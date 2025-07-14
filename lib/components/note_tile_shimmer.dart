import 'package:flutter/material.dart';

class NoteTileShimmer extends StatelessWidget {
  const NoteTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 150,
                            height: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 21,
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 14,
                  color: Colors.grey,
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  height: 14,
                  color: Colors.grey,
                ),
                const SizedBox(height: 4),
                Container(
                  width: 200,
                  height: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
