import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../services/chat_reverb_service.dart';

/// Halaman satu percakapan Packing <-> CS.
///
/// Contoh penggunaan:
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => const ChatDetailPage(chatId: 1),
/// ));
///
/// Kunci publik Reverb harus dipasok dengan --dart-define=REVERB_APP_KEY=...
/// Endpoint websocket juga bisa diatur menggunakan --dart-define=REVERB_WS_URL=...
class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key, required this.chatId});

  final int chatId;

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  static const _storage = FlutterSecureStorage();
  static const _appKey = String.fromEnvironment('REVERB_APP_KEY');
  static const _wsOverride = String.fromEnvironment('REVERB_WS_URL');

  final _input = TextEditingController();
  final _scroll = ScrollController();
  final Map<int, Map<String, dynamic>> _byId = {};

  ChatReverbService? _reverb;
  StreamSubscription<Map<String, dynamic>>? _messageSub;
  StreamSubscription<String>? _statusSub;
  StreamSubscription<Map<String, dynamic>>? _readReceiptSub;
  String? _token;
  int? _myUserId;
  Map<String, dynamic>? _chat;
  String _realtimeStatus = 'belum terhubung';
  String? _error;
  bool _loading = true;
  bool _sending = false;
  bool _closing = false;
  bool _loadingOlder = false;
  bool _hasMore = false;
  bool _readRequestInFlight = false;
  int _lastReadAckId = 0;

  // Pertahankan UUID selama retry untuk pesan yang sama.
  String? _pendingMessageId;
  String? _pendingMessageText;

  static String _newMessageUuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // UUID versi 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // RFC 4122 variant
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  List<Map<String, dynamic>> get _messages {
    final values = _byId.values.toList();
    values.sort((a, b) => _id(a).compareTo(_id(b)));
    return values;
  }

  static int _id(Map<String, dynamic> data) =>
      int.tryParse(data['id'].toString()) ?? 0;

  static Map<String, dynamic> _map(Object? raw) =>
      raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

  static String _readError(Object error) {
    if (error is DioException) {
      final body = _map(error.response?.data);
      return body['message']?.toString() ??
          'Request gagal (HTTP ${error.response?.statusCode ?? '-'}).';
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  String get _apiRoot {
    final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/$'), '');
    return base.endsWith('/api') ? base.substring(0, base.length - 4) : base;
  }

  String get _wsUrl {
    if (_wsOverride.isNotEmpty) return _wsOverride;
    final api = Uri.parse(_apiRoot);
    // Port 8080 adalah port Reverb default untuk pengujian lokal.
    // Pada hosting gunakan --dart-define=REVERB_WS_URL=wss://...
    return Uri(
      scheme: api.scheme == 'https' ? 'wss' : 'ws',
      host: api.host,
      port: 8080,
    ).toString().replaceAll(RegExp(r'/$'), '');
  }

  Options get _authOptions => Options(headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final userId = await _storage.read(key: 'user_id');
      if (token == null || token.isEmpty) {
        throw Exception('Sesi login tidak tersedia. Silakan login kembali.');
      }
      if (!mounted) return;
      _token = token;
      _myUserId = int.tryParse(userId ?? '');
      await _loadDetail();
      if (!mounted) return;
      if (_appKey.isNotEmpty) {
        await _connectRealtime();
      } else {
        setState(() => _realtimeStatus =
            'Kunci Reverb belum diatur (REVERB_APP_KEY)');
      }
    } catch (error) {
      if (mounted) setState(() { _error = _readError(error); _loading = false; });
    }
  }

  Future<void> _loadDetail({int? beforeId}) async {
    if (beforeId != null) {
      if (_loadingOlder) return;
      setState(() => _loadingOlder = true);
    }
    try {
      final response = await ApiClient.dio.get<dynamic>(
        '/chat-klarifikasi-packing/${widget.chatId}',
        queryParameters: beforeId == null ? null : {'before_id': beforeId},
        options: _authOptions,
      );
      final payload = _map(_map(response.data)['data']);
      final list = payload['pesan'];
      if (!mounted) return;
      setState(() {
        if (beforeId == null) _chat = _map(payload['chat']);
        if (list is List) {
          for (final raw in list) {
            final message = _map(raw);
            final id = _id(message);
            if (id > 0) _byId[id] = message;
          }
        }
        _hasMore = payload['has_more'] == true;
        _error = null;
        _loading = false;
      });
      if (beforeId == null) _scrollToBottom();
      _markVisibleMessagesRead();
    } catch (error) {
      if (mounted) setState(() { _error = _readError(error); _loading = false; });
    } finally {
      if (mounted && beforeId != null) {
        setState(() => _loadingOlder = false);
      }
    }
  }

  Future<void> _connectRealtime() async {
    await _messageSub?.cancel();
    await _statusSub?.cancel();
    await _readReceiptSub?.cancel();
    await _reverb?.dispose();

    final service = ChatReverbService(
      apiBaseUrl: _apiRoot,
      wsBaseUrl: _wsUrl,
      appKey: _appKey,
      authToken: _token!,
      chatId: widget.chatId,
    );
    _reverb = service;
    _messageSub = service.messages.listen((data) {
      if (!mounted) return;
      final id = _id(data);
      if (id <= 0) return;
      setState(() {
        _byId.putIfAbsent(id, () => data);
      });
      _scrollToBottom();
      _markVisibleMessagesRead();
    });
    _readReceiptSub = service.readReceipts.listen((data) {
      if (!mounted) return;
      final reader = int.tryParse('${data['pembaca_user_id']}');
      final lastId = int.tryParse('${data['last_message_id']}');
      if (reader == null || reader == _myUserId || lastId == null) return;
      setState(() {
        for (final message in _byId.values) {
          if (_id(message) <= lastId &&
              int.tryParse('${message['pengirim_user_id']}') == _myUserId) {
            message['dibaca_at'] ??= DateTime.now().toUtc().toIso8601String();
          }
        }
      });
    });
    _statusSub = service.statuses.listen((status) {
      if (!mounted) return;
      setState(() => _realtimeStatus = status);
      // Rekonsiliasi pesan saat koneksi kembali tersambung.
      if (status == 'terhubung') _loadDetail();
    });
    try {
      await service.connect();
    } catch (error) {
      if (mounted) setState(() => _realtimeStatus = _readError(error));
    }
  }

  // Hanya pesan dari lawan bicara yang sudah ditampilkan yang ditandai dibaca.
  // Jika ada pesan baru saat request berlangsung, kirim lagi setelahnya.
  Future<void> _markVisibleMessagesRead() async {
    if (!mounted || _token == null || _readRequestInFlight) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;

    int lastIncomingId = 0;
    for (final message in _byId.values) {
      final sender = int.tryParse('${message['pengirim_user_id']}');
      if (sender != null && sender != _myUserId && _id(message) > lastIncomingId &&
          message['dibaca_at'] == null) {
        lastIncomingId = _id(message);
      }
    }
    if (lastIncomingId <= _lastReadAckId) return;

    _readRequestInFlight = true;
    try {
      await ApiClient.dio.post<dynamic>(
        '/chat-klarifikasi-packing/${widget.chatId}/dibaca',
        data: {'last_message_id': lastIncomingId},
        options: _authOptions,
      );
      if (!mounted) return;
      _lastReadAckId = lastIncomingId;
      setState(() {
        for (final message in _byId.values) {
          final sender = int.tryParse('${message['pengirim_user_id']}');
          if (sender != null && sender != _myUserId &&
              _id(message) <= lastIncomingId) {
            message['dibaca_at'] ??= DateTime.now().toUtc().toIso8601String();
          }
        }
      });
    } catch (_) {
      // Saat jaringan bermasalah, baca akan dicoba kembali ketika pesan
      // dimuat ulang atau koneksi Reverb pulih. Jangan ganggu pengguna.
    } finally {
      _readRequestInFlight = false;
      if (mounted && _byId.values.any((message) {
        final sender = int.tryParse('${message['pengirim_user_id']}');
        return sender != null && sender != _myUserId &&
            message['dibaca_at'] == null && _id(message) > _lastReadAckId;
      })) {
        // Hindari loop saat request gagal; pemanggilan ulang hanya bila ada
        // pesan baru yang masuk setelah request terakhir berhasil.
        if (_lastReadAckId >= lastIncomingId) {
          _markVisibleMessagesRead();
        }
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final message = _input.text.trim();
    if (_sending || message.isEmpty || _chat?['status'] == 'selesai') return;

    // Bila jaringan putus, kirim ulang UUID yang sama untuk pesan yang sama.
    // Bila isi pesan berubah, gunakan UUID baru agar tidak dianggap retry.
    if (_pendingMessageText != message || _pendingMessageId == null) {
      _pendingMessageText = message;
      _pendingMessageId = _newMessageUuid();
    }
    final clientMessageId = _pendingMessageId!;

    setState(() => _sending = true);
    try {
      final response = await ApiClient.dio.post<dynamic>(
        '/chat-klarifikasi-packing/${widget.chatId}/pesan',
        data: {
          'pesan': message,
          'client_message_id': clientMessageId,
        },
        options: _authOptions,
      );
      final sent = _map(_map(response.data)['data']);
      if (!mounted) return;
      setState(() {
        if (_id(sent) > 0) _byId[_id(sent)] = sent;
        _chat = {...?_chat, 'status': _myUserId == _chat?['cs_user_id']
            ? 'dibalas' : 'menunggu_jawaban'};
      });
      // Jangan hapus teks baru yang mungkin diketik saat request berjalan.
      if (_input.text.trim() == message) _input.clear();
      _pendingMessageText = null;
      _pendingMessageId = null;
      _scrollToBottom();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_readError(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _loadOlder() async {
    if (!_hasMore || _byId.isEmpty) return;
    await _loadDetail(beforeId: _messages.first['id'] as int?);
  }

  Future<void> _finish() async {
    if (_closing) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selesaikan klarifikasi?'),
        content: const Text('Chat yang sudah selesai tidak bisa menerima pesan baru.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Selesaikan')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _closing = true);
    try {
      await ApiClient.dio.post<dynamic>(
        '/chat-klarifikasi-packing/${widget.chatId}/selesai',
        options: _authOptions,
      );
      if (!mounted) return;
      setState(() => _chat = {...?_chat, 'status': 'selesai'});
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_readError(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _closing = false);
    }
  }

  String _clock(Object? raw) {
    final value = DateTime.tryParse(raw?.toString() ?? '');
    if (value == null) return '';
    final local = value.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _statusSub?.cancel();
    _readReceiptSub?.cancel();
    _reverb?.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = _chat;
    final finished = chat?['status'] == 'selesai';
    final canFinish = _myUserId != null &&
        _myUserId == int.tryParse('${chat?['packing_user_id']}') &&
        !finished;
    return Scaffold(
      appBar: AppBar(
        title: Text(chat == null
            ? 'Chat #${widget.chatId}'
            : 'Pesanan ${chat['no_pesanan']}'),
        actions: [
          if (canFinish)
            IconButton(
              tooltip: 'Selesaikan klarifikasi',
              onPressed: _closing ? null : _finish,
              icon: const Icon(Icons.task_alt),
            ),
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _loading ? null : () => _loadDetail(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Material(
              color: _realtimeStatus == 'terhubung'
                  ? Colors.green.shade50 : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                child: Row(children: [
                  Icon(Icons.circle, size: 9,
                      color: _realtimeStatus == 'terhubung'
                          ? Colors.green : Colors.orange),
                  const SizedBox(width: 9),
                  Expanded(child: Text('Real-time: $_realtimeStatus',
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12))),
                ]),
              ),
            ),
            if (chat != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${chat['topik'] ?? 'Klarifikasi'} · ${chat['status'] ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: Column(children: [
                  if (_hasMore)
                    TextButton(
                      onPressed: _loadingOlder ? null : _loadOlder,
                      child: Text(_loadingOlder ? 'Memuat...' : 'Muat pesan sebelumnya'),
                    ),
                  Expanded(
                    child: _messages.isEmpty
                        ? const Center(child: Text('Belum ada pesan.'))
                        : ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.all(12),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final m = _messages[index];
                              final senderId = int.tryParse('${m['pengirim_user_id']}');
                              final mine = senderId != null && senderId == _myUserId;
                              final sender = _map(m['pengirim']);
                              final name = sender['name']?.toString() ??
                                  m['pengirim_nama']?.toString() ?? 'Pengguna';
                              return Align(
                                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  constraints: BoxConstraints(maxWidth:
                                      MediaQuery.sizeOf(context).width * .82),
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: mine ? const Color(0xFFD9F7E9)
                                        : const Color(0xFFF1F3F5),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 11)),
                                      const SizedBox(height: 5),
                                      Text('${m['pesan'] ?? ''}'),
                                      const SizedBox(height: 4),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(_clock(m['created_at']),
                                                style: const TextStyle(
                                                    fontSize: 10, color: Colors.black54)),
                                            if (mine) ...[
                                              const SizedBox(width: 5),
                                              Icon(
                                                m['dibaca_at'] != null
                                                    ? Icons.done_all
                                                    : Icons.done,
                                                size: 15,
                                                color: m['dibaca_at'] != null
                                                    ? Colors.blue
                                                    : Colors.black54,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ]),
              ),
            if (finished)
              const Padding(
                padding: EdgeInsets.all(14),
                child: Text('Klarifikasi telah selesai. Pesan baru dinonaktifkan.'),
              )
            else if (!_loading && _error == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(children: [
                  Expanded(child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 10000,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      hintText: 'Tulis pesan ke CS / Packing...',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  )),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Kirim pesan',
                    onPressed: _sending ? null : _sendMessage,
                    icon: _sending ? const SizedBox(height: 18, width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send),
                  ),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}