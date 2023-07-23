import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'booking.dart';

class BookingListScreen extends StatefulWidget {
  @override
  _BookingListScreenState createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking List'),
       
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching data'),
            );
          } else {
            List<Booking>? bookings = snapshot.data?.docs.map((doc) {
              return Booking(
                id: doc.id,
                name: doc['name'],
                cardNumber: doc['cardNumber'],
                expiryDate: doc['expiryDate'],
                cvv: doc['cvv'],
                timestamp: doc['timestamp'].toDate(),
                userData: doc['userData'],
              );
            }).toList();

            return ListView.builder(
              itemCount: bookings!.length,
              itemBuilder: (context, index) {
                Booking booking = bookings[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.calendar_today, color: Colors.blue), // Icon for the leading section.
                    title: Text(
                      'Name: ${booking.name}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Date: ${booking.bookingDate}',
                        ),
                        Text(
                          'Slot Time: ${booking.bookingTime}',
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () async {
                        await _firestore.collection('bookings').doc(booking.id).delete();
                      },
                      icon: Icon(Icons.delete, color: Colors.red), // Icon for delete action.
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
