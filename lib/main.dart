import 'dart:math';

import 'package:editable/commons/math_functions.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
    'Name': "",
    'Height': 0.0,
    'Weight': 0.0,
    //'Temperature': 0.0,
    'Input': 0.0,
    'Output': 0.0,
    'Urine': 0.0,
    'BM': 0.0,
    //'Prev Day Insensible Loss': 0.0
  };
  Map<String, dynamic>? formVal;
  Map<String, double> calculated = {
    "BSA": 0.00,
    "Insensible": 0.00,
    "UO": 0.00
  };
  var testString = "";
  static const _credentials = r'''
''';
  // Build our app and trigger a frame.
  final gsheets = GSheets(_credentials);

  /// Your spreadsheet id
  ///
  /// It can be found in the link to your spreadsheet -
  /// link looks like so https://docs.google.com/spreadsheets/d/YOUR_SPREADSHEET_ID/edit#gid=0
  /// [YOUR_SPREADSHEET_ID] in the path is the id your need
  static const _spreadsheetId = '1Z1nj_Cfn937DAzdkggM4JEg4yFvxgNAJWXW5CwysPMw';

  @override
  Widget build(BuildContext context) {
    //returnprefix icon by key
    Icon? iconByKey(String label) {
      switch (label) {
        case 'Name':
          return const Icon(Icons.badge);
        case 'Height':
          return const Icon(Icons.height);
        case 'Weight':
          return const Icon(Icons.scale);
        case 'Input':
          return const Icon(Icons.free_breakfast);
        case 'Output':
          return const Icon(Icons.water_drop);
        case 'Urine':
          return const Icon(Icons.water_drop_outlined);
        case 'BM':
          return const Icon(Icons.delete);
        default:
          return null;
      }
    }

    //this autogenerates in FormTextFields - meaning they will be in text
    FormBuilderTextField formBuilderText(String label) {
      return FormBuilderTextField(
        name: label,
        initialValue: '',
        cursorColor: Theme.of(context).indicatorColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: iconByKey(label),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
        ),
        onChanged: (val) {
          // setState(() {
          // });
        },
        keyboardType:
            label == "Name" ? TextInputType.text : TextInputType.number,
        textInputAction: TextInputAction.next,
      );
    }

    FormBuilderRadioGroup<String> formRadio(
        String? labelText, String keyName, List<String> options) {
      return FormBuilderRadioGroup<String>(
        decoration: InputDecoration(
            labelText: labelText, labelStyle: const TextStyle(fontSize: 25)),
        initialValue: options[0],
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
    var textInputoutput =
        Text("I/O: ${formVal?['Input'] ?? 0}:${formVal?['Output'] ?? 0}");

    // height weight notifier
    String isMissingHeightOrWeight(String measurement) {
      String returnString =
          double.tryParse((formVal?[measurement] ?? 0).toString()) == 0 ||
                  formVal?[measurement] == ""
              ? "| No ${measurement.toLowerCase()}"
              : "";
      return returnString;
    }

    String returnWhatMissing() {
      String fullString = "";
      fullString += isMissingHeightOrWeight("Height");
      if (fullString != "") fullString = "$fullString ";
      fullString += isMissingHeightOrWeight("Weight");
      if (fullString != "") {
        fullString = "\n$fullString";
      }
      return fullString;
    }

    // return calculated previous insense
    String returnPreviousInsense() {
      String previousInsenseString = "";
      // double? previousInsense =
      //     double.tryParse(formVal?['Prev Day Insensible Loss'] ?? "");
      // //clean previousInsense
      // if (previousInsense?.isNaN ?? true) {
      //   previousInsense = 0;
      // }
      // double calculatedInsensible =
      //     (parseForm('Input') - parseForm('Output')) - (previousInsense ?? 0);

      // // (calculated['Insensible']?.toDouble() ?? 0) - (previousInsense ?? 0);
      // if (calculatedInsensible > 0 && calculatedInsensible != 0) {
      //   previousInsenseString += "+";
      // }
      // previousInsenseString += calculatedInsensible.toStringAsFixed(2);
      if (calculated['Insensible'] != null) {
        if (calculated['Insensible']?.isNaN ?? true) {
        } else {
          double calculatedFBInsense = parseForm('Input') -
              parseForm('Output') -
              (calculated['Insensible'] ?? 0);
          if (calculatedFBInsense > 0) {
            previousInsenseString += "+";
          }
          previousInsenseString += calculatedFBInsense.toStringAsFixed(2);
        }
      }

      return previousInsenseString;
    }

    // Fluid Balance
    String processFluidBalancePlusMinus() {
      double doubleFluidBalance = parseForm('Input') - parseForm('Output');
      String stringFluidBalance = "";
      if (doubleFluidBalance > 0) {
        stringFluidBalance += "+";
      }
      stringFluidBalance += doubleFluidBalance.toStringAsFixed(2);
      return stringFluidBalance;
    }

    var textFluidbalance = Text(
        "FB: ${processFluidBalancePlusMinus()} / ${returnPreviousInsense()}");

    // insensible
    void setInsensible() {
      double febrile = formVal?['Febrile'] == "No" ? 400.00 : 500.00;
      double shift = formVal?['Shift'] == "Daily" ? 1.0 : 3.0;
      double calculatedInsense = (calculated['BSA'] ?? 0.00) * febrile / shift;
      debugPrint(
          "Insensible = ${calculated['BSA']} * $febrile / $shift =  $calculatedInsense");
      calculated['Insensible'] = calculatedInsense;
      return;
    }

    var textInsensiblelosses =
        Text("Insensible: ${calculated['Insensible']?.toStringAsFixed(2)}");

    // urine out
    double calculateUO() {
      double shift = formVal?['Shift'] == "Daily" ? 24.0 : 8.0;
      calculated["UO"] = (parseForm('Urine') / parseForm('Weight')) / shift;
      if (calculated["UO"]?.isNaN ?? false) return 0.00;
      return calculated["UO"] ?? 0.00;
    }

    var textUrineoutput = Text("UO: ${calculateUO().toStringAsFixed(1)}");

    // scaffold
    var textBowelmovement =
        Text("BM: ${(formVal?['BM'] ?? 0) == "" ? 0 : (formVal?['BM'] ?? 0)}");
    var textName = Text(formVal?['Name'] ?? "");
    var textHeightweightcheck = Text(returnWhatMissing());

    //for loadPatientDialog

    bool isLoading = false;
    List<String> columnNameList = [""];
    List<String> columnHeightList = [""];
    List<String> columnWeightList = [""];

    List<SimpleDialogOption> listNamesAsOption(
        BuildContext context, List<String> nameColumn) {
      Map<String, dynamic> mappedContent = {};
      List<SimpleDialogOption> toReturn = [];

      for (var name in nameColumn) {
        toReturn.add(
          SimpleDialogOption(
            child: Text(name),
            onPressed: () {
              int index = columnNameList.indexOf(name);
              _formKey.currentState?.fields['Name']?.didChange(name);
              _formKey.currentState?.fields['Height']
                  ?.didChange(columnHeightList[index]);
              _formKey.currentState?.fields['Weight']
                  ?.didChange(columnWeightList[index]);
              Navigator.pop(context);
            },
          ),
        );
      }
      toReturn.add(
        SimpleDialogOption(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
      return toReturn;
    }

    // ignore: no_leading_underscores_for_local_identifiers
    void _loadPatient() async {
      // _formKey.currentState?.fields['Name']?.didChange("Test");
      // _formKey.currentState?.fields['Height']?.didChange("");
      // _formKey.currentState?.fields['Weight']?.didChange("20");
      // Display the spinner while the data is being loaded
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return const SimpleDialog(
            children: <Widget>[
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        },
      );

      // Run the function after the dialog is displayed
      final ss = await gsheets.spreadsheet(_spreadsheetId);
      final sheet = ss.worksheetByTitle('PatientList');
      columnNameList = await sheet?.values.column(1) ?? [""];
      columnHeightList = await sheet?.values.column(2) ?? [""];
      columnWeightList = await sheet?.values.column(3) ?? [""];

      // Close the dialog
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      // ignore: use_build_context_synchronously
      await showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return SimpleDialog(
                title: const Text('Choose Patient'),
                children: listNamesAsOption(context, columnNameList),
              );
            });
          });

      //await Future.delayed(Duration(seconds: 5));
      setState(() {
        isLoading = false;
      });
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
                onPressed: () {
                  _showAddDialog();
                },
                icon: const Icon(Icons.add)),
            IconButton(
                onPressed: _loadPatient, icon: const Icon(Icons.download))
          ],
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
                        // formRadio(
                        //     'Is Nephro Patient?', 'Nephro', ['Yes', 'No']),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Card(
                                margin: const EdgeInsets.all(3),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(children: [
                                    for (String keys in initVal.keys)
                                      formBuilderText(keys),
                                  ]),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  //bodySurfaceArea,
                                  Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Visibility(
                                            visible: textName.data == ""
                                                ? false
                                                : true,
                                            child: textName,
                                          ),
                                          textInputoutput,
                                          textUrineoutput,
                                          textFluidbalance,
                                          textInsensiblelosses,
                                          textBowelmovement,
                                          Visibility(
                                              visible:
                                                  textHeightweightcheck.data ==
                                                          ""
                                                      ? false
                                                      : true,
                                              child: textHeightweightcheck)
                                        ],
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                      onPressed: () async {
                                        var name = (formVal?['Name'] ?? "");
                                        if (name != "") {
                                          name += "\n";
                                        }
                                        await Clipboard.setData(ClipboardData(
                                            text:
                                                """${textInputoutput.data}, ${textFluidbalance.data}, ${textUrineoutput.data}, ${textBowelmovement.data}
${textInsensiblelosses.data}${textHeightweightcheck.data}"""));
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

  Future<void> _showAddDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false;
        return StatefulBuilder(builder: (context, setState) {
          TextEditingController controllerName = TextEditingController();
          controllerName.text = formVal?['Name'] ?? "";
          TextEditingController controllerHeight = TextEditingController();
          controllerHeight.text = formVal?['Height'] ?? "";
          TextEditingController controllerWeight = TextEditingController();
          controllerWeight.text = formVal?['Weight'] ?? "";
          void updateFieldsOnClose() {
            _formKey.currentState?.fields['Name']
                ?.didChange(controllerName.text);
            _formKey.currentState?.fields['Height']
                ?.didChange(controllerHeight.text);
            _formKey.currentState?.fields['Weight']
                ?.didChange(controllerWeight.text);
          }

          var formName = TextFormField(
            decoration: const InputDecoration(labelText: 'Name'),
            // initialValue: formVal?['Name'] ?? "",
            controller: controllerName,
            onChanged: (value) {},
          );
          var formHeight = TextFormField(
            decoration: const InputDecoration(labelText: 'Height'),
            controller: controllerHeight,
            // initialValue: formVal?['Height'] ?? "",
            onChanged: (value) {
              //formVal?["Height"] = controllerHeight.text;
            },
          );
          var formWeight = TextFormField(
            decoration: const InputDecoration(labelText: 'Weight'),
            // initialValue: formVal?['Weight'] ?? "",
            controller: controllerWeight,
            onChanged: (value) {
              //formVal?["Weight"] = controllerWeight.text;
            },
          );

          return AlertDialog(
            title: const Text('Add new data'),
            content: isLoading
                ? const Center(
                    heightFactor: 0.5,
                    child: CircularProgressIndicator(),
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                      children: [formName, formHeight, formWeight],
                    ),
                  ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  //setState(() {});
                  updateFieldsOnClose();
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('Add'),
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  // fetch spreadsheet by its id
                  final ss = await gsheets.spreadsheet(_spreadsheetId);
                  final sheet = ss.worksheetByTitle('PatientList');

                  // add the data to the Google Sheets
                  await sheet?.values.appendRow([
                    controllerName.text,
                    controllerHeight.text,
                    controllerWeight.text
                  ]);
                  //await Future.delayed(Duration(seconds: 1));
                  setState(() {
                    isLoading = false;
                  });
                  updateFieldsOnClose();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }
}
