import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Availabilities extends StatefulWidget {
  const Availabilities({super.key});

  @override
  State<Availabilities> createState() => _AvailabilitiesState();
}

class _AvailabilitiesState extends State<Availabilities> {
  CollectionReference availabilities =
      FirebaseFirestore.instance.collection('availabilities');

  late String _setTime, _setDate;

  String? _hour, _minute, _time;

  late String? date = "";

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2015),
      lastDate: DateTime(2101),
    );
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
        _hour = selectedTime.hourOfPeriod
            .toString()
            .padLeft(2, '0'); // add leading zero if needed
        _minute = selectedTime.minute
            .toString()
            .padLeft(2, '0'); // add leading zero if needed
        _time =
            '${selectedTime.hour}:${_minute} ${selectedTime.period.index == 0 ? "AM" : "PM"}';
      });
    }
  }

  Future<void> _saveData() async {
    CollectionReference availabilities =
        FirebaseFirestore.instance.collection('availabilities');

    // Query the Firestore to check if a document with the selected date already exists
    QuerySnapshot querySnapshot = await availabilities
        .where('date', isEqualTo: date)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // If the document with the selected date exists, update the time slots list
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      List<String> timeSlots = List.from(documentSnapshot['time_slots']);
      timeSlots.add(_time!); // Add the selected time to the list of time slots
      await documentSnapshot.reference.update({'time_slots': timeSlots});
    } else {
      // If the document with the selected date does not exist, create a new one
      await availabilities.add({
        'date': date,
        'time_slots': [_time!], // Create a new list with the selected time as the first element
        'created_at': DateTime.now(),
      });
    }

    // Show a snackbar to indicate that the data was saved
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data saved to Firestore')),
    );
  }

  Future<void> _deleteData(String documentId) async {
    await FirebaseFirestore.instance
        .collection('availabilities')
        .doc(documentId)
        .delete();

    // Show a snackbar to indicate that the data was deleted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data deleted from Firestore')),
    );
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> stream = availabilities.snapshots();
    var size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _time != null || date != ""
              ? _saveData()
              : ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Select time and date')),
                );
        },
        child: Icon(Icons.add),
      ),
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
            StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                } else {
                  List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return Container(
                    height: 400,
                    child: ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        String documentId = documents[index].id;
                        Map<String, dynamic> data =
                            documents[index].data() as Map<String, dynamic>;
                        return InkWell(
                          onLongPress: () => _deleteData(documentId),
                          child: Card(
                            elevation: 4,
                            margin:
                                EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(
                                data['date'],
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (String time in data['time_slots'])
                                    Text(
                                      time,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                ],
                              ),
                              trailing: Icon(Icons.timelapse_sharp),
                              onTap: () {
                                // add your onTap logic here
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
