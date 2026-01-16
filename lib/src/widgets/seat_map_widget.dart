import 'package:flutter/material.dart';
import '../models/seat.dart';
import '../models/seat_layout.dart';
import 'default_seat_widget.dart';
import 'default_aisle_widget.dart';
import 'default_special_widget.dart';

/// Callback when a seat is tapped
typedef SeatTapCallback = void Function(SeatElement seat);

/// Builder for custom seat widgets
typedef SeatWidgetBuilder = Widget Function(
  BuildContext context,
  SeatElement seat,
  bool isSelected,
);

/// Builder for aisle/empty space widgets
typedef AisleWidgetBuilder = Widget Function(
  BuildContext context,
  SeatElement element,
);

/// Builder for special elements (door, toilet, stairs, etc.)
typedef SpecialWidgetBuilder = Widget Function(
  BuildContext context,
  SeatElement element,
);

/// Builder for row labels (optional left side labels)
typedef RowLabelBuilder = Widget? Function(
  BuildContext context,
  int rowIndex,
  List<SeatElement> row,
);

/// A flexible, customizable seat map widget
class SeatMapWidget extends StatelessWidget {
  /// The seat layout to display
  final SeatLayout layout;

  /// Currently selected seats
  final List<SelectedSeat> selectedSeats;

  /// Callback when a seat is tapped
  final SeatTapCallback? onSeatTap;

  /// Custom builder for seat widgets
  final SeatWidgetBuilder? seatBuilder;

  /// Custom builder for aisle/empty widgets
  final AisleWidgetBuilder? aisleBuilder;

  /// Custom builder for special elements
  final SpecialWidgetBuilder? specialBuilder;

  /// Custom builder for row labels
  final RowLabelBuilder? rowLabelBuilder;

  /// Size of each seat cell (width and height)
  final double seatSize;

  /// Spacing between seats
  final double seatSpacing;

  /// Spacing between rows
  final double rowSpacing;

  /// Whether to show row labels on the left
  final bool showRowLabels;

  /// Width of row label area
  final double rowLabelWidth;

  /// Whether to enable InteractiveViewer for zoom/pan
  final bool enableZoom;

  /// Minimum scale for zoom
  final double minScale;

  /// Maximum scale for zoom
  final double maxScale;

  /// Padding around the seat map
  final EdgeInsets padding;

  /// Main axis alignment for rows
  final MainAxisAlignment rowAlignment;

  /// Cross axis alignment for the column
  final CrossAxisAlignment columnAlignment;

  const SeatMapWidget({
    super.key,
    required this.layout,
    this.selectedSeats = const [],
    this.onSeatTap,
    this.seatBuilder,
    this.aisleBuilder,
    this.specialBuilder,
    this.rowLabelBuilder,
    this.seatSize = 50,
    this.seatSpacing = 4,
    this.rowSpacing = 4,
    this.showRowLabels = false,
    this.rowLabelWidth = 30,
    this.enableZoom = false,
    this.minScale = 0.5,
    this.maxScale = 3.0,
    this.padding = const EdgeInsets.all(16),
    this.rowAlignment = MainAxisAlignment.center,
    this.columnAlignment = CrossAxisAlignment.center,
  });

  bool _isSelected(SeatElement seat) {
    return selectedSeats.any((s) => s.id == seat.id);
  }

  Widget _buildElement(BuildContext context, SeatElement element) {
    final isSelected = _isSelected(element);

    switch (element.type) {
      case SeatElementType.seat:
        if (seatBuilder != null) {
          return seatBuilder!(context, element, isSelected);
        }
        return DefaultSeatWidget(
          seat: element,
          isSelected: isSelected,
          size: seatSize,
          onTap: onSeatTap != null ? () => onSeatTap!(element) : null,
        );

      case SeatElementType.aisle:
        if (aisleBuilder != null) {
          return aisleBuilder!(context, element);
        }
        return DefaultAisleWidget(size: seatSize);

      case SeatElementType.empty:
        if (aisleBuilder != null) {
          return aisleBuilder!(context, element);
        }
        return SizedBox(
          width: seatSize + seatSpacing * 2,
          height: seatSize,
        );

      case SeatElementType.door:
      case SeatElementType.toilet:
      case SeatElementType.stairs:
      case SeatElementType.driver:
      case SeatElementType.custom:
        if (specialBuilder != null) {
          return specialBuilder!(context, element);
        }
        return DefaultSpecialWidget(
          element: element,
          size: seatSize,
        );
    }
  }

  Widget _buildRow(BuildContext context, int rowIndex, List<SeatElement> row) {
    final List<Widget> rowWidgets = [];

    // Add row label if enabled
    if (showRowLabels) {
      Widget? label;
      if (rowLabelBuilder != null) {
        label = rowLabelBuilder!(context, rowIndex, row);
      }
      label ??= SizedBox(
        width: rowLabelWidth,
        child: Center(
          child: Text(
            '${rowIndex + 1}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ),
      );
      rowWidgets.add(label);
    }

    // Add seat elements
    for (final element in row) {
      rowWidgets.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: seatSpacing / 2),
          child: _buildElement(context, element),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: rowSpacing / 2),
      child: Row(
        mainAxisAlignment: rowAlignment,
        mainAxisSize: MainAxisSize.min,
        children: rowWidgets,
      ),
    );
  }

  Widget _buildSeatMap(BuildContext context) {
    if (layout.rows.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No seat layout available',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: columnAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < layout.rows.length; i++)
            _buildRow(context, i, layout.rows[i]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seatMap = _buildSeatMap(context);

    if (enableZoom) {
      return InteractiveViewer(
        minScale: minScale,
        maxScale: maxScale,
        boundaryMargin: const EdgeInsets.all(20),
        constrained: false,
        child: seatMap,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: seatMap,
      ),
    );
  }
}

/// A convenience widget that manages seat selection state
class SeatMapController extends StatefulWidget {
  /// The seat layout to display
  final SeatLayout layout;

  /// Maximum number of seats that can be selected
  final int? maxSelection;

  /// Callback when selection changes
  final void Function(List<SelectedSeat> selectedSeats)? onSelectionChanged;

  /// Initial selection
  final List<SelectedSeat> initialSelection;

  /// Builder for the SeatMapWidget
  final Widget Function(
    BuildContext context,
    SeatLayout layout,
    List<SelectedSeat> selectedSeats,
    void Function(SeatElement seat) onSeatTap,
  ) builder;

  const SeatMapController({
    super.key,
    required this.layout,
    required this.builder,
    this.maxSelection,
    this.onSelectionChanged,
    this.initialSelection = const [],
  });

  @override
  State<SeatMapController> createState() => _SeatMapControllerState();
}

class _SeatMapControllerState extends State<SeatMapController> {
  late List<SelectedSeat> _selectedSeats;

  @override
  void initState() {
    super.initState();
    _selectedSeats = List.from(widget.initialSelection);
  }

  void _handleSeatTap(SeatElement seat) {
    if (!seat.isSelectable) return;

    setState(() {
      final existingIndex = _selectedSeats.indexWhere((s) => s.id == seat.id);

      if (existingIndex >= 0) {
        // Deselect
        _selectedSeats.removeAt(existingIndex);
      } else {
        // Check max selection
        if (widget.maxSelection != null &&
            _selectedSeats.length >= widget.maxSelection!) {
          return;
        }
        // Select
        _selectedSeats.add(SelectedSeat.fromElement(seat));
      }
    });

    widget.onSelectionChanged?.call(_selectedSeats);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      widget.layout,
      _selectedSeats,
      _handleSeatTap,
    );
  }
}
