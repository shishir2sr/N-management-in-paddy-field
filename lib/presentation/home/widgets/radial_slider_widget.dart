import 'package:flutter/material.dart';
import 'package:LCC/Utils/app_fonts.dart';
import 'package:LCC/core/shared/color_constants.dart';
import 'package:LCC/presentation/home/widgets/next_button_widget.dart';

import 'package:syncfusion_flutter_gauges/gauges.dart';

class RadialSliderWidget extends StatelessWidget {
  const RadialSliderWidget(
      {super.key,
      required this.percentage,
      required this.remaining,
      required this.onPressed});
  final double percentage;
  final int remaining;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 10,
              showLabels: false,
              showTicks: false,
              radiusFactor: 0.7,
              axisLineStyle: const AxisLineStyle(
                cornerStyle: CornerStyle.bothCurve,
                color: Colors.black12,
                thickness: 8,
              ),
              pointers: <GaugePointer>[
                RangePointer(
                  value: percentage.toDouble(),
                  cornerStyle: CornerStyle.bothCurve,
                  width: 8,
                  sizeUnit: GaugeSizeUnit.logicalPixel,
                  gradient: const SweepGradient(
                    colors: [
                      Color(0xFF7DD3A0), // Mint Green (Lighter Green)
                      Color(0xFF5E7C4E), // Olive Green
                      Color(0xFF349668), // Dark Green (Your Dark Green)
                    ],
                    stops: [0.0, 0.5, 1.0],
                    startAngle: 0.0,
                    endAngle: 2 * 3.14159265,
                  ),
                ),
                MarkerPointer(
                    value: percentage.toDouble(),
                    enableDragging: false,
                    markerHeight: 20,
                    markerWidth: 20,
                    markerType: MarkerType.circle,
                    color: const Color(0xFF4B823A),
                    borderWidth: 1,
                    borderColor: Colors.white54)
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  angle: 90,
                  axisValue: 5,
                  positionFactor: 0.025,
                  widget: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: const Offset(0, 0))
                      ],
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    height: deviceWidth * 0.5,
                    width: deviceWidth * 0.5,
                    child: Center(
                      child: remaining > 0
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${remaining.ceil()}',
                                  style: const TextStyle(
                                    fontSize: 52,
                                    fontWeight: FontWeight.bold,
                                    color: ColorConstants.primaryGreen,
                                    fontFamily: AppFonts.MANROPE,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  remaining == 1
                                      ? "Remaining\nLeaf"
                                      : 'Remaining\nLeaves',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black.withOpacity(0.5),
                                    fontFamily: AppFonts.MANROPE,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : const SizedBox(),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: remaining > 0
                ? const SizedBox.shrink()
                : NextButtonWidget(onPressed: onPressed),
          ),
        ),
      ],
    );
  }
}
