import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:first_app/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:first_app/patientHome.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class doctorProfile extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<doctorProfile> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey();

  Future<void> _submit() async {
    // you can write your
    // own code according to
    // whatever you want to submit;
    // final url = Uri.https(
    //     'health-monitoring-afb77-default-rtdb.firebaseio.com', 'patients.json');
    // _formKey.currentState!.save();
    // http.post(url,
    //     headers: {'Content-Type': 'application/json'},
    //     body: json.encode(
    //       _formKey.currentState!.value
    //     ));
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;

      DatabaseReference doctorRef =
          FirebaseDatabase.instance.ref("Doctor/$uid");
      print(_formKey.currentState!.value);
      print(doctorRef);
      _formKey.currentState!.save();

// Only update the name, leave the age and address!
      await doctorRef.update(
        _formKey.currentState!.value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(24),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  FormBuilderTextField(
                    name: 'doctorMobNo',
                    decoration:
                        InputDecoration(labelText: 'Doctor Mobile Number'),
                    keyboardType: TextInputType.phone,
                  ),
                  // this is where the
                  // input goes
                  FormBuilderTextField(
                    name: 'patientName',
                    decoration: InputDecoration(labelText: 'Doctor Name'),
                    keyboardType: TextInputType.text,
                  ),
                  FormBuilderTextField(
                    name: 'patientAge',
                    decoration: InputDecoration(labelText: 'Doctor Age'),
                    keyboardType: TextInputType.number,
                  ),
                  FormBuilderTextField(
                    name: 'patientGender',
                    decoration: InputDecoration(labelText: 'Doctor Gender'),
                    keyboardType: TextInputType.text,
                  ),
                  FormBuilderTextField(
                    name: 'patientAddress',
                    decoration: InputDecoration(labelText: 'Doctor Address'),
                    keyboardType: TextInputType.text,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 152, 34, 172),
                        foregroundColor: Colors.white),
                    onPressed: _submit,
                    child: Text("submit"),
                  ),
                ],
              ),
            ),
          ),
          // this is where
          // the form field
          // are defined
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
