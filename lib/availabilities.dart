import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Availabilities extends StatefulWidget {
  const Availabilities({super.key});

  @override
  State<Availabilities> createState() => _AvailabilitiesState();
}

class _AvailabilitiesState extends State<Availabilities> {
  late String _setTime, _setDate;

  List<String> times = [];

  late String _hour, _minute, _time;

  late String? date = "";

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        date = DateFormat.yMd().format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = '$_hour : $_minute';
        times.add(_time);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                width: size.width - 40,
                height: size.height / 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF006766),
                ),
                child: const Center(
                  child: Text(
                    "Choose a Date",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: _selectTime,
              child: Container(
                width: size.width - 40,
                height: size.height / 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF006766),
                ),
                child: const Center(
                  child: Text(
                    "Choose a Time",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.all(10),
              color: Colors.green[100],
              shadowColor: Colors.blueGrey,
              elevation: 10,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text("Date: $date"),
                Text("Time: ${times}"),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
