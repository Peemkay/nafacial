import 'package:flutter/material.dart';
import '../config/design_system.dart';

class QuickFaceRecognitionWidget extends StatelessWidget {
  final Function() onRecognize;
  
  const QuickFaceRecognitionWidget({
    Key? key, 
    required this.onRecognize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onRecognize,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DesignSystem.primaryColor.withValues(alpha: 26),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.face,
                      color: DesignSystem.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Face Recognition',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Verify personnel identity instantly',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode 
                                ? Colors.white.withValues(alpha: 178) 
                                : Colors.black.withValues(alpha: 178),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
