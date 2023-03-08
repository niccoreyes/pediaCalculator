// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'config.dart';

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
    'BP Systolic': "",
    'BP Diastolic': "",
    'HR': 0,
    'RR': 0,
    'T': 0,
    'O2Sat': 0,
    'Input': 0.0,
    'Output': 0.0,
    'Urine': 0.0,
    'Oral': 0.0,
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

  // Build our app and trigger a frame.
  final gsheets = GSheets(config.creds);

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
      Icon? iconLook;
      const iconMap = {
        'Name': Icons.badge,
        'Height': Icons.height,
        'Weight': Icons.scale,
        'HR': Icons.favorite_outlined,
        'RR': Icons.timelapse_rounded,
        'T': Icons.thermostat,
        'Input': Icons.free_breakfast,
        'Output': Icons.water_drop,
        'Urine': Icons.water_drop_outlined,
        'BM': Icons.delete,
      };
      if (iconMap[label] != null) {
        iconLook = Icon(iconMap[label]);
      }

      return iconLook;
    }

    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    DateTime dateTime = DateTime.now();

    // Select for Date
    Future<DateTime> selectDate(BuildContext context) async {
      final selected = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
      );
      if (selected != null && selected != selectedDate) {
        setState(() {
          selectedDate = selected;
        });
      }
      return selectedDate;
    }

// Select for Time
    Future<TimeOfDay> selectTime(BuildContext context) async {
      final selected = await showTimePicker(
        context: context,
        initialTime: selectedTime,
      );
      if (selected != null && selected != selectedTime) {
        setState(() {
          selectedTime = selected;
        });
      }
      return selectedTime;
    }
