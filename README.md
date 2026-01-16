# OTApp Bus Seat Map

A flexible, customizable seat map widget for Flutter. Perfect for bus, cinema, theater, and event seat selection.

## Features

- CSV-based seat layout parsing (simple API integration)
- Automatic aisle detection
- Support for special elements (doors, toilets, stairs)
- Customizable seat appearance
- VIP/category support
- Seat status management (available, booked, selected, processing)
- InteractiveViewer support for zoom/pan
- Fully customizable with builder patterns

## Installation

```yaml
dependencies:
  otapp_bus_seat_map:
    git:
      url: https://github.com/benardmseti/otapp_bus_seat_map.git
```

## Quick Start

### Basic Usage

```dart
import 'package:otapp_bus_seat_map/otapp_bus_seat_map.dart';

// Define your seat layout (CSV format)
final rows = [
  '1A,1B,0,1C,1D',  // 0 = aisle
  '2A,2B,0,2C,2D',
  '@,0,0,3C,3D',    // @ = door
  '4A,4B,0,4C,4D',
  '*,0,0,5C,5D',    // * = toilet
];

// Parse the layout
final layout = SeatLayout.fromCsvRows(rows);

// Use the widget
SeatMapWidget(
  layout: layout,
  selectedSeats: selectedSeats,
  onSeatTap: (seat) {
    // Handle seat selection
  },
)
```

### With Seat Status (from API)

```dart
final layout = SeatLayout.fromCsvRowsWithStatus(
  rows,
  availableSeats: 'L-1-1-1,L-1-1-2,L-1-1-3',
  bookedSeats: 'L-1-1-4,L-1-2-5',
  processingSeats: 'L-1-2-6',
);
```

### With Configuration

```dart
final layout = SeatLayout.fromCsvRows(
  rows,
  config: SeatLayoutConfig.bus(
    defaultPrice: 25000,
    categoryResolver: (code, metadata) {
      if (vipSeats.contains(code)) return 'VIP';
      return 'Standard';
    },
    priceResolver: (code, category, metadata) {
      if (category == 'VIP') return 35000;
      return 25000;
    },
  ),
);
```

### From JSON (API Response)

```dart
// Supports both formats:
// List: [{"seat_row1": "1A,1B,0,1C"}, ...]
// Map: {"seat_row1": "1A,1B,0,1C", "seat_row2": "2A,2B,0,2C"}

final layout = SeatLayout.fromJson(apiResponse['lower_seat_map']);
```

## Markers

| Code | Element | Description |
|------|---------|-------------|
| `0` | Empty/Aisle | Empty space or walkway |
| `@` | Door | Entry/exit door |
| `*` | Toilet | WC/restroom |
| `#` | Stairs | For double-decker buses |
| Other | Seat | Regular bookable seat |

## Customization

### Custom Seat Widget

```dart
SeatMapWidget(
  layout: layout,
  seatBuilder: (context, seat, isSelected) {
    return Container(
      // Your custom seat design
    );
  },
)
```

### Custom Special Elements

```dart
SeatMapWidget(
  layout: layout,
  specialBuilder: (context, element) {
    if (element.type == SeatElementType.door) {
      return MyCustomDoorWidget();
    }
    return DefaultSpecialWidget(element: element);
  },
)
```

### With State Management

```dart
SeatMapController(
  layout: layout,
  maxSelection: 4,
  onSelectionChanged: (seats) {
    print('Selected: ${seats.map((s) => s.label).join(", ")}');
  },
  builder: (context, layout, selectedSeats, onSeatTap) {
    return SeatMapWidget(
      layout: layout,
      selectedSeats: selectedSeats,
      onSeatTap: onSeatTap,
    );
  },
)
```

## Configuration Options

### SeatLayoutConfig

| Property | Default | Description |
|----------|---------|-------------|
| `emptyMarkers` | `{'0', ''}` | Codes that represent empty spaces |
| `doorMarker` | `'@'` | Code for door elements |
| `toiletMarker` | `'*'` | Code for toilet elements |
| `stairsMarker` | `'#'` | Code for stairs |
| `autoDetectAisle` | `true` | Auto-detect aisle columns |
| `delimiter` | `','` | Separator for row strings |

### SeatMapWidget

| Property | Default | Description |
|----------|---------|-------------|
| `seatSize` | `50` | Width/height of each seat |
| `seatSpacing` | `4` | Horizontal spacing between seats |
| `rowSpacing` | `4` | Vertical spacing between rows |
| `showRowLabels` | `false` | Show row numbers on left |
| `enableZoom` | `false` | Enable InteractiveViewer |
| `minScale` | `0.5` | Minimum zoom scale |
| `maxScale` | `3.0` | Maximum zoom scale |

## Preset Configurations

```dart
// For bus booking
SeatLayoutConfig.bus()

// For cinema/theater
SeatLayoutConfig.cinema()
```

## License

MIT License
