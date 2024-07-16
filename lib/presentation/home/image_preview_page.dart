import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/application/image_processror_notifier_provider.dart';
import 'package:rice_fertile_ai/domain/segmentation_result.dart';
import 'package:rice_fertile_ai/presentation/home/home_page.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/bottom_navbar_widget.dart';

class ImagePreviewPage extends ConsumerWidget {
  final SegmentationResult segmentationResult;

  const ImagePreviewPage({super.key, required this.segmentationResult});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: getAppBar(
        title: 'Preview',
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      persistentFooterButtons: [
        ImageSelectionPlaceholderWidget(
          onSelectImage: () {
            ref
                .read(imageProcessorProvider.notifier)
                .updateImageList(segmentationResult.outputImage);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          onRetakeImage: () {
            Navigator.of(context).pop();
          },
        )
      ],
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(child: Image.memory(segmentationResult.outputImage)),
          ],
        ),
      ),
    );
  }
}

class ImageSelectionPlaceholderWidget extends StatelessWidget {
  const ImageSelectionPlaceholderWidget({
    super.key,
    required this.onSelectImage,
    required this.onRetakeImage,
  });
  final Function() onSelectImage;
  final Function() onRetakeImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SecondaryLccButtonWidget(
          onPressed: onSelectImage,
          icon: Icons.check,
        ),
        SecondaryLccButtonWidget(
          onPressed: onRetakeImage,
          icon: Icons.close,
          iconColor: Colors.red,
        ),
        // Retake Button
      ],
    );
  }
}
