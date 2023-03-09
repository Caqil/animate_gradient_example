import 'dart:isolate';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

void main() => runApp(FlutterFluxApp());

class FlutterFluxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isConnected = false;
  final Connectivity _connectivity = Connectivity();
  ReceivePort _port = ReceivePort();
  @override
  void initState() {
    super.initState();
    _prepare();

    _bindConnection();
  }

  void _prepare() async {
    ConnectivityResult connectivityResult =
        await _connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      _noConnectionModal();

      _isConnected = true;
    }

    _connectivity.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.none) {
        _noConnectionModal();

        _isConnected = true;
        return;
      }

      if (_isConnected) {
        Navigator.of(context).pop();

        _isConnected = false;
      }
    });
  }

  Future<void> _noConnectionModal() {
    bool shouldPop = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => shouldPop,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.all(10.0 * 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.all(10.0 * 2),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Icon(Icons.wifi_off_outlined)),
                const SizedBox(height: 10.0 * 2),
                const Text(
                  "No internet connection!",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  "Make sure Wi-Fi or mobile data is turned on then try again",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _bindConnection() {
    bool isSuccess =
        IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader');
    if (!isSuccess) {
      _unbindConnection();
      _bindConnection();
      return;
    }
  }

  void _unbindConnection() {
    IsolateNameServer.removePortNameMapping('downloader');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Image.asset(
            'assets/logo.png',
            height: 30,
          ),
          Text('flutterflux.com')
        ]),
      ),
      body: Center(
        child: Text(
          !_isConnected ? 'Internet Connected' : 'No Internet Connection',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
