import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'chat_screen.dart';

class RealTimeIndexScreen extends StatefulWidget {
  const RealTimeIndexScreen({super.key});

  @override
  _RealTimeIndexScreenState createState() => _RealTimeIndexScreenState();
}

class _RealTimeIndexScreenState extends State<RealTimeIndexScreen> {
  late Timer _timer;
  Map<String, dynamic> niftyData = {};
  Map<String, dynamic> sensexData = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchData());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      const niftyUrl =
          "https://query1.finance.yahoo.com/v8/finance/chart/^NSEI?region=IN&lang=en-IN&includePrePost=false&interval=1m&range=1d";
      const sensexUrl =
          "https://query1.finance.yahoo.com/v8/finance/chart/%5EBSESN?region=IN&lang=en-IN&includePrePost=false&interval=1m&range=1d";

      final niftyRes = await http.get(Uri.parse(niftyUrl));
      final sensexRes = await http.get(Uri.parse(sensexUrl));

      if (niftyRes.statusCode == 200 && sensexRes.statusCode == 200) {
        final niftyJson = json.decode(niftyRes.body);
        final sensexJson = json.decode(sensexRes.body);

        if (mounted) {
          setState(() {
            niftyData = _parseIndexData(niftyJson);
            sensexData = _parseIndexData(sensexJson);
          });
        }
      } else {
        print("HTTP error: NIFTY ${niftyRes.statusCode}, SENSEX ${sensexRes.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Map<String, dynamic> _parseIndexData(dynamic data) {
    final result = data['chart']['result'][0];
    final meta = result['meta'];
    final quote = result['indicators']['quote'][0];
    final timestamps = result['timestamp'];

    double price = meta['regularMarketPrice']?.toDouble() ?? 0.0;
    double prevClose = meta['chartPreviousClose']?.toDouble() ?? 0.0;
    double open = quote['open'][0]?.toDouble() ?? 0.0;
    double high = quote['high'][0]?.toDouble() ?? 0.0;
    double low = quote['low'][0]?.toDouble() ?? 0.0;
    double close = quote['close'][0]?.toDouble() ?? 0.0;
    int volume = quote['volume'][0]?.toInt() ?? 0;

    if (price == 0.0) price = close;

    double percentChange = (prevClose != 0.0)
        ? ((price - prevClose) / prevClose) * 100
        : 0.0;

    List<FlSpot> chartData = [];
    if (timestamps != null && quote['close'] != null) {
      for (int i = 0; i < timestamps.length && i < quote['close'].length; i++) {
        if (quote['close'][i] != null) {
          chartData.add(FlSpot(i.toDouble(), quote['close'][i].toDouble()));
        }
      }
    }

    return {
      'price': price,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
      'percentChange': percentChange,
      'chartData': chartData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Market Indexes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        elevation: 4,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          IndexTile(title: "NIFTY 50", data: niftyData),
          const SizedBox(height: 16),
          IndexTile(title: "BSE SENSEX", data: sensexData),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}

class IndexTile extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;

  const IndexTile({required this.title, required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(child: Text("Loading $title...")),
        ),
      );
    }

    double percent = data['percentChange'] ?? 0.0;
    Icon? arrow;
    Color? changeColor;

    if (percent > 0) {
      arrow = const Icon(Icons.arrow_upward, color: Colors.green, size: 18);
      changeColor = Colors.green;
    } else if (percent < 0) {
      arrow = const Icon(Icons.arrow_downward, color: Colors.red, size: 18);
      changeColor = Colors.red;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            SizedBox(
              height: 100, // Reduced height for a more concise graph
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false), // Remove grid lines
                  titlesData: const FlTitlesData(show: false), // Remove all titles
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data['chartData'] ?? [],
                      isCurved: true,
                      color: const Color(0xFF4CAF50),
                      barWidth: 1, // Thinner line
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false), // Remove area below
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            _buildRow("Price", data['price']),
            _buildRow("Open", data['open']),
            _buildRow("High", data['high']),
            _buildRow("Low", data['low']),
            _buildRow("Close", data['close']),
            _buildRow("Volume", data['volume'].toDouble(), isInt: true),
            _buildRow("Change",
                percent, isPercent: true, arrow: arrow, color: changeColor),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double value,
      {bool isPercent = false, bool isInt = false, Icon? arrow, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            if (arrow != null) arrow,
            const SizedBox(width: 4),
            Text(
              isPercent
                  ? "${value.toStringAsFixed(2)}%"
                  : isInt
                  ? value.toInt().toString()
                  : value.toStringAsFixed(2),
              style: TextStyle(color: color),
            ),
          ],
        ),
      ],
    );
  }
}