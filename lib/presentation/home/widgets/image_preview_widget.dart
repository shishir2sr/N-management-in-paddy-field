import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:LCC/domain/image_type.dart';
import 'package:LCC/presentation/home/widgets/glassmorphic_container.dart';

class ImagePreviewWidget extends StatelessWidget {
  const ImagePreviewWidget({
    super.key,
    required this.image,
    required this.imageType,
  });

  final Uint8List image;

  final ImageType imageType;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: double.infinity,
          child: Image.memory(image, fit: BoxFit.fitWidth),
        ),
        GlassmorphicContainer(
          color: Colors.white,
          height: 40,
          width: double.infinity,
          child: Text(
            switch (imageType) {
              ImageType.original => 'Before',
              ImageType.segmented => 'After'
            },
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}
