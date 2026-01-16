## 0.1.2

- **NEW: `SeatLayout.fromApiResponse()`** - Parse full Otapp API response in one call
- Auto-parses seat_types with fares (V.V.I.P, VIP, Standard, etc.)
- Auto-parses available_seats, process_seats, reserve_hold_seats
- Auto-adds driver row based on is_right_hand_drive
- Handles price parsing with commas (e.g., "40,000.00")
- Added `SeatElementType.driver` for driver positioning
- Seats not in available_seats are automatically marked as booked
- Each seat now includes price and category from API

## 0.1.1

- Fix README installation instructions (use pub.dev instead of git)
- Add comprehensive widget customization documentation
- Clarify that all widgets (seats, aisles, special elements, row labels) are fully customizable

## 0.1.0

- Initial release
- CSV-based seat layout parsing
- Support for Otapp Services API response format
- Manual layout configuration option
- Automatic aisle detection
- Special elements support (doors, toilets, stairs)
- VIP/category seat support
- Seat status management (available, booked, selected, processing)
- Customizable seat widgets
- InteractiveViewer zoom/pan support
