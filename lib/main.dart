import 'dart:math';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  Map<String, dynamic> initVal = {
    'Height': 0.0,
    'Weight': 0.0,
    'Temperature': 0.0,
    'Input': 0.0,
    'Output': 0.0,
    'Urine': 0.0,
  };
  Map<String, dynamic>? formVal;
  Map<String, double> calculated = {
    "BSA": 0.00,
    "Insensible": 0.00,
    "UO": 0.00
  };
  var testString = "";

  @override
  Widget build(BuildContext context) {
    //this autogenerates in FormTextFields - meaning they will be in text
    FormBuilderTextField formBuilderText(String label) {
      return FormBuilderTextField(
        name: label,
        initialValue: '',
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
          // setState(() {
          // });
        },
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
      );
    }

    FormBuilderRadioGroup<String> formRadio(
        String? labelText, String keyName, List<String> options) {
      return FormBuilderRadioGroup<String>(
        decoration: InputDecoration(
            labelText: labelText, labelStyle: const TextStyle(fontSize: 25)),
        //initialValue: "No",
        name: keyName,
        options: options
            .map((yn) => FormBuilderFieldOption(
                  value: yn,
                  child: Text(yn, style: const TextStyle(fontSize: 20)),
                ))
            .toList(growable: false),
        controlAffinity: ControlAffinity.trailing,
        onChanged: (value) {
          setState(() {});
        },
      );
    }

    double parseForm(String key) {
      try {
        double myDouble = double.parse(formVal?[key]);
        return myDouble;
      } catch (e) {
        debugPrint("Error: $e");
        return 0.00;
      }
    }

    String returnBSA() {
      double calculatedBSA =
          sqrt((parseForm('Height') * parseForm('Weight')) / 3600);
      calculated['BSA'] = calculatedBSA;
      return calculatedBSA.toStringAsFixed(2);
    }

    var bodySurfaceArea = Text("BSA: ${returnBSA()}");
    var inputOutput = Text("I/O: ${formVal?['Input']}:${formVal?['Output']}");
    var fluidBalance = Text(
        "FB: ${(parseForm('Input') - parseForm('Output')).toStringAsFixed(2)}");

    void setInsensible() {
      double febrile = formVal?['Febrile'] == "No" ? 400.00 : 500.00;
      double shift = formVal?['Shift'] == "Daily" ? 1.0 : 3.0;
      double calculatedInsense = (calculated['BSA'] ?? 0.00) * febrile / shift;
      debugPrint(
          "Insensible = ${calculated['BSA']} * $febrile / $shift =  $calculatedInsense");
      calculated['Insensible'] = calculatedInsense;
      return;
    }

    var insensibleLosses =
        Text("Insensible: ${calculated['Insensible']?.toStringAsFixed(2)}");

    double calculateUO() {
      double shift = formVal?['Shift'] == "Daily" ? 24.0 : 8.0;
      calculated["UO"] = (parseForm('Urine') / parseForm('Weight')) / shift;
      return calculated["UO"] ?? 0.00;
    }

    var urineOutput = Text("UO: ${calculateUO().toStringAsFixed(2)}");
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SafeArea(
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
                      setState(() {
                        formVal = _formKey.currentState?.value;
                        setInsensible();
                      });
                    },
                    autovalidateMode: AutovalidateMode.disabled,
                    initialValue: initVal,
                    child: Column(
                      children: [
                        formRadio(null, 'Shift', ['Shift', 'Daily']),
                        formRadio(
                            'Had Febrile episode?', 'Febrile', ['Yes', 'No']),
                        formRadio(
                            'Is Nephro Patient?', 'Nephro', ['Yes', 'No']),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(children: [
                                for (String keys in initVal.keys)
                                  formBuilderText(keys),
                              ]),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  bodySurfaceArea,
                                  inputOutput,
                                  urineOutput,
                                  fluidBalance,
                                  insensibleLosses,
                                  ElevatedButton(
                                      onPressed: () async {
                                        await Clipboard.setData(ClipboardData(
                                            text:
                                                """Ht: ${formVal?['Height']} Wt: ${formVal?['Weight']}
${bodySurfaceArea.data}
${inputOutput.data}
${urineOutput.data}
${fluidBalance.data}
${insensibleLosses.data}"""));
                                      },
                                      child: const Text("Copy to Clipboard"))
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 26.0,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
