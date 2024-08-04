// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rice_fertile_ai/application/image_processror_notifier_provider.dart';
import 'package:rice_fertile_ai/core/shared/color_constants.dart';
import 'package:rice_fertile_ai/core/shared/string_constants.dart';
import 'package:rice_fertile_ai/domain/image_type.dart';
import 'package:rice_fertile_ai/domain/segmentation_result.dart';
import 'package:rice_fertile_ai/infrastructure/tflite_service.dart';
import 'package:rice_fertile_ai/presentation/home/home_page.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/image_preview_widget.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/image_selection_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ImagePreviewPage extends StatefulHookConsumerWidget {
  final SegmentationResult segmentationResult;

  const ImagePreviewPage({
    super.key,
    required this.segmentationResult,
  });

  @override
  ConsumerState<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends ConsumerState<ImagePreviewPage> {
  int _result = -1;
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Read the interpreter provider
    final interpreter = await ref
        .read(interpreterProvider(StrConsts.classificationModelPath).future);

    _result = await ref.read(imageProcessorProvider.notifier).classifyImages(
          interpreter: interpreter,
          segmentedImage: widget.segmentationResult.outputImage,
        );

    print('');
  }

  @override
  Widget build(BuildContext context) {
    final imageProcessor = ref.watch(imageProcessorProvider);

    imageProcessor.maybeWhen(
      loading: () => context.loaderOverlay.show(),
      orElse: () => context.loaderOverlay.hide(),
    );

    ref.listen(interpreterProvider(StrConsts.segmentationModelPath),
        (state, next) {
      state?.maybeWhen(
          orElse: () {},
          error: (e, s) {
            context.loaderOverlay.hide();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: Colors.red,
              ),
            );
          });
    });

    return Scaffold(
      backgroundColor: ColorConstants.secondaryBackgroundColor,
      appBar: getAppBar(
        title: 'Preview',
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      persistentFooterButtons: [
        ImageSelectionPlaceholderWidget(
          onSelectImage: () async {
            if (_result > 1 && _result < 6) {
              final notifier = ref.read(imageProcessorProvider.notifier);
              await notifier.updateState(result: _result);
            }
            if (context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
          onRetakeImage: () {
            Navigator.of(context).pop();
          },
        )
      ],
      body: LoaderOverlay(
        useDefaultLoading: false,
        overlayWidgetBuilder: (_) {
          //ignored progress for the moment
          return const Center(
            child: SpinKitPulsingGrid(
              color: ColorConstants.primaryGreen,
              size: 100.0,
            ),
          );
        },
        child: Padding(
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
                shape: BoxShape.rectangle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: ImagePreviewWidget(
                    image: widget.segmentationResult.originalImage,
                    imageType: ImageType.original,
                  )),
                  const SizedBox(height: 8),
                  const Divider(
                    color: ColorConstants.secondaryGreen,
                    thickness: 0.3,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ImagePreviewWidget(
                      image: widget.segmentationResult.outputImage,
                      imageType: ImageType.segmented,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
