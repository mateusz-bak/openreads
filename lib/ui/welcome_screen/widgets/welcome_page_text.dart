import 'package:flutter/material.dart';

class WelcomePageText extends StatelessWidget {
  const WelcomePageText({
    super.key,
    required this.descriptions,
    required this.image,
  });

  final List<String> descriptions;
  final Widget image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (var description in descriptions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Text(
                      description,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [image],
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
