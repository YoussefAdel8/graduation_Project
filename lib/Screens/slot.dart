import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? _selectedDate;
  List<String> _timeSlots = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM'
  ];
  String? _selectedTimeSlot;

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot =
            null; // Reset selected time slot when a new date is selected
      });
    }
  }

  void _onTimeSlotSelected(String? timeSlot) {
    setState(() {
      _selectedTimeSlot = timeSlot;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Dates'),
        backgroundColor: const Color(0xFFEF8B39),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 55,
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xFFEF8B39))),
            onPressed: () => _showDatePicker(context),
            child: Text('Select Date'),
          ),
          SizedBox(height: 16),
          _selectedDate != null
              ? Text(
                  'Selected Date: ${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
              : Container(),
          SizedBox(height: 16),
          _selectedDate != null
              ? Column(
                  children: _timeSlots.map((timeSlot) {
                    return ListTile(
                      title: Text(timeSlot),
                      leading: Radio<String>(
                        value: timeSlot,
                        groupValue: _selectedTimeSlot,
                        onChanged: _onTimeSlotSelected,
                      ),
                    );
                  }).toList(),
                )
              : Container(),
          SizedBox(height: 16),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xFFEF8B39))),
            onPressed: () {
              if (_selectedDate != null && _selectedTimeSlot != null) {
                // Handle the selected date and time slot
                print('Selected Date: $_selectedDate');
                print('Selected Time Slot: $_selectedTimeSlot');
              } else {
                print('Please select a date and time slot');
              }
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
