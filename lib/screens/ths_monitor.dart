import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:foka_hub_build/main.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class THSMonitor extends StatefulWidget {
  const THSMonitor({Key? key}) : super(key: key);

  static const String id = 'ths_monitor';

  @override
  State<THSMonitor> createState() => _THSMonitorState();
}

class _THSMonitorState extends State<THSMonitor> with SingleTickerProviderStateMixin {
  List dropdownItemList = [
    {'label': 'THS Monitor 1', 'value': 'FKB001THS'},
    {'label': 'THS Monitor 2', 'value': 'FKB002THS'},
    {'label': 'THS Monitor 3', 'value': 'FKB003THS'},
    {'label': 'THS Monitor 4', 'value': 'FKB004THS'}, // label is required and unique
    {'label': 'THS Monitor 5', 'value': 'FKB005THS'},
    {'label': 'THS Monitor 6', 'value': 'FKB006THS'},
    {'label': 'THS Monitor 7', 'value': 'FKB007THS'},
  ];

  String deviceId = 'FKB001THS';

  double temperature = 20.0;
  int temperatureLowerValue = 10;
  int temperatureUpperValue = 30;

  double humidity = 20.0;
  int humidityLowerValue = 10;
  int humidityUpperValue = 30;

  int gas = 5000;
  int gasLowerValue = 4000;
  int gasUpperValue = 6000;

  bool showSpinner = true;
  int ths = 30;

  late AnimationController _animationController;
  late Animation _animation;

  late MqttServerClient client;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (ths-- < 0) showSpinner = true;
    });

    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    void start() async {
      await connectClient();
      client.subscribe("/$deviceId", MqttQos.atLeastOnce);
    }

    start();
  }

  Future<MqttServerClient> connectClient() async {
    client = MqttServerClient.withPort('164.52.212.96', MyApp.clientId, 1883);
    client.logging(on: true);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onUnsubscribed = onUnsubscribed;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;
    client.keepAlivePeriod = 20;

    final connMessage = MqttConnectMessage()
        .authenticateAs('admin', 'smartboat@rec&adr')
        // ignore: deprecated_member_use
        .withClientIdentifier(MyApp.clientId)
        .keepAliveFor(6000)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('catch');
      print('Exception: $e');
      client.disconnect();
    }

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);

      print('Received message:$payload from topic: ${c[0].topic}>');

      List parts = payload.split(',');
      print("message_received : $parts");

      showSpinner = false;
      ths = 30;

      gas = int.parse(parts[0]);
      temperature = double.parse(parts[1]);
      humidity = double.parse(parts[2]) <= 100 ? double.parse(parts[2]) : 100;
      setState(() {});
    });

    return client;
  }

  // connection succeeded
  void onConnected() {
    print('Connected');
  }

// unconnected
  void onDisconnected() {
    print('Disconnected');
  }

// subscribe to topic succeeded
  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

// subscribe to topic failed
  void onSubscribeFail(String topic) {
    print('Failed to subscribe $topic');
  }

// unsubscribe succeeded
  void onUnsubscribed(String? topic) {
    print('Unsubscribed topic: $topic');
  }

// PING response received
  void pong() {
    print('Ping response client callback invoked');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff090f13),
      appBar: AppBar(
        backgroundColor: const Color(0xff090f13),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: CoolDropdown(
          dropdownList: dropdownItemList,
          onChange: (item) async {
            setState(() {
              deviceId = item['value'];
              showSpinner = true;
            });
            await connectClient();
            client.subscribe('/$deviceId', MqttQos.atLeastOnce);
          },
          defaultValue: dropdownItemList[0],
          dropdownItemAlign: Alignment.center,
          resultAlign: Alignment.center,
          dropdownBD: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          selectedItemBD: BoxDecoration(
            color: const Color(0xff090f13),
            borderRadius: BorderRadius.circular(10),
          ),
          selectedItemTS: const TextStyle(color: Color(0xFF6FCC76), fontSize: 20),
          unselectedItemTS: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
          resultBD: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xff090f13),
          ),
          resultTS: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
          isTriangle: false,
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.black,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Container(
                  // width: 200,
                  // height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          temperature.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // const SizedBox(
                        //   width: 20.0,
                        //   child: Divider(
                        //     thickness: 2,
                        //     color: Colors.blue,
                        //   ),
                        // ),
                        const Text(
                          "°C",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 27, 28, 30),
                    boxShadow: [
                      BoxShadow(
                          // color: Color.fromARGB(130, 237, 125, 58),
                          color: temperature > temperatureLowerValue
                              ? Colors.red
                              : temperature < temperature
                                  ? Colors.red
                                  : Colors.blue,
                          blurRadius: _animation.value,
                          spreadRadius: _animation.value)
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  // width: MediaQuery.of(context).size.width * 0.85,
                  height: 200,
                  decoration: BoxDecoration(
                    // color: Colors.white12,
                    color: const Color(0xff1d2429),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        // color: Color.fromARGB(130, 237, 125, 58),
                        color: Colors.white,
                        blurRadius: 7.5 - _animation.value * 0.5,
                        spreadRadius: 7.5 - _animation.value * 0.5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          "Humidity",
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/humidity.png',
                              height: 35,
                              width: 35,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              humidity.toStringAsFixed(1) + " %",
                              style: const TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Container(
                  // width: 200,
                  // height: 200,
                  child: Center(
                    child: Text(
                      gas < gasLowerValue
                          ? 'Low'
                          : gas < gasUpperValue
                              ? 'Medium'
                              : 'High',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 27, 28, 30),
                    boxShadow: [
                      BoxShadow(
                          // color: Color.fromARGB(130, 237, 125, 58),
                          color: gas < gasLowerValue
                              ? Colors.green
                              : gas < gasUpperValue
                                  ? Colors.yellow
                                  : Colors.red,
                          blurRadius: _animation.value,
                          spreadRadius: _animation.value)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
