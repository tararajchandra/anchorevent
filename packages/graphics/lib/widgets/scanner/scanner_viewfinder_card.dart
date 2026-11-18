import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../graphics_consts/graphics_color_consts.dart';
import '../../graphics_consts/graphics_string_consts.dart';

class ScannerViewfinderCard extends StatelessWidget {
  final bool isCameraActive;
  final bool isShutterClosed;
  final String scannedProductLabel;
  final VoidCallback onToggleCamera;
  final ValueChanged<String> onBarcodeDetected;
  final VoidCallback onSimulateKnownScan;
  final VoidCallback onSimulateUnlinkedScan;
  final VoidCallback? onRescanTap;
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
    this.isShutterClosed = false,
    this.scannedProductLabel = '',
    this.onRescanTap,
  });

  Widget _buildCameraPlaceholder(ThemeData theme) {
    return Container(
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
    );
  }

  Widget _buildShutterOverlay(ThemeData theme) {
    return Container(
      color: GraphicsColorConsts.backgroundDark.withAlpha(242),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 5.0,
            ),
            decoration: BoxDecoration(
              color: GraphicsColorConsts.accentEmerald.withAlpha(38),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: GraphicsColorConsts.accentEmerald),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16.0,
                  color: GraphicsColorConsts.accentEmerald,
                ),
                const SizedBox(width: 6.0),
                Flexible(
                  child: Text(
                    GraphicsStringConsts.shutterScannedBadge,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: GraphicsColorConsts.accentEmerald,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (scannedProductLabel.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6.0),
            Text(
              scannedProductLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: GraphicsColorConsts.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 4.0),
          Text(
            GraphicsStringConsts.shutterReadyHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: GraphicsColorConsts.textMuted,
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            height: 28.0,
            child: OutlinedButton.icon(
              onPressed: onRescanTap,
              icon: const Icon(
                Icons.camera_alt_rounded,
                size: 14.0,
                color: GraphicsColorConsts.primaryTeal,
              ),
              label: Text(
                GraphicsStringConsts.shutterRescanBtn,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: GraphicsColorConsts.primaryTeal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  isCameraActive
                      ? MobileScanner(
                          onDetect: (capture) {
                            if (isShutterClosed) {
                              return;
                            }
                            for (final barcode in capture.barcodes) {
                              final raw = barcode.rawValue;
                              if (raw != null && raw.isNotEmpty) {
                                onBarcodeDetected(raw);
                                break;
                              }
                            }
                          },
                        )
                      : _buildCameraPlaceholder(theme),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    top: isShutterClosed ? 0.0 : -85.0,
                    left: 0.0,
                    right: 0.0,
                    height: 83.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: GraphicsColorConsts.backgroundDark,
                        border: Border(
                          bottom: BorderSide(
                            color: GraphicsColorConsts.primaryTeal,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    bottom: isShutterClosed ? 0.0 : -85.0,
                    left: 0.0,
                    right: 0.0,
                    height: 83.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: GraphicsColorConsts.backgroundDark,
                        border: Border(
                          top: BorderSide(
                            color: GraphicsColorConsts.primaryTeal,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isShutterClosed) _buildShutterOverlay(theme),
                ],
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
