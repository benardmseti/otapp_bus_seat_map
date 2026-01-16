import 'seat.dart';
import 'seat_layout_config.dart';

/// Represents a complete seat layout with parsed rows and columns
class SeatLayout {
  /// All rows of seat elements
  final List<List<SeatElement>> rows;

  /// Configuration used to parse this layout
  final SeatLayoutConfig config;

  /// Maximum number of columns across all rows (for consistent rendering)
  final int maxColumns;

  /// Detected aisle column indices (columns that are consistently empty)
  final Set<int> aisleColumns;

  /// Number of seats on the left side of the aisle
  final int leftSideCount;

  /// Number of seats on the right side of the aisle
  final int rightSideCount;

  /// Total number of bookable seats
  final int totalSeats;

  /// Raw row data (for reference)
  final List<String> rawRows;

  SeatLayout._({
    required this.rows,
    required this.config,
    required this.maxColumns,
    required this.aisleColumns,
    required this.leftSideCount,
    required this.rightSideCount,
    required this.totalSeats,
    required this.rawRows,
  });

  /// Create a SeatLayout from a list of CSV row strings
  ///
  /// Example:
  /// ```dart
  /// final layout = SeatLayout.fromCsvRows([
  ///   '1A,1B,0,1C,1D',
  ///   '2A,2B,0,2C,2D',
  ///   '@,0,0,3C,3D',  // Door on left
  ///   '4A,4B,0,4C,4D',
  /// ]);
  /// ```
  factory SeatLayout.fromCsvRows(
    List<String> rowStrings, {
    SeatLayoutConfig? config,
    Map<String, SeatStatus>? seatStatuses,
    Map<String, dynamic>? metadata,
  }) {
    final cfg = config ?? const SeatLayoutConfig();
    final statuses = seatStatuses ?? {};

    // Parse all rows into raw codes
    final List<List<String>> rawParsed = [];
    int maxCols = 0;

    for (final rowStr in rowStrings) {
      if (rowStr.trim().isEmpty) continue;
      final codes = rowStr.split(cfg.delimiter);
      rawParsed.add(codes);
      if (codes.length > maxCols) maxCols = codes.length;
    }

    // Detect aisle columns (columns that are consistently empty/0)
    final Set<int> aisleColumns = {};
    if (cfg.autoDetectAisle && rawParsed.isNotEmpty) {
      // Check each column position
      for (int col = 0; col < maxCols; col++) {
        bool isAisle = true;
        int emptyCount = 0;
        int totalRows = 0;

        for (final row in rawParsed) {
          if (col >= row.length) continue;
          totalRows++;
          final code = row[col].trim();

          // Check if this position is empty (potential aisle)
          if (cfg.emptyMarkers.contains(code)) {
            emptyCount++;
          } else if (!cfg.isSpecial(code)) {
            // Has a seat, not an aisle column
            isAisle = false;
            break;
          }
        }

        // Column is aisle if it's empty in most rows (allowing for some special elements)
        if (isAisle && emptyCount > totalRows * 0.5) {
          aisleColumns.add(col);
        }
      }
    }

    // Calculate left/right seat counts
    int leftCount = 0;
    int rightCount = 0;
    if (aisleColumns.isNotEmpty) {
      final firstAisle = aisleColumns.reduce((a, b) => a < b ? a : b);
      leftCount = firstAisle;
      rightCount = maxCols - firstAisle - aisleColumns.length;
    } else {
      // No aisle detected, all seats are "left"
      leftCount = maxCols;
    }

    // Convert raw codes to SeatElements
    final List<List<SeatElement>> rows = [];
    int totalSeats = 0;

    for (int rowIdx = 0; rowIdx < rawParsed.length; rowIdx++) {
      final rawRow = rawParsed[rowIdx];
      final List<SeatElement> elementRow = [];

      for (int colIdx = 0; colIdx < rawRow.length; colIdx++) {
        final code = rawRow[colIdx].trim();
        final isAisleCol = aisleColumns.contains(colIdx);

        SeatElementType type;
        if (isAisleCol && cfg.emptyMarkers.contains(code)) {
          type = SeatElementType.aisle;
        } else {
          type = cfg.getElementType(code);
        }

        final isSeat = type == SeatElementType.seat;
        if (isSeat) totalSeats++;

        final category = isSeat ? cfg.getCategory(code, metadata) : null;

        final element = SeatElement(
          id: isSeat ? code : null,
          type: type,
          status: isSeat ? (statuses[code] ?? SeatStatus.available) : SeatStatus.available,
          rowIndex: rowIdx,
          columnIndex: colIdx,
          label: isSeat ? cfg.getLabel(code) : null,
          price: isSeat ? cfg.getPrice(code, category, metadata) : null,
          category: category,
          rawCode: code,
          metadata: metadata,
        );

        elementRow.add(element);
      }

      // Pad row to maxCols for consistent rendering
      while (elementRow.length < maxCols) {
        elementRow.add(SeatElement(
          type: SeatElementType.empty,
          rowIndex: rowIdx,
          columnIndex: elementRow.length,
          rawCode: '',
        ));
      }

      rows.add(elementRow);
    }

    return SeatLayout._(
      rows: rows,
      config: cfg,
      maxColumns: maxCols,
      aisleColumns: aisleColumns,
      leftSideCount: leftCount,
      rightSideCount: rightCount,
      totalSeats: totalSeats,
      rawRows: rowStrings,
    );
  }

