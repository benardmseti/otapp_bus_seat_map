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
    // Example bus seat layout (similar to your API format)
    final busRows = [
      'L-1-1-1,L-1-1-2,0,L-1-1-3,L-1-1-4',
      'L-1-2-5,L-1-2-6,0,L-1-2-7,L-1-2-8',
      '@,0,0,L-1-3-9,L-1-3-10', // Door row
      'L-1-4-11,L-1-4-12,0,L-1-4-13,L-1-4-14',
      'L-1-5-15,L-1-5-16,0,L-1-5-17,L-1-5-18',
      '*,0,0,L-1-6-19,L-1-6-20', // Toilet row
      'L-1-7-21,L-1-7-22,0,L-1-7-23,L-1-7-24',
      'L-1-8-25,L-1-8-26,0,L-1-8-27,L-1-8-28',
      'L-1-9-29,L-1-9-30,L-1-9-31,L-1-9-32,L-1-9-33', // Back row (5 seats)
    ];

    // Simulated seat statuses (from API)
    final availableSeats =
        'L-1-1-1,L-1-1-2,L-1-1-3,L-1-2-5,L-1-2-7,L-1-2-8,L-1-3-9,L-1-4-11,L-1-4-12,L-1-4-13,L-1-5-15,L-1-5-16,L-1-5-17,L-1-6-19,L-1-7-21,L-1-7-22,L-1-7-23,L-1-8-25,L-1-8-26,L-1-9-29,L-1-9-30,L-1-9-31';
    final bookedSeats = 'L-1-1-4,L-1-2-6,L-1-3-10,L-1-4-14,L-1-5-18,L-1-6-20';
    final processingSeats = 'L-1-7-24,L-1-8-27,L-1-8-28,L-1-9-32,L-1-9-33';

    // VIP seats
    final vipSeats = {'L-1-1-1', 'L-1-1-2', 'L-1-1-3', 'L-1-1-4'};

    final layout = SeatLayout.fromCsvRowsWithStatus(
      busRows,
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
      availableSeats: availableSeats,
      bookedSeats: bookedSeats,
      processingSeats: processingSeats,
    );

    return Column(
      children: [
        // Driver section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const DriverWidget(size: 50),
              const SizedBox(width: 8),
            ],
          ),
        ),

        // Legend
        _buildLegend(),

        // Seat map
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
