import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:weather/weather.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Future<WeatherResponse> weatherData;

  @override
  void initState() {
    super.initState();
    weatherData = getData();
  }

  Future<WeatherResponse> getData() async {
    var client = http.Client();
    String APIKEY = dotenv.env['API_KEY'] ?? "";
    print(APIKEY);
    try {
      var response = await client.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=bangkok&units=metric&appid=$APIKEY'));
      if (response.statusCode == 200) {
        return WeatherResponse.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception("Failed to load data");
      }
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
            child: FutureBuilder<WeatherResponse>(
                future: weatherData,
                builder: (constext, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.name ?? "",
                          style: const TextStyle(fontSize: 40),
                        ),
                        Text(
                          data.main!.temp!.toString() ?? "0.00",
                        )
                      ],
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                })),
      ),
    );
  }
}
