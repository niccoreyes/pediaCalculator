import 'package:flutter/foundation.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pedia table',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Fluid Balance'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> formVal = {
    'Age': '',
    'Weight': '',
    'Temperature': '',
    'Input': '',
    'Output': '',
  };

  FormBuilderTextField formBuilderText(String label) {
    return FormBuilderTextField(
      name: label,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF6200EE),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF6200EE)),
        ),
      ),
      onChanged: (val) {
        setState(() {
          formVal = _formKey.currentState?.value ?? formVal;
          if (kDebugMode) {
            print(formVal.toString());
          }
        });
      },
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
    );
  }

  Widget resultsWidget() {
    return Text(
        "I/O: ${formVal['Input'] ??= ''}:${formVal['Output'] ??= ''}\nInsensible: ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Column(
                    children: [
                      FormBuilder(
                        key: _formKey,
                        // enabled: false,
                        onChanged: () {
                          _formKey.currentState!.save();
                          debugPrint(_formKey.currentState!.value.toString());
                        },
                        autovalidateMode: AutovalidateMode.disabled,
                        initialValue: formVal,
                        child: Column(children: [
                          for (String keys in formVal.keys)
                            formBuilderText(keys),
                        ]),
                      ),
                      Divider(
                        height: 26.0,
                      ),
                      resultsWidget()
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
