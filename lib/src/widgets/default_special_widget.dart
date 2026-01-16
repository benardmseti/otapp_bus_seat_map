import 'package:flutter/material.dart';
import '../models/seat.dart';

/// Default widget for special elements (door, toilet, stairs, etc.)
class DefaultSpecialWidget extends StatelessWidget {
  final SeatElement element;
  final double size;
  final double borderRadius;

  const DefaultSpecialWidget({
    super.key,
    required this.element,
    this.size = 50,
    this.borderRadius = 8,
  });

  IconData _getIcon() {
    switch (element.type) {
      case SeatElementType.door:
        return Icons.sensor_door_outlined;
      case SeatElementType.toilet:
        return Icons.wc_outlined;
      case SeatElementType.stairs:
        return Icons.stairs_outlined;
      case SeatElementType.driver:
        return Icons.airline_seat_recline_normal;
      case SeatElementType.custom:
        return Icons.square_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _getLabel() {
    switch (element.type) {
      case SeatElementType.door:
        return 'Door';
      case SeatElementType.toilet:
        return 'WC';
      case SeatElementType.stairs:
        return 'Stairs';
      case SeatElementType.driver:
        return 'Driver';
      case SeatElementType.custom:
        return element.rawCode;
      default:
        return '';
    }
  }

  Color _getBackgroundColor() {
    switch (element.type) {
      case SeatElementType.door:
        return Colors.lightBlue.shade50;
      case SeatElementType.toilet:
        return Colors.lightBlue.shade50;
      case SeatElementType.stairs:
        return Colors.amber.shade50;
      case SeatElementType.driver:
        return Colors.blue.shade700;
      case SeatElementType.custom:
        return Colors.grey.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getBorderColor() {
    switch (element.type) {
      case SeatElementType.door:
        return Colors.lightBlue.shade200;
      case SeatElementType.toilet:
        return Colors.lightBlue.shade200;
      case SeatElementType.stairs:
        return Colors.amber.shade200;
      case SeatElementType.driver:
        return Colors.blue.shade900;
      case SeatElementType.custom:
        return Colors.grey.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getIconColor() {
    switch (element.type) {
      case SeatElementType.door:
        return Colors.lightBlue.shade700;
      case SeatElementType.toilet:
        return Colors.lightBlue.shade700;
      case SeatElementType.stairs:
        return Colors.amber.shade700;
      case SeatElementType.driver:
        return Colors.white;
      case SeatElementType.custom:
        return Colors.grey.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(),
            size: size * 0.4,
          ),
          Text(
            _getLabel(),
            style: TextStyle(
              color: _getIconColor(),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for driver position
class DriverWidget extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final double borderRadius;

  const DriverWidget({
    super.key,
    this.size = 50,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue.shade700,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.airline_seat_recline_normal,
            color: iconColor ?? Colors.white,
            size: size * 0.4,
          ),
          Text(
            'Driver',
            style: TextStyle(
              color: iconColor ?? Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for steering wheel display
class SteeringWheelWidget extends StatelessWidget {
  final double size;
  final Color? color;

  const SteeringWheelWidget({
    super.key,
    this.size = 50,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Icon(
        Icons.trip_origin,
        color: color ?? Colors.grey.shade600,
        size: size * 0.6,
      ),
    );
  }
}
