import 'package:flutter/material.dart';

class FrequencyOption extends StatelessWidget {
  final String title;
  final String? subtitle;
  // final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const FrequencyOption({
    super.key,
    required this.title,
    this.subtitle,
    // required this.icon,
    required this.isSelected,
    required this.onTap,
    // required String text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? Colors.grey.shade200
            : Theme.of(context).colorScheme.surface,
        elevation: isSelected ? 2 : 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Color.fromARGB(255, 56, 26, 3)
                    : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon(
                //   icon,
                //   color: isSelected
                //       ? Theme.of(context).colorScheme.primary
                //       : Colors.grey.shade600,
                //   size: 28,
                // ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Color.fromARGB(255, 56, 26, 3)
                                  : Colors.grey.shade800,
                            ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? const Color.fromARGB(255, 56, 26, 3)
                      : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
