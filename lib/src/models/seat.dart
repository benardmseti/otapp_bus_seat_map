import 'package:flutter/foundation.dart';

/// The type of element in a seat map position
enum SeatElementType {
  /// A regular bookable seat
  seat,

  /// An empty space (no seat, not aisle)
  empty,

  /// An aisle/walkway
  aisle,

  /// A door element
  door,

  /// A toilet/WC element
  toilet,

  /// A stairs element (for double-decker)
  stairs,

  /// Driver position
  driver,

  /// A custom special element
  custom,
}

/// The current status of a seat
enum SeatStatus {
  /// Seat is available for selection
  available,

  /// Seat has been booked by someone else
  booked,

  /// Seat is currently selected by the user
  selected,

  /// Seat is being processed (held temporarily)
  processing,

  /// Seat is blocked/disabled
  blocked,
}

/// Represents a single element in the seat map
@immutable
class SeatElement {
  /// Unique identifier for this seat (e.g., "1A", "L-3-1-10")
  final String? id;

  /// The type of this element
  final SeatElementType type;

  /// Current status (only relevant for seat type)
  final SeatStatus status;

  /// Row index in the layout (0-based)
  final int rowIndex;

  /// Column index in the layout (0-based)
  final int columnIndex;

  /// Display label for the seat (e.g., "1", "A1", "10")
  final String? label;

  /// Price for this seat (if applicable)
  final double? price;

  /// Category/type name (e.g., "VIP", "Standard", "Premium")
  final String? category;

  /// The original raw code from CSV (e.g., "1A", "0", "@")
  final String rawCode;

  /// Any additional custom data
  final Map<String, dynamic>? metadata;

  const SeatElement({
    this.id,
    required this.type,
    this.status = SeatStatus.available,
    required this.rowIndex,
    required this.columnIndex,
    this.label,
    this.price,
    this.category,
    required this.rawCode,
    this.metadata,
  });

  /// Creates a copy with updated fields
  SeatElement copyWith({
    String? id,
    SeatElementType? type,
    SeatStatus? status,
    int? rowIndex,
    int? columnIndex,
    String? label,
    double? price,
    String? category,
    String? rawCode,
    Map<String, dynamic>? metadata,
  }) {
    return SeatElement(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      rowIndex: rowIndex ?? this.rowIndex,
      columnIndex: columnIndex ?? this.columnIndex,
      label: label ?? this.label,
      price: price ?? this.price,
      category: category ?? this.category,
      rawCode: rawCode ?? this.rawCode,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Whether this element is a bookable seat
  bool get isSeat => type == SeatElementType.seat;

  /// Whether this element is an empty space or aisle
  bool get isEmpty => type == SeatElementType.empty || type == SeatElementType.aisle;

  /// Whether this seat can be selected (available seats only)
  bool get isSelectable => isSeat && status == SeatStatus.available;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeatElement &&
        other.id == id &&
        other.type == type &&
        other.rowIndex == rowIndex &&
        other.columnIndex == columnIndex;
  }

  @override
  int get hashCode =>
      id.hashCode ^ type.hashCode ^ rowIndex.hashCode ^ columnIndex.hashCode;

  @override
  String toString() =>
      'SeatElement(id: $id, type: $type, status: $status, row: $rowIndex, col: $columnIndex)';
}

/// Represents a selected seat with booking info
@immutable
class SelectedSeat {
  final String id;
  final String label;
  final double price;
  final String? category;
  final int rowIndex;
  final int columnIndex;

  const SelectedSeat({
    required this.id,
    required this.label,
    required this.price,
    this.category,
    required this.rowIndex,
    required this.columnIndex,
  });

  factory SelectedSeat.fromElement(SeatElement element) {
    return SelectedSeat(
      id: element.id ?? element.rawCode,
      label: element.label ?? element.rawCode,
      price: element.price ?? 0,
      category: element.category,
      rowIndex: element.rowIndex,
      columnIndex: element.columnIndex,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectedSeat && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