// select date time picker

    // ignore: unused_element
    Future selectDateTime(BuildContext context) async {
      final date = await selectDate(context);
      //if (date == null) return;

      final time = await selectTime(context);

      //if (time == null) return;
      setState(() {
        dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }

    String getDate() {
      // ignore: unnecessary_null_comparison
      if (selectedDate == null) {
        return 'select date';
      } else {
        return DateFormat('MM/dd/yyyy').format(selectedDate);
      }
    }

    // ignore: unused_element
    String getDateTime() {
      // ignore: unnecessary_null_comparison
      if (dateTime == null) {
        return 'select date timer';
      } else {
        return DateFormat('yyyy-MM-dd HH: ss a').format(dateTime);
      }
    }

    // ignore: unused_element
    String getTime(TimeOfDay tod) {
      final now = DateTime.now();

      final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
      final format = DateFormat.jm();
      return format.format(dt);
    }

    Widget? getSuffixButton(String label) {
      Future<void> addDate(String lastFormat) async {
        var currentText = _formKey.currentState?.value[label] ?? "";
        await selectDate(context);
        var date = getDate();
        _formKey.currentState?.fields[label]
            ?.didChange(currentText + " " + lastFormat + " " + date);
      }

      var suffixMap = {
        'T': IconButton(
            onPressed: () {
              addDate("last febrile episode");
            },
            icon: const Icon(Icons.date_range)),
        'BM': IconButton(
            onPressed: () {
              addDate("last BM");
            },
            icon: const Icon(Icons.date_range))
      };
      return suffixMap[label];
    }

    //this autogenerates in FormTextFields - meaning they will be in text
    FormBuilderTextField formBuilderText(String label,
        {Widget? suffixButton, void Function()? onTapFunction}) {
      Map<String, dynamic> labelKeyboard = {
        "Name": TextInputType.text,
        "BM": TextInputType.text,
        'T': TextInputType.text,
        'O2Sat': TextInputType.text
      };

      TextInputType getKeyboardType() {
        var currentKeyboard = formVal?['keyboard'] ?? "Yes";
        if (currentKeyboard == 'No') {
          return labelKeyboard[label] ?? TextInputType.number;
        } else {
          return TextInputType.text;
        }
      }

      return FormBuilderTextField(
        name: label,
        maxLines: null,
        initialValue: '',
        cursorColor: Theme.of(context).indicatorColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: iconByKey(label),
          suffixIcon: suffixButton,
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
        onTap: onTapFunction,
        keyboardType: getKeyboardType(),
        textInputAction: TextInputAction.next,
        autofocus: true,
      );
    }

    // radioForm
    FormBuilderRadioGroup<String> formRadio(
        String? labelText, String keyName, List<String> options,
        {double labelFont = 25, double labelOption = 20}) {
      return FormBuilderRadioGroup<String>(
        decoration: InputDecoration(
            labelText: labelText, labelStyle: TextStyle(fontSize: labelFont)),
        initialValue: options[0],
        name: keyName,
        options: options
            .map((yn) => FormBuilderFieldOption(
                  value: yn,
                  child: (() {
                    // your code here
                    if (yn == "Custom") {
                      return formVal?['Shift'] == "Custom"
                          ? formBuilderText("Custom", onTapFunction: () {
                              debugPrint("tapped");
                              _formKey.currentState?.fields[keyName]
                                  ?.didChange(yn);
                            })
                          : Text(yn, style: TextStyle(fontSize: labelOption));
                    } else {
                      return Text(yn, style: TextStyle(fontSize: labelOption));
                    }
                  }()),
                ))
            .toList(growable: false),
        controlAffinity: ControlAffinity.trailing,
        onChanged: (value) {
          setState(() {});
        },
      );
    }

    String getShift() {
      String input = _formKey.currentState?.value['Shift'] ?? "Shift (6-10)";
      String output = input.replaceAll(RegExp(r'^Shift '), '');
      if (output != "") {
        output += "\n";
      }
      return output;
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

    var textBodySurfaceArea = Text("BSA: ${returnBSA()}");
    var textInputoutput =
        Text("I/O ${formVal?['Input'] ?? 0}/${formVal?['Output'] ?? 0}");

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
      if (calculated['Insensible'] != null) {
        if (calculated['Insensible']?.isNaN ?? true) {
        } else {
          double calculatedFBInsense = parseForm('Input') -
              parseForm('Output') -
              (calculated['Insensible'] ?? 0);
          if (calculatedFBInsense > 0) {
            previousInsenseString += "+";
          }
          previousInsenseString += calculatedFBInsense.toStringAsFixed(0);
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
      stringFluidBalance = stringFluidBalance.replaceAll(RegExp(r'\.00$'), '');

      return stringFluidBalance;
    }

    var textFluidbalance = Text(
        "FB ${processFluidBalancePlusMinus()} / ${returnPreviousInsense()}");

    // insensible
    void setInsensible() {
      double febrile = formVal?['Febrile'] == "No" ? 400.00 : 500.00;
      double shift = formVal?['Shift'] == "Daily" ? 1.0 : 3.0;
      if (formVal?['Shift'] == "Custom") {}
      bool isNewborn = (formVal?['Newborn'] ?? "No") == "No" ? false : true;

      double calculatedInsense = (calculated['BSA'] ?? 0.00) * febrile / shift;
      // debugPrint(
      //     "Insensible = ${calculated['BSA']} * $febrile / $shift =  $calculatedInsense");
      if (!isNewborn) {
        calculated['Insensible'] = calculatedInsense;
      } else {
        double weight = double.tryParse(formVal?['Weight'] ?? "") ?? 0.00;
        if (weight < 750) {
          calculatedInsense = weight * 100 / shift;
        } else if (weight <= 1000) {
          calculatedInsense = weight * 70 / shift;
        } else if (weight <= 1500) {
          calculatedInsense = weight * 65 / shift;
        } else {
          calculatedInsense = weight * 30 / shift;
        }
        calculated['Insensible'] = calculatedInsense;
      }
      return;
    }

    var textInsensiblelosses =
        Text("Insensible ${calculated['Insensible']?.toStringAsFixed(2)}");

    // urine out
    double calculateUO() {
      double shift = formVal?['Shift'] == "Daily" ? 24.0 : 8.0;
      calculated["UO"] = (parseForm('Urine') / parseForm('Weight')) / shift;
      if (calculated["UO"]?.isNaN ?? false) return 0.00;
      return calculated["UO"] ?? 0.00;
    }

    var textUrineoutput = Text("UO ${calculateUO().toStringAsFixed(1)}");

    // scaffold
    var textBowelmovement =
        Text("BM ${(formVal?['BM'] ?? 0) == "" ? 0 : (formVal?['BM'] ?? 0)}");
    var textName = Text(formVal?['Name'] ?? "");
    var textHeightweightcheck = Text(returnWhatMissing());

    //for loadPatientDialog

    List<String> columnNameList = [""];
    List<String> columnHeightList = [""];
    List<String> columnWeightList = [""];

    List<SimpleDialogOption> listNamesAsOption(
        BuildContext context, List<String> nameColumn) {
      //Map<String, dynamic> mappedContent = {};
      List<SimpleDialogOption> toReturn = [];

      for (int i = 0; i < nameColumn.length; i++) {
        String name = nameColumn[i];
        //int index = columnNameList.indexOf(name);
        toReturn.add(
          SimpleDialogOption(
            padding: const EdgeInsets.all(0),
            child: GestureDetector(
                onLongPress: () {
                  // your code here
                  debugPrint("int index: $i");
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Delete"),
                        content: const Text(
                            "Are you sure you want to delete this item?"),
                        actions: <Widget>[
                          ElevatedButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          ElevatedButton(
                            child: const Text("Delete"),
                            onPressed: () async {
                              // your code to delete the item
                              final ss =
                                  await gsheets.spreadsheet(_spreadsheetId);
                              final sheet = ss.worksheetByTitle('PatientList');

                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const SimpleDialog(
                                      children: <Widget>[
                                        Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ],
                                    );
                                  });
                              if (kDebugMode) {
                                print(await sheet?.values.row(i + 1));
                                print(await sheet?.deleteRow(i + 1));
                              } else {
                                await sheet?.values.row(i + 1);
                                await sheet?.deleteRow(i + 1);
                              }

                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();

                              //Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  ); //showdialog
                }, //onlong press

                child: Container(
                    padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                    margin: const EdgeInsets.all(0),
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    //color: Colors.amberAccent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name),
                        Text(
                            "Ht: ${columnHeightList[i]} Wt: ${columnWeightList[i]}")
                      ],
                    ))),
            onPressed: () {
              _formKey.currentState?.fields['Name']?.didChange(name);
              _formKey.currentState?.fields['Height']
                  ?.didChange(columnHeightList[i]);
              _formKey.currentState?.fields['Weight']
                  ?.didChange(columnWeightList[i]);
              Navigator.pop(context);
            },
          ),
        );
      }
      toReturn.add(
        SimpleDialogOption(
          child: const Center(child: Text('Cancel')),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
      return toReturn;
    }

    // ignore: no_leading_underscores_for_local_identifiers
    void _loadPatient() async {
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
      Navigator.pop(context);
      await showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return SimpleDialog(
                title: const Column(
                  children: [
                    Text('Choose Patient'),
                    Text(
                      'hold to delete',
                      style:
                          TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                    )
                  ],
                ),
                children: listNamesAsOption(context, columnNameList),
              );
            });
          });

      //await Future.delayed(Duration(seconds: 5));
      setState(() {});
    }

    Widget textPeekExpiratoryEstimate() {
      double hundredToAdd = 0;
      double height = double.tryParse(formVal?['Height'] ?? "") ?? 0;
      double calculatedHtRemain = height;
      double estimatedPeakExpiratoryFlowRate = 0;
      while (calculatedHtRemain >= 100) {
        calculatedHtRemain = calculatedHtRemain - 100;
        hundredToAdd += 1;
      }
      double divisible10 = (calculatedHtRemain / 10).floorToDouble();

      calculatedHtRemain = calculatedHtRemain - divisible10 * 10;
      double remain = calculatedHtRemain;

      // print('hundredToAdd: $hundredToAdd');
      // print('Height: $height');
      // print('Calculated Height: $calculatedHtRemain');

      estimatedPeakExpiratoryFlowRate =
          (hundredToAdd * 100) + (divisible10 * 50) + (remain / 10 * 50);
      String calculationString =
          'Height: $height\nCalculation:\n($hundredToAdd x 100) + ($divisible10 x 50) + ($remain / 10 x 50)\n=$estimatedPeakExpiratoryFlowRate';
      return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(
                      "Formula for Estimated Peak Expiratory flow rate"),
                  content: Text(calculationString),
                  actions: <Widget>[
                    ElevatedButton(
                      child: const Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Text('ePEFR: $estimatedPeakExpiratoryFlowRate'));
    }

    Widget webOnlyWidget(Widget webWidget, {bool androidWebOnlyCheck = false}) {
      bool androidWebCheck = true;
      Widget returnedWidget;
      if (androidWebOnlyCheck) {
        androidWebCheck = defaultTargetPlatform == TargetPlatform.android;
      }

      if (androidWebOnlyCheck) {
        if (androidWebCheck && kIsWeb) {
          returnedWidget = webWidget;
        } else {
          returnedWidget = const SizedBox.shrink();
        }
      } else {
        returnedWidget = webWidget;
      }
      return returnedWidget;
    }

    String strVital(String label, {bool setComma = true}) {
      var stringBuild = "$label ";
      var retrievedVal = formVal?[label].toString();
      var comma = setComma ? " " : "";
      if (retrievedVal == null ||
          retrievedVal == "" ||
          retrievedVal == "null") {
        stringBuild = "";
      } else {
        if (label == 'T') {
          retrievedVal += "°C";
        }
        stringBuild += "$retrievedVal$comma";
      }
      return stringBuild;
    }

    String stringBP() {
      String bpBuilder;
      //returns true if null
      bool nullCheck(var item) {
        return item == null || item == "" || item == "null";
      }

      var systolicBP = formVal?['BP Systolic'].toString();
      var sysCheck = nullCheck(systolicBP);

      var diastolicBP = formVal?['BP Diastolic'].toString();
      var diasCheck = nullCheck(diastolicBP);

      // null == true
      if (sysCheck && diasCheck) {
        bpBuilder = "";
      } else {
        bpBuilder = "BP $systolicBP/$diastolicBP ";
      }
      return bpBuilder;
    }

    var textVitals = Text(
      "${stringBP()}${strVital('HR')}${strVital('RR')}${strVital('T')}${strVital('O2Sat')}",
      style: const TextStyle(fontSize: 10),
    );

    // oralText calculation
    String strOral(String label) {
      var stringBuild = "$label ";
      var doubleRetrieved = int.tryParse(formVal?[label] ?? "") ?? 0;
      var retrievedVal = doubleRetrieved.toString();
      if (retrievedVal == "" || retrievedVal == "null" || retrievedVal == "0") {
        stringBuild = "";
      } else {
        if (doubleRetrieved > 0) {
          stringBuild += "+";
        }
        stringBuild += retrievedVal;
      }
      return stringBuild;
    }

    var textOral = Text(strOral('Oral'));
    GestureDetector glanceFormula(
        String labelFormula, String variableOutput, String formulaText) {
      return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(formulaText),
                  content: Text(variableOutput),
                  actions: <Widget>[
                    ElevatedButton(
                      child: const Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Text('$labelFormula: $variableOutput'));
    }

    Widget textABL() {
      String stringWeight = formVal?['Weight'] ?? "";
      double weight = double.tryParse(stringWeight) ?? 0.00;
      double doubleAbl = weight * 80 * 0.20;
      String stringAbl = doubleAbl.toStringAsFixed(2);
      return glanceFormula("ABL", stringAbl,
          "Allowable Blood Loss (ABL)= weight($stringAbl) x 80ml/kg x.20\n\n(max blood loss permitted for pediatric population)");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          webOnlyWidget(IconButton(
              tooltip: 'Open Vitals App',
              onPressed: () async {
                const url =
                    'https://niccoreyes.github.io/medical_calculator/build/web/';
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  throw 'Could not launch $url';
                }
              },
              icon: const Icon(Icons.monitor_heart))),
          webOnlyWidget(
              IconButton(
                  tooltip: 'Install Android',
                  onPressed: () async {
                    const url =
                        'https://github.com/niccoreyes/PediaFluid/releases';
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  icon: const Icon(Icons.android)),
              androidWebOnlyCheck: true),
          webOnlyWidget(IconButton(
              tooltip: 'Open Patient GSheets',
              onPressed: () async {
                const url =
                    'https://docs.google.com/spreadsheets/d/1Z1nj_Cfn937DAzdkggM4JEg4yFvxgNAJWXW5CwysPMw/edit?usp=sharing';
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  throw 'Could not launch $url';
                }
              },
              icon: const Icon(Icons.table_chart))),
          IconButton(
              tooltip: 'Clear Fields',
              onPressed: () {
                for (String keys in initVal.keys) {
                  _formKey.currentState?.fields[keys]?.didChange("");
                }
              },
              icon: const Icon(Icons.clear)),
          IconButton(
              tooltip: 'Load Previous Patient',
              onPressed: _loadPatient,
              icon: const Icon(Icons.download))
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
                      formRadio(null, 'Shift',
                          ['Shift (6-2)', 'Shift (2-10)', 'Daily', 'Custom']),
                      formRadio(
                          'Had Febrile episode?', 'Febrile', ['No', 'Yes']),
                      formRadio('First month of life (NICU)', 'isNewborn',
                          ['No', 'Yes'],
                          labelFont: 14, labelOption: 14),
                      formRadio('Full Keyboard (No = numeric)', 'keyboard',
                          ['Yes', 'No'],
                          labelFont: 14, labelOption: 14),
                      // formRadio(
                      //     'Is Nephro Patient?', 'Nephro', ['Yes', 'No']),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Card(
                              margin: const EdgeInsets.all(3),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Column(children: [
                                  for (String keys in initVal.keys)
                                    formBuilderText(keys,
                                        suffixButton: getSuffixButton(keys)),
                                ]),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Card(
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * .30,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible:
                                            textName.data == "" ? false : true,
                                        child: textName,
                                      ),
                                      textVitals.data != ""
                                          ? textVitals
                                          : const SizedBox.shrink(),
                                      textInputoutput,
                                      textUrineoutput,
                                      textOral.data != ""
                                          ? textOral
                                          : const SizedBox.shrink(),
                                      textFluidbalance,
                                      textBowelmovement,
                                      Visibility(
                                          visible:
                                              textHeightweightcheck.data == ""
                                                  ? false
                                                  : true,
                                          child: textHeightweightcheck),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ElevatedButton(
                                          onPressed: () async {
                                            var name = (formVal?['Name'] ?? "");
                                            if (name != "") {
                                              name += "\n";
                                            }
                                            await Clipboard.setData(
                                                ClipboardData(
                                                    // ignore: prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings
                                                    text: "${textName.data}\n" +
                                                        getShift() +
                                                        "${textVitals.data}${textVitals.data != "" ? "\n" : ""}" +
                                                        "${textInputoutput.data},${textOral.data}${textOral.data == "" ? "" : " "}${textOral.data == "" ? " " : ", "}${textFluidbalance.data}, ${textUrineoutput.data}, ${textBowelmovement.data}\n" +
                                                        "${textHeightweightcheck.data}")); //${textInsensiblelosses.data}
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                duration:
                                                    Duration(milliseconds: 500),
                                                content: Text("Copied"),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            "Clipboard",
                                            style: TextStyle(fontSize: 10),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onLongPress: () async {
                                  await Clipboard.setData(ClipboardData(
                                      text:
                                          """${textBodySurfaceArea.data}, ${textInsensiblelosses.data}""")); //${textInsensiblelosses.data}
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      duration: Duration(milliseconds: 500),
                                      content: Text("Copied"),
                                    ),
                                  );
                                },
                                child: Card(
                                  child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .30,
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("Extras not copied:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          const Text("(hold to copy)",
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic)),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          textBodySurfaceArea,
                                          textInsensiblelosses,
                                          textPeekExpiratoryEstimate(),
                                          textABL()
                                        ],
                                      )),
                                ),
                              )
                            ],
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
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Patient',
        onPressed: () {
          _showAddDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
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

                  // makes sure no empty cells are added
                  String spaceSafety(String text, {String labelText = "0"}) {
                    String safeText = text;
                    if (text == "") {
                      safeText = labelText;
                    }
                    return safeText;
                  }

                  var nameText =
                      spaceSafety(controllerName.text, labelText: "Untitled");
                  var heightText = spaceSafety(controllerHeight.text);
                  var weightText = spaceSafety(controllerWeight.text);

                  // add the data to the Google Sheets
                  await sheet?.values
                      .appendRow([nameText, heightText, weightText]);
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
