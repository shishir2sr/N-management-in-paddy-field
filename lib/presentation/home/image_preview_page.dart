import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:LCC/application/image_processror_notifier_provider.dart';
import 'package:LCC/core/shared/color_constants.dart';
import 'package:LCC/domain/image_type.dart';
import 'package:LCC/domain/segmentation_result.dart';
import 'package:LCC/presentation/home/home_page.dart';
import 'package:LCC/presentation/home/widgets/image_preview_widget.dart';
import 'package:LCC/presentation/home/widgets/image_selection_widget.dart';

/// Shows the captured leaf next to its segmented version, with the LCC score
/// the models produced.
///
/// This page used to run the classification model itself from an unawaited
/// `initState` call, against an interpreter that had no listeners and could be
/// disposed across the `await`. The score now arrives with the segmentation
/// result, so there is no inference here at all.
class ImagePreviewPage extends ConsumerWidget {
  const ImagePreviewPage({
    super.key,
    required this.segmentationResult,
  });

  final SegmentationResult segmentationResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = segmentationResult;

    return Scaffold(
      backgroundColor: ColorConstants.secondaryBackgroundColor,
      appBar: getAppBar(
        title: 'Preview',
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      persistentFooterButtons: [
        ImageSelectionPlaceholderWidget(
          onSelectImage: () {
            if (result.isValidLabel) {
              ref.read(imageProcessorProvider.notifier).addResult(
                    result.lccLabel,
                  );
            } else {
              showSnackBar(
                context,
                'This reading could not be scored. Please capture the leaf '
                'again.',
              );
              return;
            }
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          onRetakeImage: () => Navigator.of(context).pop(),
        )
      ],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _ScoreBanner(
              label: result.lccLabel,
              isValid: result.isValidLabel,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorConstants.secondaryGreen,
                    width: 0.3,
                  ),
                  shape: BoxShape.rectangle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ImagePreviewWidget(
                        image: result.originalImage,
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
                        image: result.outputImage,
                        imageType: ImageType.segmented,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBanner extends StatelessWidget {
  const _ScoreBanner({required this.label, required this.isValid});

  final int label;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: isValid
            ? ColorConstants.primaryGreen
            : Colors.red.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isValid ? 'Leaf colour score: $label' : 'Could not score this leaf',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
