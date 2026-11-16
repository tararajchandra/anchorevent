import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../graphics_consts/graphics_color_consts.dart';

class ScannerViewfinderCard extends StatelessWidget {
  final bool isCameraActive;
  final VoidCallback onToggleCamera;
  final ValueChanged<String> onBarcodeDetected;
  final VoidCallback onSimulateKnownScan;
  final VoidCallback onSimulateUnlinkedScan;
  final String knownBtnLabel;
  final String unlinkedBtnLabel;

  const ScannerViewfinderCard({
    super.key,
    required this.isCameraActive,
    required this.onToggleCamera,
    required this.onBarcodeDetected,
    required this.onSimulateKnownScan,
    required this.onSimulateUnlinkedScan,
    required this.knownBtnLabel,
    required this.unlinkedBtnLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: GraphicsColorConsts.surfaceSlate,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: GraphicsColorConsts.borderSlate),
      ),
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(14.0),
            child: SizedBox(
              height: 165.0,
              width: double.infinity,
              child: isCameraActive
                  ? MobileScanner(
                      onDetect: (capture) {
                        for (final barcode in capture.barcodes) {
                          final raw = barcode.rawValue;
                          if (raw != null && raw.isNotEmpty) {
                            onBarcodeDetected(raw);
                            break;
                          }
                        }
                      },
                    )
                  : Container(
                      color: GraphicsColorConsts.backgroundDark,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 44.0,
                            color: GraphicsColorConsts.primaryTeal,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Google ML Kit • Continuous Barcode Scanner',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: GraphicsColorConsts.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          TextButton.icon(
                            onPressed: onToggleCamera,
                            icon: const Icon(
                              Icons.videocam_rounded,
                              size: 16.0,
                              color: GraphicsColorConsts.primaryTeal,
                            ),
                            label: Text(
                              'Activate Live Camera',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: GraphicsColorConsts.primaryTeal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: onSimulateKnownScan,
                  child: Text(
                    knownBtnLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: GraphicsColorConsts.primaryTeal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: OutlinedButton(
                  onPressed: onSimulateUnlinkedScan,
                  child: Text(
                    unlinkedBtnLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: GraphicsColorConsts.warningAmber,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