  /// Create a SeatLayout from a JSON structure (like the API response)
  ///
  /// Supports formats:
  /// - List of maps: `[{"seat_row1": "1A,1B,0,1C"}, {"seat_row2": "2A,2B,0,2C"}]`
  /// - Map with row keys: `{"seat_row1": "1A,1B,0,1C", "seat_row2": "2A,2B,0,2C"}`
  factory SeatLayout.fromJson(
    dynamic json, {
    SeatLayoutConfig? config,
    Map<String, SeatStatus>? seatStatuses,
    Map<String, dynamic>? metadata,
    int maxRows = 20,
  }) {
    final List<String> rowStrings = [];

    if (json is List) {
      // Format: [{"seat_row1": "1A,1B,0,1C"}, ...]
      for (final item in json) {
        if (item is Map) {
          final value = item.values.first?.toString() ?? '';
          if (value.isNotEmpty && value != 'null') {
            rowStrings.add(value);
          }
        }
      }
    } else if (json is Map) {
      // Format: {"seat_row1": "1A,1B,0,1C", "seat_row2": "2A,2B,0,2C"}
      // Try both naming conventions
      for (int i = 1; i <= maxRows; i++) {
        String? rowValue;

        // Try different key formats
        final keys = ['seat_row$i', 'SeatRow$i', 'row$i', 'Row$i'];
        for (final key in keys) {
          if (json.containsKey(key)) {
            rowValue = json[key]?.toString();
            break;
          }
        }

        if (rowValue != null && rowValue.isNotEmpty && rowValue != 'null') {
          rowStrings.add(rowValue);
        }
      }
    }

    return SeatLayout.fromCsvRows(
      rowStrings,
      config: config,
      seatStatuses: seatStatuses,
      metadata: metadata,
    );
  }

  /// Create a SeatLayout from available/booked seat lists
  ///
  /// Useful when API provides seat status separately
  factory SeatLayout.fromCsvRowsWithStatus(
    List<String> rowStrings, {
    SeatLayoutConfig? config,
    String availableSeats = '',
    String bookedSeats = '',
    String processingSeats = '',
    String blockedSeats = '',
    Map<String, dynamic>? metadata,
  }) {
    final Map<String, SeatStatus> statuses = {};

    // Parse status lists
    for (final seat in availableSeats.split(',')) {
      if (seat.trim().isNotEmpty) {
        statuses[seat.trim()] = SeatStatus.available;
      }
    }
    for (final seat in bookedSeats.split(',')) {
      if (seat.trim().isNotEmpty) {
        statuses[seat.trim()] = SeatStatus.booked;
      }
    }
    for (final seat in processingSeats.split(',')) {
      if (seat.trim().isNotEmpty) {
        statuses[seat.trim()] = SeatStatus.processing;
      }
    }
    for (final seat in blockedSeats.split(',')) {
      if (seat.trim().isNotEmpty) {
        statuses[seat.trim()] = SeatStatus.blocked;
      }
    }

    return SeatLayout.fromCsvRows(
      rowStrings,
      config: config,
      seatStatuses: statuses,
      metadata: metadata,
    );
  }

  /// Get a seat element by its ID
  SeatElement? getSeatById(String id) {
    for (final row in rows) {
      for (final element in row) {
        if (element.id == id) return element;
      }
    }
    return null;
  }

  /// Get all bookable seats
  List<SeatElement> get allSeats {
    return rows
        .expand((row) => row)
        .where((e) => e.type == SeatElementType.seat)
        .toList();
  }

  /// Get all available (selectable) seats
  List<SeatElement> get availableSeats {
    return allSeats.where((e) => e.status == SeatStatus.available).toList();
  }

  /// Create a copy of this layout with updated seat statuses
  SeatLayout withUpdatedStatuses(Map<String, SeatStatus> newStatuses) {
    final List<List<SeatElement>> updatedRows = [];

    for (final row in rows) {
      final updatedRow = row.map((element) {
        if (element.isSeat && element.id != null && newStatuses.containsKey(element.id)) {
          return element.copyWith(status: newStatuses[element.id]);
        }
        return element;
      }).toList();
      updatedRows.add(updatedRow);
    }

    return SeatLayout._(
      rows: updatedRows,
      config: config,
      maxColumns: maxColumns,
      aisleColumns: aisleColumns,
      leftSideCount: leftSideCount,
      rightSideCount: rightSideCount,
      totalSeats: totalSeats,
      rawRows: rawRows,
    );
  }

