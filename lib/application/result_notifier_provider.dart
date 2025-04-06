import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:LCC/Utils/result_details_model.dart';
import 'package:LCC/application/image_processror_notifier_provider.dart';
import 'package:LCC/core/shared/logging_service.dart';
import 'package:LCC/infrastructure/land_conversion_service.dart';
import 'package:LCC/main.dart';
import 'package:timezone/timezone.dart';
part 'result_notifier_provider.freezed.dart';

@freezed
class ResultState with _$ResultState {
  const ResultState._();
  factory ResultState({
    required double landAmountInBigha,
    required LandConversionStrategy selectedStrategy,
    required String recommendation,
  }) = _ResultState;

  factory ResultState.initial(LandConversionStrategy strategy) => ResultState(
        landAmountInBigha: 0.0,
        selectedStrategy: strategy,
        recommendation: "No recommendation yet",
      );
}

class ResultStateNotifier extends Notifier<ResultState> {
  @override
  ResultState build() {
    final acresConverter = ref.read(acresConverterProvicer);
    return ResultState.initial(acresConverter);
  }

  void setSelectedStrategy(LandConversionStrategy strategy) {
    state = state.copyWith(selectedStrategy: strategy);
  }

  void calculateNitrogenRequirement({required double landAmount}) {
    // set the land amount in bigha
    String recommendation = "";
    _convertToBigha(landAmount);
    logger.i('Calculating nitrogen requirement');
    final resultList = ref.watch(imageProcessorProvider).value?.lccResult;
    final average = _getResultAverage(resultList!);
    logger.d('Average LCC: $average');
    final ureaRequired = _getRecommendation(averageLcc: average);

    if (ureaRequired == 0.0) {
      recommendation = "Good nitrogen level!";
      state = state.copyWith(recommendation: recommendation);
    } else {
      recommendation =
          "Recommended\nUrea:\n${ureaRequired.toStringAsFixed(2)} kg";
    }

    state = state.copyWith(recommendation: recommendation);
    logger.i('Recommendation: $recommendation');

    // save the result to the database

    var resultData = ResultStateDetails(
      landAmountInBigha: state.landAmountInBigha,
      recommendation: recommendation,
      date: DateTime.now(),
      ureaNeeded: ureaRequired,
      averageLLC: average,
    );

    saveResultHistory(resultData);
    setLocalNotification();
  }

  void setLocalNotification() async {
    logger.i('Setting local notification');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description', // Channel description
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Nitrogen Requirement Calculated', // Notification title
      'Check the latest nitrogen requirement details.', // Notification body
      TZDateTime.now(local)
          .add(const Duration(minutes: 1)), // Scheduled time (1 minute later)
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode:
          AndroidScheduleMode.exact, // Match component for accuracy
    );
  }

  saveResultHistory(ResultStateDetails resultData) {
    // save the result to the database
    logger.i('Saving result to the database');

    // Save the result data in Hive
    var box = Hive.box<ResultStateDetails>('resultStateBox');
    box.add(resultData);
  }

  // convert the land amount to bigha
  void _convertToBigha(double amount) {
    logger.i('Converting to $amount ${state.selectedStrategy}');
    final landInBigha = state.selectedStrategy.convertToBigha(amount);
    logger.d('Converted to $landInBigha Bigha');
    state = state.copyWith(landAmountInBigha: landInBigha);
  }

  // get the recommendation based on the average LCC
  double _getRecommendation({required double averageLcc}) {
    if (averageLcc <= 3.5) {
      double ureaRequired = state.landAmountInBigha * 0.227273;

      return ureaRequired;
      // return "Recommended\nUrea:\n${ureaRequired.toStringAsFixed(2)} kg";
    } else {
      return 0.0;
      // return "Good nitrogen level!\ntry again in 10 days later";
    }
  }

  // get the average of the list
  double _getResultAverage(List<int> resultList) {
    return resultList.reduce((value, element) => value + element) /
        resultList.length;
  }
}

// resultNotifierProvider is a provider that returns a ResultStateNotifier
final resultNotifierProvider =
    NotifierProvider<ResultStateNotifier, ResultState>(ResultStateNotifier.new);
