import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:first_app/auth.dart';
import 'package:first_app/pages/loginDoctor.dart';
import 'package:first_app/patietntTabs.dart';
import 'package:flutter/material.dart';
import 'package:first_app/patientSettings.dart';
import 'package:first_app/patientProfile.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_health_connect/flutter_health_connect.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    initializeReading();
  }

  Iterable<MapEntry> patientsNames = Iterable.empty();

  void initializeReading() async {
    final user = FirebaseAuth.instance.currentUser;
    print("user$user");
    if (user != null) {
      final uid = user.uid;
      DatabaseReference doctorRef =
          FirebaseDatabase.instance.ref("Doctor/$uid");
      final snapshot = await doctorRef.get();
      if (snapshot.exists) {
        dynamic doctor = snapshot.value;
        DatabaseReference patientsRef =
            FirebaseDatabase.instance.ref("Patients");
        Query query = patientsRef
            .orderByChild("doctorMobileNo")
            .equalTo(doctor["doctorMobNo"]);
        final patientSnapshot = await query.get();
        if (patientSnapshot.exists) {
          dynamic patients = patientSnapshot.value as dynamic;
          setState(() {
            patientsNames = patients.entries as dynamic;
          });

          print("patientNames:$patientsNames");
        }
      }
    }
  }

  void _navigateToDoctorView(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => LoginDoctorPage()));
  }

  Future signOut() async {
    _navigateToDoctorView(context);
    // await Auth().signOut();
  }

  Future<Map> getPatientReadings(String patientId) async {
    DatabaseReference patientParamsRef =
        FirebaseDatabase.instance.ref("PatientsParams");
    final snapshot = await patientParamsRef.get();
    if (snapshot.exists) {
      Query query = patientParamsRef
          .limitToLast(1)
          .orderByChild("userId")
          .equalTo(patientId);
      final patientParamsSnapshot = await query.get();
      dynamic patientParamsSnapshotValue = patientParamsSnapshot.value;
      String RR =
          patientParamsSnapshotValue.values.first["RespiratoryRate"].toString();
      String HR =
          patientParamsSnapshotValue.values.first["HeartRate"].toString();
      print(patientParamsSnapshotValue);
      return {"RR": RR, "HR": HR};
    }
    return {};
  }

  PatientCard(MapEntry patient) {
    // List listings = <Widget>[];

    // for (int i = 0; i < patientsNames.length; i++) {
    String patName = patient.value["patientName"];
    String patientId = patient.key;

    // listings.add(
    return FutureBuilder<Map>(
      future: getPatientReadings(patientId),
      builder: (context, AsyncSnapshot<Map> snapshot) => Card(
        color: Color.fromARGB(255, 245, 230, 255),
        elevation: 4.0,
        child: Column(
          children: [
            ListTile(
              title: Text(patName),
              subtitle: Text('Status: Ok'),
              //  trailing: Icon(Icons.favorite_outline),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 0, 0, 16),
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(snapshot.data!["HR"]),
                  Text(snapshot.data!["RR"]),
                ],
              ),
            ),
            ButtonBar(
              children: [
                //  TextButton(
                //    child: const Text('CONTACT AGENT'),
                //    onPressed: () {/* ... */},
                //  ),
                TextButton(
                  child: const Text('View Health Parameters'),
                  onPressed: () {/* ... */},
                ),
              ],
            ),
          ],
        ),
        // ),
      ),
    );
    // }
  }

  Widget displayAllCards(Iterable<dynamic> patientsNames) {
    // List<Widget> cards = [];
    // for (int i=0; i<patientsNames.length; i++) {
    //   cards.add(PatientCard(patientsNames));
    // }
    // return cards;

    List.generate(patientsNames.length, (index) {
      return PatientCard(
        patientsNames.elementAt(index)["patientName"],
      );
    });

    return Text("");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment
                        .centerLeft, // Align however you like (i.e .centerRight, centerLeft)
                    child:
                        Text("Your Patients", style: TextStyle(fontSize: 18)),
                  ),
                ),
                Column(
                  children:
                      patientsNames.map<Widget>((e) => PatientCard(e)).toList(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 152, 34, 172),
                  ),
                  onPressed: signOut,
                  child: const Text('Sign Out'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
