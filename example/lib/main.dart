import 'package:flutter/material.dart';
import 'package:otapp_bus_seat_map/otapp_bus_seat_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seat Map Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SeatMapDemo(),
    );
  }
}

class SeatMapDemo extends StatefulWidget {
  const SeatMapDemo({super.key});

  @override
  State<SeatMapDemo> createState() => _SeatMapDemoState();
}

class _SeatMapDemoState extends State<SeatMapDemo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SelectedSeat> _selectedSeats = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seat Map Examples'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bus'),
            Tab(text: 'Cinema'),
            Tab(text: 'Custom'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBusExample(),
          _buildCinemaExample(),
          _buildCustomExample(),
        ],
      ),
      bottomNavigationBar: _selectedSeats.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedSeats.length} seats selected',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _selectedSeats.map((s) => s.label).join(', '),
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle booking
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Booked: ${_selectedSeats.map((s) => s.label).join(", ")}',
                            ),
                          ),
                        );
                      },
                      child: const Text('Book'),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBusExample() {
    // Exact Otapp Services API response format
    final apiResponse = {
      "status": 200,
      "lower_seat_map": [
        {"SeatRow1": "L-0-0-01,0,0,L-0-3-05,L-0-4-04"},
        {"SeatRow2": "L-1-0-02,0,0,L-1-3-07,L-1-4-06"},
        {"SeatRow3": "L-2-0-03,0,0,L-2-3-09,L-2-4-08"},
        {"SeatRow4": "0,0,0,L-3-3-11,L-3-4-10"},
        {"SeatRow5": "*,0,0,L-4-3-13,L-4-4-12"},
        {"SeatRow6": "@,0,0,L-5-3-15,L-5-4-14"},
        {"SeatRow7": "L-6-0-16,L-6-1-17,0,L-6-3-19,L-6-4-18"},
        {"SeatRow8": "L-7-0-20,L-7-1-21,0,L-7-3-23,L-7-4-22"},
        {"SeatRow9": "L-8-0-24,L-8-1-25,0,L-8-3-27,L-8-4-26"},
        {"SeatRow10": "L-9-0-28,L-9-1-29,0,L-9-3-31,L-9-4-30"},
        {"SeatRow11": "L-10-0-32,L-10-1-33,0,L-10-3-35,L-10-4-34"},
        {"SeatRow12": "L-11-0-36,L-11-1-37,0,L-11-3-39,L-11-4-38"},
        {"SeatRow13": "L-12-0-43,L-12-1-42,L-12-2-44,L-12-3-41,L-12-4-40"}
      ],
      "process_seats": "L-8-3-27,L-8-4-26",
      "available_seats":
          "L-0-0-01,L-0-4-04,L-1-0-02,L-1-3-07,L-1-4-06,L-2-0-03,L-2-3-09,L-2-4-08,L-5-3-15,L-8-1-25,L-8-3-27,L-8-4-26,L-9-0-28,L-9-1-29,L-9-3-31,L-9-4-30,L-10-0-32,L-10-1-33,L-10-3-35,L-10-4-34,L-11-0-36,L-11-1-37,L-11-3-39,L-11-4-38,L-12-0-43,L-12-1-42,L-12-2-44,L-12-3-41,L-12-4-40",
      "seat_types": [
        {
          "seat_type_id": "315",
          "seat_type_name": "V.V.I.P",
          "seats":
              "L-0-0-01,L-0-3-05,L-0-4-04,L-1-0-02,L-1-3-07,L-1-4-06,L-2-0-03,L-2-3-09,L-2-4-08",
          "fare": [
            {"currency": "TSH", "fare": "40,000.00"}
          ]
        }
      ],
      "fare": [
        {"currency": "TSH", "fare": "25,000.00"}
      ],
      "reserve_hold_seats": "",
      "is_right_hand_drive": "1"
    };

    // Parse with one line - handles everything automatically!
    final layout = SeatLayout.fromApiResponse(apiResponse);

    return Column(
      children: [
        // Legend with VIP
        _buildBusLegend(),

        // Seat map - Driver row is auto-added based on is_right_hand_drive
        Expanded(
          child: SeatMapWidget(
            layout: layout,
            selectedSeats: _selectedSeats,
            onSeatTap: (seat) => _handleSeatTap(seat),
            seatSize: 50,
            seatSpacing: 4,
            rowSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildBusLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _legendItem(Colors.white, 'Available'),
          _legendItemVip(Colors.amber.shade100, 'VIP', Colors.amber.shade600),
          _legendItem(Colors.blue.shade600, 'Selected'),
          _legendItem(Colors.grey.shade400, 'Booked'),
          _legendItem(Colors.orange.shade400, 'Processing'),
        ],
      ),
    );
  }

  Widget _legendItemVip(Color color, String label, Color border) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border, width: 2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildCinemaExample() {
    // Cinema layout with gaps for aisles
    final cinemaRows = [
      'A1,A2,A3,A4,,A5,A6,A7,A8,,A9,A10,A11,A12',
      'B1,B2,B3,B4,,B5,B6,B7,B8,,B9,B10,B11,B12',
      'C1,C2,C3,C4,,C5,C6,C7,C8,,C9,C10,C11,C12',
      ',,,,,,,,,,,,', // Gap row
      'D1,D2,D3,D4,,D5,D6,D7,D8,,D9,D10,D11,D12',
      'E1,E2,E3,E4,,E5,E6,E7,E8,,E9,E10,E11,E12',
      'F1,F2,F3,F4,,F5,F6,F7,F8,,F9,F10,F11,F12',
    ];

    final bookedSeats = 'B5,B6,B7,D6,D7,E6,E7';

    final layout = SeatLayout.fromCsvRowsWithStatus(
      cinemaRows,
      config: SeatLayoutConfig.cinema(defaultPrice: 15000),
      bookedSeats: bookedSeats,
    );

    return Column(
      children: [
        // Screen
        Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade200, Colors.blue.shade400],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'SCREEN',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),

        _buildLegend(),

        // Seat map
        Expanded(
          child: SeatMapWidget(
            layout: layout,
            selectedSeats: _selectedSeats,
            onSeatTap: (seat) => _handleSeatTap(seat),
            seatSize: 40,
            seatSpacing: 2,
            rowSpacing: 4,
            showRowLabels: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomExample() {
    // Custom layout with special markers
    final customRows = [
      'S1,S2,S3,0,S4,S5,S6',
      'S7,S8,S9,0,S10,S11,S12',
      '#,0,0,0,0,0,#', // Stairs on both sides
      'S13,S14,S15,0,S16,S17,S18',
      'S19,S20,S21,0,S22,S23,S24',
    ];

    final layout = SeatLayout.fromCsvRows(
      customRows,
      config: SeatLayoutConfig(
        emptyMarkers: {'0', ''},
        stairsMarker: '#',
        autoDetectAisle: true,
        defaultPrice: 50,
        labelExtractor: (code) => code.replaceAll('S', ''),
      ),
    );

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Double Decker Upper Floor',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _buildLegend(),
        Expanded(
          child: SeatMapWidget(
            layout: layout,
            selectedSeats: _selectedSeats,
            onSeatTap: (seat) => _handleSeatTap(seat),
            seatSize: 55,
            seatSpacing: 6,
            rowSpacing: 8,
            enableZoom: true,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _legendItem(Colors.white, 'Available'),
          _legendItem(Colors.blue.shade600, 'Selected'),
          _legendItem(Colors.grey.shade400, 'Booked'),
          _legendItem(Colors.orange.shade300, 'Processing'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _handleSeatTap(SeatElement seat) {
    if (!seat.isSelectable) return;

    setState(() {
      final existingIndex =
          _selectedSeats.indexWhere((s) => s.id == seat.id);

      if (existingIndex >= 0) {
        _selectedSeats.removeAt(existingIndex);
      } else {
        _selectedSeats.add(SelectedSeat.fromElement(seat));
      }
    });
  }
}
