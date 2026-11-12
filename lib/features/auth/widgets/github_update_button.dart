import 'package:flutter/material.dart';
import 'package:flutter_ota_update/flutter_ota_update.dart';

import '../../../app/app_theme.dart';

class GithubUpdateButton extends StatefulWidget {
  const GithubUpdateButton({super.key});

  @override
  State<GithubUpdateButton> createState() =>
      _GithubUpdateButtonState();
}

class _GithubUpdateButtonState
    extends State<GithubUpdateButton> {
  static const githubOwner = 'dahadigitalkreasi';
  static const githubRepo = 'ddk_mobile';

  bool isChecking = false;
  bool isDownloading = false;
  double progress = 0;

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> checkUpdate() async {
    if (isChecking || isDownloading) return;

    if (githubOwner == 'NAMA_AKUN_GITHUB' ||
        githubRepo == 'NAMA_REPOSITORY') {
      showMessage(
        'Isi akun dan repository GitHub terlebih dahulu.',
      );
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

      // Membandingkan versi terpasang dengan
      // GitHub Release terbaru.
      final release = await ota.checkForUpdate();

      if (!mounted) return;

      if (release == null) {
        showMessage(
          'Aplikasi sudah menggunakan versi terbaru.',
        );
        return;
      }

      // TANYAKAN SEBELUM DOWNLOAD
      final shouldDownload = await showDialog<bool>(
        context: context,
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
                Text(
                  'Versi terbaru: ${release.version}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Download APK terbaru dari GitHub '
                  'dan lanjutkan ke pemasangan Android?',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Data aplikasi yang sudah tersimpan '
                  'biasanya tetap ada selama update '
                  'berhasil dipasang tanpa uninstall.',
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

      // DOWNLOAD, VERIFIKASI, DAN BUKA INSTALLER
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
      showMessage(
        'Gagal memeriksa atau mengunduh update: $error',
      );
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
          onPressed: busy ? null : checkUpdate,
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