  /// Create a copy with a specific seat's status updated
  SeatLayout withSeatStatus(String seatId, SeatStatus status) {
    return withUpdatedStatuses({seatId: status});
  }

  /// Create a SeatLayout from full Otapp Services API response
  ///
  /// This parses the complete API response including:
  /// - lower_seat_map / upper_seat_map
  /// - available_seats, process_seats
  /// - seat_types with fares
  /// - is_right_hand_drive (for driver positioning)
  /// - fare (default fare)
  ///
  /// Example:
  /// ```dart
  /// final layout = SeatLayout.fromApiResponse(apiResponse);
  /// ```
  factory SeatLayout.fromApiResponse(
    Map<String, dynamic> apiResponse, {
    bool includeDriveRow = true,
    SeatLayoutConfig? baseConfig,
  }) {
    // Extract data from API response
    final lowerSeatMap = apiResponse['lower_seat_map'] as List? ?? [];
    final availableSeats = apiResponse['available_seats']?.toString() ?? '';
    final processSeats = apiResponse['process_seats']?.toString() ?? '';
    final reserveHoldSeats = apiResponse['reserve_hold_seats']?.toString() ?? '';
    final seatTypes = apiResponse['seat_types'] as List? ?? [];
    final defaultFare = apiResponse['fare'] as List? ?? [];
    final isRightHandDrive = _parseBool(apiResponse['is_right_hand_drive']);

    // Parse default price
    double defaultPrice = 0;
    if (defaultFare.isNotEmpty && defaultFare[0]['fare'] != null) {
      defaultPrice = _parsePrice(defaultFare[0]['fare']);
    }

    // Build seat type lookup: seatCode -> {category, price}
    final Map<String, Map<String, dynamic>> seatTypeMap = {};
    for (final seatType in seatTypes) {
      final typeName = seatType['seat_type_name']?.toString() ?? '';
      final seats = seatType['seats']?.toString() ?? '';
      final fares = seatType['fare'] as List? ?? [];

      double typePrice = defaultPrice;
      if (fares.isNotEmpty && fares[0]['fare'] != null) {
        typePrice = _parsePrice(fares[0]['fare']);
      }

      for (final seatCode in seats.split(',')) {
        final code = seatCode.trim();
        if (code.isNotEmpty) {
          seatTypeMap[code] = {
            'category': typeName,
            'price': typePrice,
          };
        }
      }
    }

    // Parse row strings from lower_seat_map
    final List<String> rowStrings = [];
    for (final item in lowerSeatMap) {
      if (item is Map) {
        final value = item.values.first?.toString() ?? '';
        if (value.isNotEmpty && value != 'null') {
          rowStrings.add(value);
        }
      }
    }

    // Determine maxCols from rows
    int maxCols = 0;
    for (final rowStr in rowStrings) {
      final cols = rowStr.split(',').length;
      if (cols > maxCols) maxCols = cols;
    }

    // Create config with price/category resolvers
    final config = SeatLayoutConfig(
      emptyMarkers: baseConfig?.emptyMarkers ?? const {'0', ''},
      doorMarker: baseConfig?.doorMarker ?? '@',
      toiletMarker: baseConfig?.toiletMarker ?? '*',
      stairsMarker: baseConfig?.stairsMarker ?? '#',
      autoDetectAisle: baseConfig?.autoDetectAisle ?? true,
      defaultPrice: defaultPrice,
      labelExtractor: baseConfig?.labelExtractor ?? (code) {
        final parts = code.split('-');
        return parts.length > 1 ? parts.last : code;
      },
      categoryResolver: (code, metadata) {
        return seatTypeMap[code]?['category'];
      },
      priceResolver: (code, category, metadata) {
        return seatTypeMap[code]?['price'] ?? defaultPrice;
      },
    );

    // Build seat statuses
    final Map<String, SeatStatus> statuses = {};

    // All seats in available_seats are available
    for (final seat in availableSeats.split(',')) {
      final code = seat.trim();
      if (code.isNotEmpty) {
        statuses[code] = SeatStatus.available;
      }
    }

    // Process seats override
    for (final seat in processSeats.split(',')) {
      final code = seat.trim();
      if (code.isNotEmpty) {
        statuses[code] = SeatStatus.processing;
      }
    }

    // Reserve hold seats are blocked
    for (final seat in reserveHoldSeats.split(',')) {
      final code = seat.trim();
      if (code.isNotEmpty) {
        statuses[code] = SeatStatus.blocked;
      }
    }

    // Add driver row if requested
    List<String> finalRowStrings = rowStrings;
    if (includeDriveRow && maxCols > 0) {
      // Create driver row: empty except for driver position
      final List<String> driverRowCodes = List.filled(maxCols, '0');
      if (isRightHandDrive) {
        driverRowCodes[maxCols - 1] = 'D'; // Driver on right
      } else {
        driverRowCodes[0] = 'D'; // Driver on left
      }
      finalRowStrings = [driverRowCodes.join(','), ...rowStrings];
    }

    // Use the base fromCsvRows but with our custom config and statuses
    final cfg = config;

    // Parse all rows into raw codes
    final List<List<String>> rawParsed = [];
    maxCols = 0;

    for (final rowStr in finalRowStrings) {
      if (rowStr.trim().isEmpty) continue;
      final codes = rowStr.split(cfg.delimiter);
      rawParsed.add(codes);
      if (codes.length > maxCols) maxCols = codes.length;
    }

    // Detect aisle columns
    final Set<int> aisleColumns = {};
    if (cfg.autoDetectAisle && rawParsed.isNotEmpty) {
      for (int col = 0; col < maxCols; col++) {
        bool isAisle = true;
        int emptyCount = 0;
        int totalRows = 0;

        for (final row in rawParsed) {
          if (col >= row.length) continue;
          totalRows++;
          final code = row[col].trim();

          if (cfg.emptyMarkers.contains(code)) {
            emptyCount++;
          } else if (!cfg.isSpecial(code) && code != 'D') {
            isAisle = false;
            break;
          }
        }

        if (isAisle && emptyCount > totalRows * 0.5) {
          aisleColumns.add(col);
        }
      }
    }

    // Calculate left/right seat counts
    int leftCount = 0;
    int rightCount = 0;
    if (aisleColumns.isNotEmpty) {
      final firstAisle = aisleColumns.reduce((a, b) => a < b ? a : b);
      leftCount = firstAisle;
      rightCount = maxCols - firstAisle - aisleColumns.length;
    } else {
      leftCount = maxCols;
    }

    // Convert raw codes to SeatElements
    final List<List<SeatElement>> rows = [];
    int totalSeats = 0;

    for (int rowIdx = 0; rowIdx < rawParsed.length; rowIdx++) {
      final rawRow = rawParsed[rowIdx];
      final List<SeatElement> elementRow = [];

      for (int colIdx = 0; colIdx < maxCols; colIdx++) {
        final code = colIdx < rawRow.length ? rawRow[colIdx].trim() : '';
        final isAisleCol = aisleColumns.contains(colIdx);

        SeatElementType type;
        if (code == 'D') {
          type = SeatElementType.driver;
        } else if (isAisleCol && cfg.emptyMarkers.contains(code)) {
          type = SeatElementType.aisle;
        } else {
          type = cfg.getElementType(code);
        }

        final isSeat = type == SeatElementType.seat;
        if (isSeat) totalSeats++;

        String? category;
        double? price;

        if (isSeat) {
          category = seatTypeMap[code]?['category'];
          price = seatTypeMap[code]?['price'] ?? defaultPrice;
        }

        // Determine status - if not in available list and is a seat, it's booked
        SeatStatus status = SeatStatus.available;
        if (isSeat) {
          if (statuses.containsKey(code)) {
            status = statuses[code]!;
          } else {
            // Not in available list = booked
            status = SeatStatus.booked;
          }
        }

        final element = SeatElement(
          id: isSeat ? code : null,
          type: type,
          status: status,
          rowIndex: rowIdx,
          columnIndex: colIdx,
          label: isSeat ? cfg.getLabel(code) : null,
          price: price,
          category: category,
          rawCode: code,
        );

        elementRow.add(element);
      }

      // Pad row to maxCols for consistent rendering
      while (elementRow.length < maxCols) {
        elementRow.add(SeatElement(
          type: SeatElementType.empty,
          rowIndex: rowIdx,
          columnIndex: elementRow.length,
          rawCode: '',
        ));
      }

      rows.add(elementRow);
    }

    return SeatLayout._(
      rows: rows,
      config: cfg,
      maxColumns: maxCols,
      aisleColumns: aisleColumns,
      leftSideCount: leftCount,
      rightSideCount: rightCount,
      totalSeats: totalSeats,
      rawRows: finalRowStrings,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0;
    try {
      final cleaned = price.toString().replaceAll(',', '').replaceAll(' ', '');
      return double.parse(cleaned);
    } catch (e) {
      return 0;
    }
  }

  @override
  String toString() {
    return 'SeatLayout(rows: ${rows.length}, cols: $maxColumns, seats: $totalSeats, aisles: $aisleColumns)';
  }
}
