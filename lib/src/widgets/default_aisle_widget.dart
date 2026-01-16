import 'package:flutter/material.dart';

/// Default widget for aisle/walkway display
class DefaultAisleWidget extends StatelessWidget {
  final double size;
  final bool showLabel;
  final String label;
  final Color? labelColor;
  final double labelFontSize;
  final bool vertical;

  const DefaultAisleWidget({
    super.key,
    this.size = 50,
    this.showLabel = true,
    this.label = 'AISLE',
    this.labelColor,
    this.labelFontSize = 8,
    this.vertical = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: showLabel
            ? RotatedBox(
                quarterTurns: vertical ? 1 : 0,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    color: labelColor ?? Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : null,
      ),
    );
  }
}

/// A spacer widget for empty positions (no label)
class EmptySpaceWidget extends StatelessWidget {
  final double size;

  const EmptySpaceWidget({
    super.key,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
    );
  }
}
