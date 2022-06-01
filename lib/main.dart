import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http123/user.dart';
import 'package:dio/dio.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

void main() {
  runApp(MaterialApp(
    home: first(),
  ));
}

class first extends StatefulWidget {
  @override
  State<first> createState() => _firstState();
}

class _firstState extends State<first> {
  List<user> l = [];
  Razorpay? razorpay;

  getalldata() async {
    // try {
    //   var response = await Dio().get('https://jsonplaceholder.typicode.com/users');
    //   print(response);
    //
    //   dynamic data=response.data;
    //
    //   data.forEach((d){
    //     setState(() {
    //       l.add(user.fromJson(d));
    //     });
    //
    //   });
    // } catch (e) {
    //   print(e);
    // }

    var url = Uri.parse('https://jsonplaceholder.typicode.com/users');
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    dynamic data = jsonDecode(response.body);

    data.forEach((d) {
      setState(() {
        l.add(user.fromJson(d));
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getalldata();
    razorpay = Razorpay();
    razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    razorpay!.clear();
  }

  void openCheckout(int id) async {
    var options = {
      'key': 'rzp_test_bnPGfYagl0FdBm',
      'amount': id * 100,
      'name': 'Acme Corp.',
      'description': 'Fine T-Shirt',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      razorpay!.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Success Response: $response');
    print("payment id ===============>${response.paymentId}");
    /*Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Error Response: $response');
    print(response.message);
    /* Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External SDK Response: $response');
    /* Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: l.length,
        itemBuilder: (context, index) {
          return ListTile(
              title: Text("${l[index].name}"),
              subtitle: Text("${l[index].email}"),
              leading: Text("${l[index].address!.zipcode}"),
              trailing: ElevatedButton(
                  onPressed: () {
                    openCheckout(l[index].id ?? 0);
                  },
                  child: Text("buy plsssss now")));
        },
      ),
    );
  }
}
