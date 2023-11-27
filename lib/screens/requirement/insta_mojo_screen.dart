import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class InstaMojoScreen extends StatefulWidget {
  const InstaMojoScreen({super.key});

  @override
  State<InstaMojoScreen> createState() => _InstaMojoScreenState();
}

class _InstaMojoScreenState extends State<InstaMojoScreen> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  Future createRequest() async {
    print('U N N N N N ');
    Map<String, String> body = {
      "amount": "100", //amount to be paid
      "purpose": "Advertising",
      "buyer_name": "Test test",
      "email": "test@gmail.com",
      "phone": "+911234567890",
      "allow_repeated_payments": "true",
      "send_email": "false",
      "send_sms": "false",
      "redirect_url": "https://www.google.com",
      "webhook": "https://www.google.com"
    };
//First we have to create a Payment_Request.
//then we'll take the response of our request.
    var resp = await http.post(
        Uri.parse("https://test.instamojo.com/api/1.1/payment-requests/"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          "X-Api-Key": "test_d55f74e68ff03b26c33dc1386bc",
          "X-Auth-Token": "test_d06b0e24d9e95fb372551c568ee",
        },
        body: body);
    if (json.decode(resp.body)['success'] == true) {
      print('this is payment details ' + jsonDecode(resp.body).toString());
//If request is successful take the longurl.
      String selectedUrl =
          json.decode(resp.body)["payment_request"]['longurl'].toString();
      //  +  "?embed=form";
      print("this is selectedUrl " + selectedUrl.toString());
      flutterWebviewPlugin.close();
//Let's open the url in webview.
      print("this is selectedUrl open" + selectedUrl.toString());

      flutterWebviewPlugin.launch(selectedUrl,
          supportMultipleWindows: true,
          withZoom: true,
          withOverviewMode: true,
          useWideViewPort: true,
          displayZoomControls: true,
          scrollBar: true,
          rect: Rect.fromLTRB(
              5.0,
              MediaQuery.of(context).size.height / 10,
              MediaQuery.of(context).size.width - 5.0,
              7 * MediaQuery.of(context).size.height / 8),
          userAgent:
              "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36");
      print("this is selectedUrl open done" + selectedUrl.toString());
    } else {
      print(resp.body);
    }
  }

  @override
  void initState() {
    super.initState();
    print('sdsadasds');
    createRequest(); //creating the HTTP request
// Add a listener on url changed
    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        print('this is change url ' + url);
        if (url.contains('https://www.lipsum.com/')) {
          Uri uri = Uri.parse(url);
//Take the payment_id parameter of the url.
          String paymentRequestId = uri.queryParameters['payment_id']!;
          print('this is payment id ' + paymentRequestId);

//calling this method to check payment status
          _checkPaymentStatus(paymentRequestId);
        }
      }
    });
  }

  _checkPaymentStatus(String id) async {
    var response = await http.get(
      Uri.parse("https://t7st.instamojo.com/api/1.1/payments/$id/"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "X-Api-Key": "test_d55f74e68ff03b26c33dc1386bc",
        "X-Auth-Token": "test_d06b0e24d9e95fb372551c568ee",
      },
    );
    var realResponse = json.decode(response.body);
    print("this is real response " + realResponse);
    if (realResponse['success'] == true) {
      if (realResponse["payment"]['status'] == 'Credit') {
//payment is successful.
        print('sucesss');
      } else {
//payment failed or pending.
      }
    } else {
      print(realResponse);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("web view"),
        leading: IconButton(
            onPressed: () {
              flutterWebviewPlugin.close();
              Get.back();
            },
            icon: const Icon(Icons.arrow_back)),
      ),
    );
  }
}
