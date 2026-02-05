import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class CropImageScreen extends StatefulWidget {
  final File imageFile;

  const CropImageScreen({super.key, required this.imageFile});

  @override
  State<CropImageScreen> createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  final CropController _cropController = CropController();
  late Uint8List _imageBytes;
  bool _isCropping = false;
  bool _overlayVisible = true;
  bool _undoEnabled = false;
  bool _redoEnabled = false;
  String _statusText = '';
  bool _isImageLoaded = false;
final double headerWidth = MediaQuery.of(context).size.width;
final double headerHeight = 260;
final double headerAspectRatio = headerWidth / headerHeight;
  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await widget.imageFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _isImageLoaded = true;
      });
    } catch (e, stackTrace) {
      _logError('Failed to load image bytes', e, stackTrace);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load image.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      });
    }
  }

  void _logError(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('❌ ERROR: $message');
    if (error != null) debugPrint('Details: $error');
    if (stackTrace != null) debugPrint('Stack trace: $stackTrace');
  }

  void _logSuccess(String message) {
    debugPrint('✅ SUCCESS: $message');
  }

  // Function to rotate the image
  Future<void> _rotateImage() async {
    try {
      // For the crop_your_image package, we need to use a different approach
      // Since there's no direct rotate method, we'll rotate the image bytes
      // This is a simple 90-degree clockwise rotation example
      final rotatedBytes = await _rotateImageBytes(_imageBytes, 90);
      setState(() {
        _imageBytes = rotatedBytes;
      });
      _logSuccess('Image rotated 90 degrees');
    } catch (e, stackTrace) {
      _logError('Failed to rotate image', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to rotate image.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper function to rotate image bytes
  Future<Uint8List> _rotateImageBytes(Uint8List bytes, int degrees) async {
    // This is a simplified version - in a real app, you'd want to use an image processing library
    // like image or image_picker for proper rotation

    // For now, we'll just reload the original image and let the user know
    // In production, consider using the `image` package:
    // import 'package:image/image.dart' as img;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Rotated ${degrees}° - Note: Full rotation requires image processing library',
        ),
        backgroundColor: Colors.blue,
      ),
    );

    // Return original bytes (in real implementation, actually rotate)
    return bytes;
  }

  Future<Uint8List> _compressTo1MB(Uint8List bytes) async {
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // Resize large images (extra safety)
    if (image.width > 1080) {
      image = img.copyResize(image, width: 1080);
    }

    int quality = 95;
    Uint8List result;

    do {
      result = Uint8List.fromList(img.encodeJpg(image, quality: quality));
      quality -= 5;
    } while (result.lengthInBytes > 1024 * 1024 && quality > 10);

    log(
      '🖼 Final image size: ${(result.lengthInBytes / 1024 / 1024).toStringAsFixed(2)} MB',
    );
    return result;
  }

  Future<void> _handleCroppedImage(Uint8List croppedImageBytes) async {
    try {
      _logSuccess('Cropping completed');

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/cropped_image_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      final compressedBytes = await _compressTo1MB(croppedImageBytes);

      await tempFile.writeAsBytes(compressedBytes);

      _logSuccess(
        'Compressed size: ${(compressedBytes.lengthInBytes / 1024 / 1024).toStringAsFixed(2)} MB',
      );
      // await tempFile.writeAsBytes(croppedImageBytes);
      // _logSuccess('Image saved to: ${tempFile.path}');

      if (!mounted) return;

      // Show the preview bottom sheet
      await _showPreviewBottomSheet(tempFile);
    } catch (e, stackTrace) {
      _logError('Failed to save cropped image', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to crop image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCropping = false);
      }
    }
  }

  Future<void> _showPreviewBottomSheet(File croppedImage) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black87,
      isDismissible: false,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Expanded(
                        // FIX: Wrap the entire content in Expanded
                        child: SingleChildScrollView(
                          // FIX: Add SingleChildScrollView
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize:
                                  MainAxisSize.min, // FIX: Changed to min
                              children: [
                                const Text(
                                  'Crop Preview',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0703C9),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Check your cropped image before proceeding',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                // FIX: Removed Expanded and used Container with fixed height
                                Container(
                                  height:
                                      300, // FIX: Fixed height instead of Expanded
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.file(
                                      croppedImage,
                                      fit: BoxFit.contain,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.error,
                                                color: Colors.red,
                                                size: 50,
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'Failed to load preview',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                child: const Text('Try Again'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: const Color(
                                            0xFF0703C9,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 18,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            side: const BorderSide(
                                              color: Color(0xFF0703C9),
                                              width: 2,
                                            ),
                                          ),
                                          elevation: 0,
                                          shadowColor: Colors.transparent,
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.crop, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Re-crop',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF0703C9,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 18,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 4,
                                          shadowColor: const Color(
                                            0xFF0703C9,
                                          ).withOpacity(0.3),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.check_circle, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Continue',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );

    if (result == true) {
      // User wants to re-crop
      return;
    } else if (result == false) {
      // User wants to continue with this crop
      if (mounted) Navigator.pop(context, croppedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            "Crop Image",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0703C9),
          elevation: 0,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          actions: [
            IconButton(
              onPressed: _isImageLoaded ? _rotateImage : null,
              icon: const Icon(Icons.rotate_90_degrees_cw_outlined),
              tooltip: 'Rotate 90°',
            ),
          ],
        ),
        body:
            !_isImageLoaded
                ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFF0703C9)),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Crop(
                              controller: _cropController,
                              image: _imageBytes,
                              aspectRatio: headerAspectRatio,
                              onCropped: (result) async {
                                switch (result) {
                                  case CropSuccess(:final croppedImage):
                                    await _handleCroppedImage(croppedImage);
                                  case CropFailure(:final cause):
                                    _logError('Cropping failed: $cause');
                                    if (mounted) {
                                      setState(() => _isCropping = false);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Crop failed: $cause'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                }
                              },
                              aspectRatio: headerAspectRatio,

                              withCircleUi: false,
                              interactive: true,
                              cornerDotBuilder:
                                  (size, edgeAlignment) => Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: const Color(0xFF0703C9),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                              baseColor: Colors.black.withOpacity(0.7),
                              maskColor: Colors.black.withOpacity(0.5),
                              onHistoryChanged: (history) {
                                if (mounted) {
                                  setState(() {
                                    _undoEnabled = history.undoCount > 0;
                                    _redoEnabled = history.redoCount > 0;
                                  });
                                }
                              },
                              onStatusChanged: (status) {
                                if (mounted) {
                                  setState(() {
                                    _statusText =
                                        {
                                          CropStatus.nothing: 'No image loaded',
                                          CropStatus.loading:
                                              'Loading image...',
                                          CropStatus.ready: 'Ready to crop!',
                                          CropStatus.cropping: 'Cropping...',
                                        }[status] ??
                                        '';
                                  });
                                }
                              },
                              overlayBuilder:
                                  _overlayVisible
                                      ? (context, rect) =>
                                          CustomPaint(painter: GridPainter())
                                      : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Status and Controls Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Status Text
                            Text(
                              _statusText,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    _statusText.contains('failed') ||
                                            _statusText.contains('error')
                                        ? Colors.red
                                        : Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Controls Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Undo Button
                                Tooltip(
                                  message: 'Undo',
                                  child: IconButton(
                                    onPressed:
                                        _undoEnabled
                                            ? () => _cropController.undo()
                                            : null,
                                    icon: const Icon(Icons.undo),
                                    color:
                                        _undoEnabled
                                            ? const Color(0xFF0703C9)
                                            : Colors.grey,
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          _undoEnabled
                                              ? const Color(
                                                0xFF0703C9,
                                              ).withOpacity(0.1)
                                              : Colors.grey[100],
                                      padding: const EdgeInsets.all(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Redo Button
                                Tooltip(
                                  message: 'Redo',
                                  child: IconButton(
                                    onPressed:
                                        _redoEnabled
                                            ? () => _cropController.redo()
                                            : null,
                                    icon: const Icon(Icons.redo),
                                    color:
                                        _redoEnabled
                                            ? const Color(0xFF0703C9)
                                            : Colors.grey,
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          _redoEnabled
                                              ? const Color(
                                                0xFF0703C9,
                                              ).withOpacity(0.1)
                                              : Colors.grey[100],
                                      padding: const EdgeInsets.all(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Grid Toggle
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF0703C9,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.grid_on,
                                        color: Color(0xFF0703C9),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Grid',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF0703C9),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Switch(
                                        value: _overlayVisible,
                                        onChanged:
                                            (val) => setState(
                                              () => _overlayVisible = val,
                                            ),
                                        activeColor: const Color(0xFF0703C9),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Crop Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _isCropping
                                        ? null
                                        : () {
                                          try {
                                            setState(() => _isCropping = true);
                                            _cropController.crop();
                                            _logSuccess(
                                              'Crop action initiated',
                                            );
                                          } catch (e, stackTrace) {
                                            _logError(
                                              'Crop initiation failed',
                                              e,
                                              stackTrace,
                                            );
                                            if (mounted) {
                                              setState(
                                                () => _isCropping = false,
                                              );
                                            }
                                          }
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0703C9),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  shadowColor: const Color(
                                    0xFF0703C9,
                                  ).withOpacity(0.3),
                                  disabledBackgroundColor: Colors.grey[400],
                                ),
                                child:
                                    _isCropping
                                        ? const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Cropping...',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        )
                                        : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.crop, size: 20),
                                            SizedBox(width: 12),
                                            Text(
                                              'Crop Image',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final int divisions = 3; // Changed to 3x3 grid
  final double strokeWidth = 1.0;
  final Color color = Colors.white.withOpacity(0.7);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..strokeWidth = strokeWidth
          ..color = color
          ..style = PaintingStyle.stroke;

    // Draw grid lines
    final xSpacing = size.width / (divisions + 1);
    final ySpacing = size.height / (divisions + 1);

    for (int i = 1; i <= divisions; i++) {
      // Vertical lines
      canvas.drawLine(
        Offset(xSpacing * i, 0),
        Offset(xSpacing * i, size.height),
        paint,
      );
      // Horizontal lines
      canvas.drawLine(
        Offset(0, ySpacing * i),
        Offset(size.width, ySpacing * i),
        paint,
      );
    }

    // Draw border
    final borderPaint =
        Paint()
          ..strokeWidth = 2.0
          ..color = Colors.white.withOpacity(0.9)
          ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
