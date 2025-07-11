import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

class LanguageOption extends StatelessWidget {
  final String flagCode;
  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageOption({
    super.key,
    required this.flagCode,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tertiaryColor = Theme.of(context).colorScheme.tertiary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border(
                  top: BorderSide(width: 2, color: tertiaryColor),
                  left: BorderSide(width: 2, color: tertiaryColor),
                  right: BorderSide(width: 2, color: tertiaryColor),
                  bottom: BorderSide(width: 4, color: tertiaryColor),
                )
              : null,
        ),
        padding: isSelected
            ? const EdgeInsets.fromLTRB(18, 13, 18, 11)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            CountryFlag.fromCountryCode(
              flagCode,
              height: 30,
              width: 40,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                language,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}