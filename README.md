# Otapp Bus Seat Map

A flexible bus seat map widget for Flutter. Designed for bus booking apps using **Otapp Services API** or manual configuration.

## Features

- Works directly with **Otapp Services API** response format
- Manual setup option for custom implementations
- **100% customizable widgets** - bring your own seat, aisle, and special element designs
- Automatic aisle detection
- Support for special elements (doors, toilets, stairs)
- VIP/category support
- Seat status management (available, booked, selected, processing)
- InteractiveViewer support for zoom/pan

## Installation

```yaml
dependencies:
  otapp_bus_seat_map: ^0.1.2
```

Or run:
```bash
flutter pub add otapp_bus_seat_map
```

---

## Option 1: Using Otapp Services API

If you're using the Otapp Services API, the seat map response works directly with this package.

### API Response Format

The Otapp API returns seat data in this format:

```json
{
  "lower_seat_map": [
    {"seat_row1": "L-1-1-1,L-1-1-2,0,L-1-1-3,L-1-1-4"},
    {"seat_row2": "L-1-2-5,L-1-2-6,0,L-1-2-7,L-1-2-8"},
    {"seat_row3": "@,0,0,L-1-3-9,L-1-3-10"},
    {"seat_row4": "*,0,0,L-1-4-11,L-1-4-12"}
  ],
  "available_seats": "L-1-1-1,L-1-1-2,L-1-1-3,L-1-2-5,L-1-2-7",
  "process_seats": "L-1-2-8",
  "is_right_hand_drive": 1,
  "seat_types": [
    {"seat_type_name": "VIP", "seats": "L-1-1-1,L-1-1-2", "fare": [{"fare": "35000"}]},
    {"seat_type_name": "Standard", "seats": "L-1-1-3,L-1-1-4", "fare": [{"fare": "25000"}]}
  ]
}
```

### Using with Otapp API

```dart
import 'package:otapp_bus_seat_map/otapp_bus_seat_map.dart';

// Parse directly from API response
final layout = SeatLayout.fromJson(
  apiResponse['lower_seat_map'],
  config: SeatLayoutConfig.bus(),
);

// Apply seat statuses from API
final layoutWithStatus = SeatLayout.fromCsvRowsWithStatus(
  layout.rawRows,
  config: SeatLayoutConfig.bus(),
  availableSeats: apiResponse['available_seats'],
  bookedSeats: apiResponse['booked_seats'] ?? '',
  processingSeats: apiResponse['process_seats'] ?? '',
);

// Use the widget
SeatMapWidget(
  layout: layoutWithStatus,
  selectedSeats: selectedSeats,
  onSeatTap: (seat) {
    // Handle seat selection
  },
)
```

---

## Option 2: Manual Setup

You can also define seat layouts manually without an API.

### CSV Format

Each row is a comma-separated string. Use markers for special elements:

| Code | Element | Description |
|------|---------|-------------|
| `0` | Empty/Aisle | Empty space or walkway |
| `@` | Door | Entry/exit door |
| `*` | Toilet | WC/restroom |
| `#` | Stairs | For double-decker buses |
| Any other | Seat | Regular bookable seat |

### Manual Layout Example

```dart
import 'package:otapp_bus_seat_map/otapp_bus_seat_map.dart';

// Define your seat layout manually
final rows = [
  '1A,1B,0,1C,1D',   // Row 1: 2 seats, aisle, 2 seats
  '2A,2B,0,2C,2D',   // Row 2: same pattern
  '@,0,0,3C,3D',     // Row 3: door on left, 2 seats on right
  '4A,4B,0,4C,4D',   // Row 4: normal row
  '*,0,0,5C,5D',     // Row 5: toilet on left, 2 seats on right
  '6A,6B,6C,6D,6E',  // Back row: 5 seats, no aisle
];

// Parse the layout
final layout = SeatLayout.fromCsvRows(
  rows,
  config: SeatLayoutConfig.bus(defaultPrice: 25000),
);

// Use the widget
SeatMapWidget(
  layout: layout,
  selectedSeats: selectedSeats,
  onSeatTap: (seat) => handleSelection(seat),
)
```

### With Custom Pricing & Categories

```dart
final vipSeats = {'1A', '1B', '1C', '1D'};

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

---

## Full Widget Customization

**Every widget is customizable.** Use the default widgets or bring your own designs.

### Available Builders

| Builder | Purpose | Receives |
|---------|---------|----------|
| `seatBuilder` | Custom seat design | `context`, `seat`, `isSelected` |
| `aisleBuilder` | Custom aisle/empty space | `context`, `element` |
| `specialBuilder` | Custom door/toilet/stairs | `context`, `element` |
| `rowLabelBuilder` | Custom row labels | `context`, `rowIndex`, `row` |

### Example: Fully Custom Seat Map

```dart
SeatMapWidget(
  layout: layout,
  selectedSeats: selectedSeats,
  onSeatTap: (seat) => handleSelection(seat),

  // Your custom seat widget
  seatBuilder: (context, seat, isSelected) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: _getSeatColor(seat, isSelected),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (seat.category == 'VIP') Icon(Icons.star, size: 12),
          Text(seat.label ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
          if (seat.price != null) Text('${seat.price}', style: TextStyle(fontSize: 8)),
        ],
      ),
    );
  },

  // Your custom aisle widget
  aisleBuilder: (context, element) {
    return Container(
      width: 50,
      height: 50,
      child: Center(
        child: RotatedBox(
          quarterTurns: 1,
          child: Text('AISLE', style: TextStyle(color: Colors.grey, fontSize: 8)),
        ),
      ),
    );
  },

  // Your custom special elements
  specialBuilder: (context, element) {
    switch (element.type) {
      case SeatElementType.door:
        return MyCustomDoorWidget();
      case SeatElementType.toilet:
        return MyCustomToiletWidget();
      case SeatElementType.stairs:
        return MyCustomStairsWidget();
      default:
        return DefaultSpecialWidget(element: element);
    }
  },

  // Your custom row labels
  rowLabelBuilder: (context, rowIndex, row) {
    return Container(
      width: 30,
      child: Center(child: Text('R${rowIndex + 1}')),
    );
  },
)
```

### Using Default Widgets (Optional)

If you don't provide custom builders, the package uses sensible defaults:

```dart
// Minimal setup - uses all default widgets
SeatMapWidget(
  layout: layout,
  selectedSeats: selectedSeats,
  onSeatTap: (seat) => handleSelection(seat),
)
```

### With Selection Controller

```dart
SeatMapController(
  layout: layout,
  maxSelection: 4,
  onSelectionChanged: (seats) {
    print('Selected: ${seats.map((s) => s.label).join(", ")}');
    print('Total: ${seats.fold(0.0, (sum, s) => sum + s.price)}');
  },
  builder: (context, layout, selectedSeats, onSeatTap) {
    return SeatMapWidget(
      layout: layout,
      selectedSeats: selectedSeats,
      onSeatTap: onSeatTap,
      // Add your custom builders here too
    );
  },
)
```

---

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

---

## About Otapp Services

This package is designed to work seamlessly with the Otapp Services bus booking API. For API access and documentation, contact Otapp Services.

## License

MIT License
