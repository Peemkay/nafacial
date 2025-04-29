import 'package:flutter/material.dart';
import 'web_footer.dart';

/// A container that ensures the footer stays at the bottom of the page
/// without covering content
class WebFooterContainer extends StatelessWidget {
  final Widget child;

  const WebFooterContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        SingleChildScrollView(
          child: Column(
            children: [
              // Main content
              child,

              // Space for footer
              const SizedBox(height: 300), // Adjust based on footer height
            ],
          ),
        ),

        // Footer positioned at the bottom
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: WebFooter(),
        ),
      ],
    );
  }
}
