import 'package:flutter/material.dart';

class PetStepHeader extends StatelessWidget {
  final int current;
  final List<String> titles;

  // Special warning for breed mandatory
  final bool showBreedWarning;

  const PetStepHeader({
    super.key,
    required this.current,
    required this.titles,
    this.showBreedWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(titles.length, (i) {
              final active = i <= current;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 3,
                      margin: EdgeInsets.only(
                        right: i == titles.length - 1 ? 0 : 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: active ? primary : Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      titles[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: i == current
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: i == current
                            ? Colors.black
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          if (showBreedWarning)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.orange.shade800,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Breed is mandatory. Please select Animal Type + Breed.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
