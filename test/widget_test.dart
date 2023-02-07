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
  test('GsheetRead', () async {
    const _credentials = r'''
{
  "type": "service_account",
  "project_id": "gsheets-377016",
  "private_key_id": "eadc1e334528f56911d14a0835585105ad5b3814",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDENW3Ty7cBudFL\nwB7EcCmz/b2XWi4OuicGbqG7eVesXFJb6VEJtoCcMXBAPF1ASf9Kqr5cTIz4My2b\nbhLbuzC0vSkKjg/H22gF7ioh83aOizoS4KOV5AN6rt4Owv1D/M2g78C8YqPEkrNs\nYl1BRQ2/w0C+4/NrjDKjGqGHiGMsp355nTBPwFLmlZzFINANqbC4KS0KiszQidDV\nizdoCqzMswCyAdCUDGNENU8bJEUIa1EO/svKou0GRgnhhcotbHEygxMzGpZ++WLy\n2LBrh6daWuHizPpjELd63lh8EnvNVrOdOMoFbxtYWhpQfAEP6sBTlYtS0gy25c0z\nVbPVUsYtAgMBAAECggEACKm5lOjxG617i8jqgtlXRLLEGMc68ocDu0FjY4PkHACC\nhBDdNVzTuQcSHJ/zAmg8p5cPgG3tKSCXV6i97T+KqGbpWuWIAFa+tR5SyWd2uVdK\ng96xElM8LRdEnNRn+sUSGNQ6cgbikga5JHoDrI1S4f/fX15GAd5cNlPcxGoVmOPO\nF1BizZe3LTZM1O/HWqOjUaaeSClp/qrx3wnIuygCRUMQUOw93mCeNaTRZk4MKiro\nyJF/LXgjkkiXZ48IhlvptN07MpGEEuJJNGwoDe45y96juK0HPrIzLKZhdGp7J0aC\nXNu8G6RHN9I4yPfWi2jmdHAt8IuPRNZGrdfiocbRGQKBgQD2ixaT817MSGtUvluN\niI911iyvTFBG7auJApCGnUSXMuXKLb3U805aOJ2GtcfRUPjgJLhaXEnOAzC4U/Xq\nh275NJNzn+s15nxLf7tuqXWJHsKv1nwY4g0HHasNPDOD3FY0IJJBS9Nt7jPuKQ/0\n0/wjipPy8ebT4c1qp0/BhLLKOQKBgQDLvBWT81lIEyYY4S61AIkrdK2Dm+ntHjOD\nG+cqiMg+YII/m7pARXaBdiPJCKtwEBbL0lsMyksysGgpuFfx3ksF5eRaPQCQMeOD\nA0ETPmo7AdIi6ANbdPy2DAIOvtsEnUk5ZGpYzJDcAh6Coghnz079/Ezup8jf5eiD\nVHMySaerlQKBgDSFEq031gT8lGi8GHLBGZaHpoM9ZYiGjtkkA7e5fugavprgPaVE\no3dSwjP1O3jan/nXuLH/IPXS9ij+Mc/hRAGwcozaD1gvHmFS95GuZcxtEho1PcBr\nP005w7uRDIRVhsOaAK4KQiMT8FoWw0BrfDXyCmxhncObQZArzjCyXQf5AoGBAMel\nkoefaphkm2q6ECkzUzgQaJCV0xCYDeanC0r1KzVlIX3vvv6Ik26eNMcmBcoVGiG2\nC59nBXWwxQJNMXFFYsNu2u1K5ihnmwmhwL145mTYjfHC5rdS1uoWrlWA1eOZtk3V\nhxlprXLLaNaerhn8Xu4ptcIRDZnLFKTNtu1KnFJZAoGADw9zulpdb+hgfcy1OOKq\nbAiA4y4S1zdUYfb6JCwJlLQlE6uECqb7V1cJnSVC1C8k0+tHZ7g3sA9s9E2l/T5V\nmLlg6bSMdieUYVnqSAfjQbwyvzKzg6aPou2o7d4qFEkHsjM/DXENK5HLiUStqVOj\n1iw0J2KNL3ZsmD0b4Navlh4=\n-----END PRIVATE KEY-----\n",
  "client_email": "gsheets@gsheets-377016.iam.gserviceaccount.com",
  "client_id": "103508671000754806052",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets%40gsheets-377016.iam.gserviceaccount.com"
}
''';

    /// Your spreadsheet id
    ///
    /// It can be found in the link to your spreadsheet -
    /// link looks like so https://docs.google.com/spreadsheets/d/YOUR_SPREADSHEET_ID/edit#gid=0
    /// [YOUR_SPREADSHEET_ID] in the path is the id your need
    const _spreadsheetId = '1Z1nj_Cfn937DAzdkggM4JEg4yFvxgNAJWXW5CwysPMw';
    // Build our app and trigger a frame.
    final gsheets = GSheets(_credentials);
    // fetch spreadsheet by its id
    final ss = await gsheets.spreadsheet(_spreadsheetId);
    final sheet = await ss.worksheetByTitle('PatientList');
    //await sheet?.values.appendRow(["_name", "_height", "_weight"]);
    print(await sheet?.values.column(1) ?? "");
    print(await sheet?.values.column(2) ?? "");
    // print(ss.data.namedRanges.byName.values
    //     .map((e) => {
    //           'name': e.name,
    //           'start':
    //               '${String.fromCharCode((e.range?.startColumnIndex ?? 0) + 97)}${(e.range?.startRowIndex ?? 0) + 1}',
    //           'end':
    //               '${String.fromCharCode((e.range?.endColumnIndex ?? 0) + 97)}${(e.range?.endRowIndex ?? 0) + 1}'
    //         })
    //     .join('\n'));
  });
}
