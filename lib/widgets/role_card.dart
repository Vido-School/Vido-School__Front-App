import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RoleCardWidget extends StatelessWidget {
  final Map<String, dynamic> role;
  final double scale;

  const RoleCardWidget({
    super.key,
    required this.role,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: role["color"].withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 7),
            ),
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(25),
                ),
                child: Opacity(
                  opacity: 0.05,
                  child: Icon(
                    role["icon"],
                    size: 120,
                    color: role["color"],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRect(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: role["iconBackgroundColor"],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        role["icon"],
                        size: 30,
                        color: role["color"],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      role["title"],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: role["color"],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      role["description"],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: (role["features"] as List<Map<String, dynamic>>)
                            .map((feature) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    feature["icon"],
                                    size: 16,
                                    color: role["color"],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    feature["text"],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary.withOpacity(0.7),
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}