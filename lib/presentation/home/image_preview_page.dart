import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/application/image_processror_notifier_provider.dart';
import 'package:rice_fertile_ai/core/shared/color_constants.dart';
import 'package:rice_fertile_ai/domain/image_type.dart';
import 'package:rice_fertile_ai/domain/segmentation_result.dart';
import 'package:rice_fertile_ai/presentation/home/home_page.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/image_preview_widget.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/image_selection_widget.dart';

class ImagePreviewPage extends ConsumerWidget {
  final SegmentationResult segmentationResult;

  const ImagePreviewPage({super.key, required this.segmentationResult});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ColorConstants.secondaryBackgroundColor,
      appBar: getAppBar(
        title: 'Preview',
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      persistentFooterButtons: [
        ImageSelectionPlaceholderWidget(
          onSelectImage: () {
            final notifier = ref.read(imageProcessorProvider.notifier);
            notifier.updateImageList(segmentationResult);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          onRetakeImage: () {
            Navigator.of(context).pop();
          },
        )
      ],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Container(
            // take full width
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border.all(
                  color: ColorConstants.secondaryGreen,
                  width: 0.3,
                ),
                shape: BoxShape.rectangle),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ImagePreviewWidget(
                    image: segmentationResult.originalImage,
                    imageType: ImageType.original,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(
                  color: ColorConstants.secondaryGreen,
                  thickness: 0.3,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ImagePreviewWidget(
                    image: segmentationResult.outputImage,
                    imageType: ImageType.segmented,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
