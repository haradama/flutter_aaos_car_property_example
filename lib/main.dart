import 'package:flutter/material.dart';
import 'car_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Control',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Car Night Mode & Cabin Lights Control'),
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
  bool _isNightMode = false; // Variable to store night mode status
  int _cabinLightState = 0; // Variable to store cabin light state
  bool _initialized = false; // Initialization state
  final CarService _carService = CarService(); // Instance of CarService

  @override
  void initState() {
    super.initState();
    _initializeCarManager(); // Initialize CarService when the widget is loaded
  }

  // Initialize the CarService and get the initial night mode status
  Future<void> _initializeCarManager() async {
    await _carService.initializeCarManager();
    setState(() {
      _initialized = true; // Mark as initialized after completion
    });
    _getNightModeStatus(); // Fetch the night mode status after initialization
  }

  // Fetch the night mode status from the car
  Future<void> _getNightModeStatus() async {
    final bool? value =
        await _carService.getCarProperty(0x11200407, 0) as bool?;
    if (value != null) {
      setState(() {
        debugPrint(
            value.toString()); // Print the night mode value for debugging
        _isNightMode = value; // Update the UI with the fetched value
      });
    }
  }

  // Set the cabin light state based on the user selection
  Future<void> _setCabinLight(int state) async {
    await _carService.setCarProperty(0x11400f02, 0, state);
    setState(() {
      _cabinLightState = state; // Update the UI with the new cabin light state
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isNightMode
          ? ThemeData.dark() // Use dark theme if night mode is ON
          : ThemeData.light(), // Use light theme if night mode is OFF
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: _initialized
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Car Night Mode Status:'),
                    Text(
                      _isNightMode
                          ? "Night Mode ON"
                          : "Night Mode OFF", // Display night mode status
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                          _getNightModeStatus, // Update night mode status when clicked
                      child: const Text('Get Night Mode Status'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Cabin Lights:'),
                    DropdownButton<int>(
                      value:
                          _cabinLightState, // Current selected cabin light state
                      items: const [
                        DropdownMenuItem(
                          value: 0,
                          child: Text('OFF'),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('ON'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('Daytime Running'),
                        ),
                        DropdownMenuItem(
                          value: 0x100,
                          child: Text('Automatic'),
                        ),
                      ],
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          _setCabinLight(
                              newValue); // Set the new cabin light state
                        }
                      },
                    ),
                    Text(
                      _cabinLightState == 0
                          ? "Cabin Light OFF"
                          : _cabinLightState == 1
                              ? "Cabin Light ON"
                              : _cabinLightState == 2
                                  ? "Daytime Running"
                                  : "Automatic", // Display the current cabin light state
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                )
              : const CircularProgressIndicator(), // Show loading indicator while initializing
        ),
      ),
    );
  }
}
