import 'package:flutter/material.dart';
import 'package:flutter_ota_update/flutter_ota_update.dart';

import '../../../app/app_theme.dart';

class GithubUpdateButton extends StatefulWidget {
  const GithubUpdateButton({super.key});

  @override
  State<GithubUpdateButton> createState() =>
      _GithubUpdateButtonState();
}

class _GithubUpdateButtonState extends State<GithubUpdateButton> {
  static const githubOwner = 'dahadigitalkreasi';
  static const githubRepo = 'ddk_mobile';

  bool isChecking = false;
  bool isDownloading = false;
  double progress = 0;

  // OTOMATIS CEK UPDATE SAAT HALAMAN DIBUKA
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      checkUpdate(automatic: true);
    });
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> checkUpdate({
    bool automatic = false,
  }) async {
    if (isChecking || isDownloading) return;

    if (githubOwner == 'NAMA_AKUN_GITHUB' ||
        githubRepo == 'NAMA_REPOSITORY') {
      if (!automatic) {
        showMessage(
          'Isi akun dan repository GitHub terlebih dahulu.',
        );
      }
      return;
    }

    setState(() {
      isChecking = true;
      progress = 0;
    });

    try {
      final ota = FlutterOtaUpdate(
        owner: githubOwner,
        repo: githubRepo,
        assetPattern: RegExp(r'app-release\.apk$'),
      );

      // CEK VERSI DI GITHUB RELEASES
      final release = await ota.checkForUpdate();

      if (!mounted) return;

      // JIKA SUDAH TERBARU
      if (release == null) {
        // OTOMATIS: TIDAK ADA POPUP
        // MANUAL: TAMPILKAN PESAN
        if (!automatic) {
          showMessage(
            'Aplikasi sudah menggunakan versi terbaru.',
          );
        }
        return;
      }

      // JIKA TERSEDIA VERSI BARU
      final shouldDownload = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.system_update_alt,
                  color: AppTheme.primary,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text('Update Tersedia'),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Versi terbaru DDK Mobile tersedia!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Versi terbaru: ${release.version}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Silakan perbarui aplikasi untuk '
                  'mendapatkan fitur dan perbaikan terbaru.',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Data aplikasi biasanya tetap tersimpan '
                  'selama update dilakukan tanpa uninstall.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: const Text('Nanti Saja'),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                icon: const Icon(Icons.download),
                label: const Text('Download Update'),
              ),
            ],
          );
        },
      );

      if (!mounted || shouldDownload != true) return;

      setState(() {
        isDownloading = true;
        progress = 0;
      });

      // DOWNLOAD DAN INSTAL APK
      await ota.downloadAndInstall(
        release,
        onProgress: (received, total) {
          if (!mounted) return;

          setState(() {
            progress = total > 0
                ? (received / total).clamp(0.0, 1.0)
                : 0;
          });
        },
      );

      if (mounted) {
        showMessage(
          'Download selesai. '
          'Lanjutkan pemasangan melalui Android.',
        );
      }
    } catch (error) {
      // JIKA CEK OTOMATIS GAGAL:
      // JANGAN GANGGU PENGGUNA
      if (!automatic) {
        showMessage(
          'Gagal memeriksa atau mengunduh update: $error',
        );
      }

      debugPrint('GitHub update error: $error');
    } finally {
      if (mounted) {
        setState(() {
          isChecking = false;
          isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = isChecking || isDownloading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: busy
              ? null
              : () => checkUpdate(),
          icon: Icon(
            isDownloading
                ? Icons.downloading
                : Icons.system_update_alt,
          ),
          label: Text(
            isChecking
                ? 'Memeriksa Update...'
                : isDownloading
                    ? 'Mengunduh Update...'
                    : 'Cek Update Aplikasi',
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),

        if (busy) ...[
          const SizedBox(height: 12),

          LinearProgressIndicator(
            value: isDownloading && progress > 0
                ? progress
                : null,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),

          const SizedBox(height: 8),

          Text(
            isChecking
                ? 'Menghubungi GitHub...'
                : progress > 0
                    ? 'Download ${(progress * 100).toStringAsFixed(0)}%'
                    : 'Menyiapkan download...',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ],
    );
  }
}
