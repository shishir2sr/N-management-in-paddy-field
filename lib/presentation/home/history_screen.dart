import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:LCC/Utils/app_fonts.dart';
import 'package:LCC/Utils/result_details_model.dart';
import 'package:LCC/presentation/home/home_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? '1 day ago'
          : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 minute ago'
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: getAppBar(
        title: 'History',
      ),
      body: ValueListenableBuilder<Box<ResultStateDetails>>(
        valueListenable:
            Hive.box<ResultStateDetails>('resultStateBox').listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('No results found.'),
            );
          }

          final itemCount = box.length;
          return ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final reverseIndex = itemCount - 1 - index;
              final result = box.getAt(reverseIndex);
              if (result == null) return const SizedBox.shrink();

              final timeAgo = _formatTimeAgo(result.date);

              return Dismissible(
                key: Key(result.key
                    .toString()), // Use a unique key for the Dismissible
                direction: DismissDirection.endToStart, // Right to left swipe
                onDismissed: (direction) {
                  box.deleteAt(
                      reverseIndex); // Delete the item from the Hive box
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item deleted')),
                  );
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red, // Background color when swiping
                  child: const Icon(Icons.delete,
                      color: Colors.white), // Delete icon
                ),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.green, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: DetailsText(
                        text:
                            'Date: ${DateFormat('dd/MM/yyyy').format(result.date)}',
                        color: Colors.grey[800]!,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          DetailsText(
                            text:
                                'Urea Needed: ${result.ureaNeeded.toStringAsFixed(2)} kg',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          DetailsText(
                            text: 'Recommendation: ${result.recommendation}',
                          ),
                          DetailsText(
                            text:
                                'Land Amount: ${result.landAmountInBigha.toStringAsFixed(2)} Bigha',
                          ),
                          DetailsText(
                            text:
                                'Average LLC: ${result.averageLLC.toStringAsFixed(2)}',
                          ),
                          DetailsText(text: 'Added: $timeAgo'),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailsText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  const DetailsText({
    super.key,
    required this.text,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.w400,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        fontFamily: AppFonts.MANROPE,
      ),
    );
  }
}
