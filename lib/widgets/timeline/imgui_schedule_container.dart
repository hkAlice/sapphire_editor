import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImGuiScheduleContainer extends StatelessWidget {
  final Widget title;
  final Widget subtitle;
  final String trailingText;
  final Widget child;
  final VoidCallback onAddTap;
  final String addButtonText;

  const ImGuiScheduleContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailingText,
    required this.child,
    required this.onAddTap,
    this.addButtonText = '+ Add new timepoint',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border.all(color: const Color(0xFF333333), width: 1.0),
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
          minTileHeight: 40.0,
          initiallyExpanded: true,
          title: DefaultTextStyle(
            style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600, color: Colors.white),
            child: title,
          ),
          subtitle: DefaultTextStyle(
            style: GoogleFonts.lilex(fontSize: 12.0, color: Colors.grey[400]),
            child: subtitle,
          ),
          trailing: SizedBox(
            width: 48.0,
            child: Text(
              trailingText,
              style: GoogleFonts.lilex(
                fontSize: 12.0,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          children: [
            child,
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A2A),
                border: Border(
                  top: BorderSide(color: Color(0xFF333333), width: 1.0),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAddTap,
                  hoverColor: const Color(0xFF3A3A3A),
                  splashColor: const Color(0xFF4A4A4A),
                  child: Container(
                    height: 28.0,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      addButtonText,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
