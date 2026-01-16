import 'package:flutter/material.dart';
import '../models/seat.dart';

/// Default seat widget with common styling
class DefaultSeatWidget extends StatelessWidget {
  final SeatElement seat;
  final bool isSelected;
  final double size;
  final VoidCallback? onTap;

  /// Colors for different seat statuses
  final Color? availableColor;
  final Color? selectedColor;
  final Color? bookedColor;
  final Color? processingColor;
  final Color? blockedColor;

  /// Border radius
  final double borderRadius;

  /// Whether to show the seat label
  final bool showLabel;

  /// Whether to show the category badge
  final bool showCategory;

  const DefaultSeatWidget({
    super.key,
    required this.seat,
    this.isSelected = false,
    this.size = 50,
    this.onTap,
    this.availableColor,
    this.selectedColor,
    this.bookedColor,
    this.processingColor,
    this.blockedColor,
    this.borderRadius = 8,
    this.showLabel = true,
    this.showCategory = true,
  });

  Color _getSeatColor(BuildContext context) {
    if (isSelected) {
      return selectedColor ?? Colors.blue.shade600;
    }

    switch (seat.status) {
      case SeatStatus.available:
        return availableColor ?? Colors.white;
      case SeatStatus.booked:
        return bookedColor ?? Colors.grey.shade400;
      case SeatStatus.selected:
        return selectedColor ?? Colors.blue.shade600;
      case SeatStatus.processing:
        return processingColor ?? Colors.orange.shade300;
      case SeatStatus.blocked:
        return blockedColor ?? Colors.grey.shade600;
    }
  }

  Color _getTextColor(BuildContext context) {
    if (isSelected || seat.status == SeatStatus.selected) {
      return Colors.white;
    }
    if (seat.status == SeatStatus.booked || seat.status == SeatStatus.blocked) {
      return Colors.white;
    }
    if (seat.status == SeatStatus.processing) {
      return Colors.white;
    }
    return Colors.black87;
  }

  bool _isVip() {
    final category = seat.category?.toLowerCase() ?? '';
    return category.contains('vip');
  }

  bool _isVvip() {
    final category = seat.category?.toLowerCase() ?? '';
    return category.contains('vvip') || category.contains('v.v.i.p');
  }

  @override
  Widget build(BuildContext context) {
    final seatColor = _getSeatColor(context);
    final textColor = _getTextColor(context);
    final isVip = _isVip();
    final isVvip = _isVvip();

    return GestureDetector(
      onTap: seat.isSelectable ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: seatColor == Colors.white
                ? Colors.grey.shade300
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // VIP indicators
            if (showCategory && isVvip) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: textColor.withValues(alpha: 0.7), size: 10),
                  Icon(Icons.star, color: textColor.withValues(alpha: 0.7), size: 10),
                ],
              ),
            ] else if (showCategory && isVip) ...[
              Icon(Icons.star, color: textColor.withValues(alpha: 0.7), size: 12),
            ],

            // Seat label
            if (showLabel && seat.label != null)
              Text(
                seat.label!,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: size * 0.28,
                ),
              ),

            // Category label
            if (showCategory && (isVip || isVvip))
              Text(
                isVvip ? 'VVIP' : 'VIP',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 9,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A more customizable seat widget using a builder pattern
class CustomizableSeatWidget extends StatelessWidget {
  final SeatElement seat;
  final bool isSelected;
  final double size;
  final VoidCallback? onTap;

  /// Builder for the seat content
  final Widget Function(
    BuildContext context,
    SeatElement seat,
    bool isSelected,
    Color backgroundColor,
    Color textColor,
  )? contentBuilder;

  /// Function to determine background color
  final Color Function(SeatElement seat, bool isSelected)? colorResolver;

  const CustomizableSeatWidget({
    super.key,
    required this.seat,
    this.isSelected = false,
    this.size = 50,
    this.onTap,
    this.contentBuilder,
    this.colorResolver,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = colorResolver?.call(seat, isSelected) ??
        (isSelected ? Colors.blue : Colors.white);
    final textColor = _contrastColor(bgColor);

    return GestureDetector(
      onTap: seat.isSelectable ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: bgColor == Colors.white ? Colors.grey.shade300 : Colors.transparent,
          ),
        ),
        child: contentBuilder != null
            ? contentBuilder!(context, seat, isSelected, bgColor, textColor)
            : Center(
                child: Text(
                  seat.label ?? seat.rawCode,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                ),
              ),
      ),
    );
  }

  Color _contrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }
}
