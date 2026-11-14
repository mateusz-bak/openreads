import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:permission_handler/permission_handler.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _scanned = false;

  void _onScan(Code code) {
    final text = code.text;

    // the reader keeps scanning until the screen is closed
    if (_scanned || !mounted || !code.isValid || text == null) return;

    // ISBN-13 always starts with 978 or 979, other EAN-13 codes are products
    if (!text.startsWith('978') && !text.startsWith('979')) return;

    _scanned = true;
    Navigator.of(context).pop(text);
  }

  // the reader only logs camera errors (denied permission, no camera)
  void _onControllerCreated(CameraController? controller, Exception? error) {
    if (error == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocaleKeys.camera_error.tr()),
        action: SnackBarAction(
          label: LocaleKeys.open_settings.tr(),
          onPressed: openAppSettings,
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          LocaleKeys.add_scan.tr(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: ReaderWidget(
        onScan: _onScan,
        onControllerCreated: _onControllerCreated,
        codeFormat: Format.ean13,
        showGallery: false,
        showToggleCamera: false,
        cropPercent: 0.8,
        scanDelaySuccess: Duration.zero,
      ),
    );
  }
}
