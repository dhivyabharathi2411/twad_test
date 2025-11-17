import 'package:flutter/material.dart';
import 'package:twad/extensions/translation_extensions.dart';

class Buildfooter extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const Buildfooter({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  void _handleTap(BuildContext context, int index) {
    onTap(index);
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;

    if (isSelected) {
      return GestureDetector(
        onTap: () => _handleTap(context, index),
        behavior: HitTestBehavior.opaque, // This makes the entire area tappable
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFe4e9f6), Color(0xE6FFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24939393),
                offset: Offset(0, -5),
                blurRadius: 30,
              ),
            ],
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                ).createShader(bounds),
                child: Icon(icon, size: 20),
              ),
              const SizedBox(width: 6),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                ).createShader(bounds),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => _handleTap(context, index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Icon(icon, size: 24, color: const Color(0xFF999999)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color.fromRGBO(255, 255, 255, 0.9)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24939393),
            blurRadius: 30,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(
            context: context,
            index: 0,
            icon: Icons.dashboard_outlined,
            label: context.tr.dashboard,
          ),
          _buildNavItem(
            context: context,
            index: 1,
            icon: Icons.assignment_outlined,
            label: context.tr.grievance,
          ),
          _buildNavItem(
            context: context,
            index: 2,
            icon: Icons.person_outline,
            label: context.tr.profilePageTitle,
          ),
        ],
      ),
    );
  }
}
