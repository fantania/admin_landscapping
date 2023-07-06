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

  // var times = [];

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
        _hour = selectedTime.hourOfPeriod
            .toString()
            .padLeft(2, '0'); // add leading zero if needed
        _minute = selectedTime.minute
            .toString()
            .padLeft(2, '0'); // add leading zero if needed
        _time =
            '${selectedTime.hour}:${_minute} ${selectedTime.period.index == 0 ? "AM" : "PM"}';
        // times.add(_time);
      });
    }
  }

  Future<void> _saveData() async {
    // Replace <YOUR_COLLECTION_NAME> with the name of your Firestore collection
    CollectionReference availabilities =
        FirebaseFirestore.instance.collection('availabilities');

    // Create a new document with a unique ID
    DocumentReference documentReference = availabilities.doc();

    // Set the data for the document
    await documentReference.set({
      'date': date,
      'time': _time,
      'created_at': DateTime.now(),
    });

    // Show a snackbar to indicate that the data was saved
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data saved to Firestore')),
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
          ;
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
                        Map<String, dynamic> data =
                            documents[index].data() as Map<String, dynamic>;
                        return InkWell(
                          onLongPress: ()async{
                            await FirebaseFirestore.instance.collection('availabilities').doc(documents[index].id).delete();
                          },
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
                              subtitle: Text(
                                data['time'],
                                style: TextStyle(fontSize: 16),
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

            // Card(
            //   margin: const EdgeInsets.all(10),
            //   color: Colors.green[100],
            //   shadowColor: Colors.blueGrey,
            //   elevation: 10,
            //   child: Column(mainAxisSize: MainAxisSize.min, children: [
            //     Text("Date: $date"),
            //     Text("Time: ${_time}"),
            //   ]),
            // ),
          ],
        ),
      ),
    );
  }
}
