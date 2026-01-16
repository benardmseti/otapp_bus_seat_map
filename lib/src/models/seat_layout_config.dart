import 'seat.dart';

/// Configuration for parsing seat layout data
class SeatLayoutConfig {
  /// Marker codes that indicate an empty space (no seat)
  /// Default: ['0', '']
  final Set<String> emptyMarkers;

  /// Marker codes that indicate an aisle
  /// Default: ['0'] - same as empty by default, use aisleDetection for smart detection
  final Set<String> aisleMarkers;

  /// Marker code for door elements
  /// Default: '@'
  final String doorMarker;

  /// Marker code for toilet/WC elements
  /// Default: '*'
  final String toiletMarker;

  /// Marker code for stairs (double-decker)
  /// Default: '#'
  final String stairsMarker;

  /// Custom markers mapped to SeatElementType
  final Map<String, SeatElementType> customMarkers;

  /// Whether to automatically detect aisle positions
  /// When true, analyzes the layout to find consistent empty columns that act as aisles
  final bool autoDetectAisle;

  /// The delimiter used to separate seats in a row string
  /// Default: ','
  final String delimiter;

  /// Function to extract the display label from a seat code
  /// Default: extracts last segment after '-' (e.g., "L-3-1-10" -> "10")
  final String Function(String code)? labelExtractor;

  /// Function to determine seat category from code
  final String? Function(String code, Map<String, dynamic>? metadata)? categoryResolver;

  /// Function to determine seat price from code and category
  final double Function(String code, String? category, Map<String, dynamic>? metadata)? priceResolver;

  /// Default price if priceResolver is not provided
  final double defaultPrice;

  const SeatLayoutConfig({
    this.emptyMarkers = const {'0', ''},
    this.aisleMarkers = const {},
    this.doorMarker = '@',
    this.toiletMarker = '*',
    this.stairsMarker = '#',
    this.customMarkers = const {},
    this.autoDetectAisle = true,
    this.delimiter = ',',
    this.labelExtractor,
    this.categoryResolver,
    this.priceResolver,
    this.defaultPrice = 0,
  });

  /// Creates a config for bus seat maps (common format)
  factory SeatLayoutConfig.bus({
    double defaultPrice = 0,
    String? Function(String code, Map<String, dynamic>? metadata)? categoryResolver,
    double Function(String code, String? category, Map<String, dynamic>? metadata)? priceResolver,
  }) {
    return SeatLayoutConfig(
      emptyMarkers: {'0', ''},
      doorMarker: '@',
      toiletMarker: '*',
      stairsMarker: '#',
      autoDetectAisle: true,
      defaultPrice: defaultPrice,
      categoryResolver: categoryResolver,
      priceResolver: priceResolver,
      labelExtractor: (code) {
        // Extract seat number: "L-3-1-10" -> "10", "1A" -> "1A"
        final parts = code.split('-');
        return parts.length > 1 ? parts.last : code;
      },
    );
  }

  /// Creates a config for cinema/theater seat maps
  factory SeatLayoutConfig.cinema({
    double defaultPrice = 0,
    String? Function(String code, Map<String, dynamic>? metadata)? categoryResolver,
    double Function(String code, String? category, Map<String, dynamic>? metadata)? priceResolver,
  }) {
    return SeatLayoutConfig(
      emptyMarkers: {'', ' '},
      autoDetectAisle: true,
      defaultPrice: defaultPrice,
      categoryResolver: categoryResolver,
      priceResolver: priceResolver,
      labelExtractor: (code) => code, // Usually just "A1", "B2", etc.
    );
  }

  /// Check if a code represents an empty space
  bool isEmpty(String code) {
    final trimmed = code.trim();
    return emptyMarkers.contains(trimmed) || aisleMarkers.contains(trimmed);
  }

  /// Check if a code represents a special element
  bool isSpecial(String code) {
    final trimmed = code.trim();
    return trimmed == doorMarker ||
        trimmed == toiletMarker ||
        trimmed == stairsMarker ||
        customMarkers.containsKey(trimmed);
  }

  /// Get the element type for a code
  SeatElementType getElementType(String code) {
    final trimmed = code.trim();

    if (trimmed == doorMarker) return SeatElementType.door;
    if (trimmed == toiletMarker) return SeatElementType.toilet;
    if (trimmed == stairsMarker) return SeatElementType.stairs;
    if (customMarkers.containsKey(trimmed)) return customMarkers[trimmed]!;
    if (emptyMarkers.contains(trimmed)) return SeatElementType.empty;
    if (aisleMarkers.contains(trimmed)) return SeatElementType.aisle;

    return SeatElementType.seat;
  }

  /// Extract the display label for a seat code
  String getLabel(String code) {
    if (labelExtractor != null) {
      return labelExtractor!(code);
    }
    // Default: return the code as-is
    return code;
  }

  /// Get the category for a seat
  String? getCategory(String code, Map<String, dynamic>? metadata) {
    if (categoryResolver != null) {
      return categoryResolver!(code, metadata);
    }
    return null;
  }

  /// Get the price for a seat
  double getPrice(String code, String? category, Map<String, dynamic>? metadata) {
    if (priceResolver != null) {
      return priceResolver!(code, category, metadata);
    }
    return defaultPrice;
  }
}
