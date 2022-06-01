import 'package:flutter/material.dart';
import 'package:foka_hub_build/screens/ths_monitor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String id = 'home_screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff090f13),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  DeviceCard(
                    icon: const Icon(
                      Icons.thermostat_rounded,
                      size: 44,
                    ),
                    deviceName: 'THS Monitor',
                    color: Colors.pink,
                    onTap: () {
                      Navigator.pushNamed(context, THSMonitor.id);
                    },
                  ),
                  DeviceCard(
                    icon: const Icon(
                      Icons.water,
                      size: 44,
                    ),
                    deviceName: 'Ultrasonic Sensor',
                    color: Colors.blue,
                    onTap: () {},
                  ),
                  DeviceCard(
                    icon: const Icon(
                      Icons.water_damage_outlined,
                      size: 44,
                    ),
                    deviceName: 'Float Sensor',
                    color: Colors.purple.shade300,
                    onTap: () {},
                  ),
                  DeviceCard(
                    icon: const Icon(
                      Icons.connect_without_contact,
                      size: 44,
                    ),
                    deviceName: 'Smart Connect',
                    color: Colors.orange.shade400,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  DeviceCard(
                    icon: const Icon(
                      Icons.location_on_outlined,
                      size: 44,
                    ),
                    deviceName: 'Location Tracker',
                    color: Colors.yellow.shade600,
                    onTap: () {},
                  ),
                  DeviceCard(
                    icon: const Icon(
                      Icons.thermostat_rounded,
                      size: 44,
                    ),
                    deviceName: 'Security Monitor',
                    color: Colors.lightGreen,
                    onTap: () {},
                  ),
                  DeviceCard(
                    icon: const Icon(
                      Icons.thermostat_rounded,
                      size: 44,
                    ),
                    deviceName: 'Battery Monitor',
                    color: Colors.redAccent.shade100,
                    onTap: () {},
                  ),
                  DeviceCard(
                    icon: const Icon(
                      Icons.door_sliding_outlined,
                      size: 44,
                    ),
                    deviceName: 'Door Monitor',
                    color: Colors.white70,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  // const DeviceCard({
  //   Key? key,
  // }) : super(key: key);

  const DeviceCard({required this.icon, required this.deviceName, required this.color, required this.onTap});

  final Icon icon;
  final String deviceName;
  final Color color;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: color,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(
                  height: 20,
                ),
                Text(
                  deviceName,
                  style: const TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
