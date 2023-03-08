// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pedia_table/main.dart';
import 'package:gsheets/gsheets.dart';

void main() {
  test('calcu height', () {
    double hundredToAdd = 0;
    double height = 120;
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
    // print(
    //     'Calculation ($hundredToAdd x 100) + ($divisible10 x 50) + ($remain / 10 x 50)');
    // print(
    //     'Estimated Peak Expiratory Flow Rate: $estimatedPeakExpiratoryFlowRate');
  });
  test("Map test", () {
    const Map<String, dynamic> textField = {"Name": TextInputType.text};
    // print(textField["Name"]);
    // print(textField["ok"]);
  });
  test("Map test", () {
    Map<String, dynamic> formVal = {"Shift": "Shift (6-10)"};
    String input = formVal['Shift'] ?? "";
    String output = input.replaceAll(RegExp(r'^Shift '), '');
    print(output);
  });

  test("Temp test", () {
    RegExp regex = RegExp(r'^(\d+)(?!\s*C)');
    String input = "39-38C last febrile episode 1/2/2023";
    String output = input.replaceFirst(regex, r'$1°C');
    print(output);
  });
  test("has Decimal test", () {
    double doubleFluidBalance = 0.32 - 300.32;
    String stringFluidBalance = "";
    if (doubleFluidBalance > 0) {
      stringFluidBalance += "+";
    }
    bool hasDecimal(String str) {
      return str.contains(".00");
    }

    stringFluidBalance = doubleFluidBalance.toStringAsFixed(2);

    print("+479.03".replaceAll(RegExp(r'\.00$'), '')); // true
    print(stringFluidBalance.replaceAll(RegExp(r'\.00$'), '')); // false
  });
}
