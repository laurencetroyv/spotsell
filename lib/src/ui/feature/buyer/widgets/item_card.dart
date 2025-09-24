import 'package:flutter/material.dart';

import 'package:spotsell/src/core/theme/app_color_schemes.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';

class ItemCard extends StatelessWidget {
  const ItemCard(this.item, {super.key});

  final Map<String, String> item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Image.network(
              'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?q=80&w=1375&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              fit: BoxFit.cover,
            ),
          ),

          // Item Details
          Expanded(
            flex: 2,
            child: ColoredBox(
              color: AppColorSchemes.primaryColor.withAlpha(50),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title']!,
                      style: ThemeUtils.getAdaptiveTextStyle(
                        context,
                        TextStyleType.body,
                      )?.copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          item['price']!,
                          style:
                              ThemeUtils.getAdaptiveTextStyle(
                                context,
                                TextStyleType.caption,
                              )?.copyWith(
                                color: ThemeUtils.getPrimaryColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          item['condition']!,
                          style:
                              ThemeUtils.getAdaptiveTextStyle(
                                context,
                                TextStyleType.caption,
                              )?.copyWith(
                                color: Colors.green.shade600,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            ThemeUtils.getAdaptiveIcon(AdaptiveIcon.profile),
                            size: 8,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item['seller']!,
                            style:
                                ThemeUtils.getAdaptiveTextStyle(
                                  context,
                                  TextStyleType.caption,
                                )?.copyWith(
                                  color: ThemeUtils.getTextColor(
                                    context,
                                  ).withValues(alpha: 0.6),
                                  fontSize: 10,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
