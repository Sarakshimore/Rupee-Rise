import 'package:flutter/material.dart';
import 'dart:async';

//Product Finder screen
class InvestmentProduct {
  final String name;
  final String category; // "Stocks", "Mutual Funds", or "ETFs"
  final double oneDayReturn;
  final double oneWeekReturn;
  final double oneMonthReturn;

  InvestmentProduct({
    required this.name,
    required this.category,
    required this.oneDayReturn,
    required this.oneWeekReturn,
    required this.oneMonthReturn,
  });
}

class ProductFinderScreen extends StatefulWidget {
  @override
  _ProductFinderScreenState createState() => _ProductFinderScreenState();
}

class _ProductFinderScreenState extends State<ProductFinderScreen> {
  List<InvestmentProduct> products = [];
  bool isLoading = true;

  // Simulate fetching products from an external API.
  Future<void> fetchProducts() async {
    // Simulate a network delay.
    await Future.delayed(Duration(seconds: 2));
    List<InvestmentProduct> fetchedProducts = [
      InvestmentProduct(
        name: 'Reliance Industries',
        category: 'Stocks',
        oneDayReturn: 1.2,
        oneWeekReturn: 2.5,
        oneMonthReturn: 5.0,
      ),
      InvestmentProduct(
        name: 'HDFC Bank',
        category: 'Stocks',
        oneDayReturn: -0.5,
        oneWeekReturn: 1.0,
        oneMonthReturn: 3.5,
      ),
      InvestmentProduct(
        name: 'ICICI Prudential MF',
        category: 'Mutual Funds',
        oneDayReturn: 0.8,
        oneWeekReturn: 1.5,
        oneMonthReturn: 4.0,
      ),
      InvestmentProduct(
        name: 'Nippon India ETF',
        category: 'ETFs',
        oneDayReturn: 1.0,
        oneWeekReturn: 2.0,
        oneMonthReturn: 6.0,
      ),
      // Add more dummy products as needed.
    ];
    setState(() {
      products = fetchedProducts;
      isLoading = false;
    });
  }

  // Filter options.
  final List<String> categories = ['Stocks', 'Mutual Funds', 'ETFs'];
  final List<String> returnRanges = ['<0%', '0-5%', '>5%'];
  final List<String> timeframes = ['1D', '1W', '1M'];

  // Selected filters.
  Set<String> selectedCategories = {};
  Set<String> selectedReturnRanges = {};
  String selectedTimeframe = '1D';

  // Helper to convert a return value to a range string.
  String getReturnRange(double value) {
    if (value < 0) return '<0%';
    if (value <= 5) return '0-5%';
    return '>5%';
  }

  // Build a filter section with FilterChip widgets.
  Widget buildFilterSection(
      String title, List<String> options, Set<String> selected, Function(String, bool) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: options
              .map((option) => FilterChip(
            label: Text(option),
            selected: selected.contains(option),
            onSelected: (isSelected) => onSelected(option, isSelected),
            selectedColor: Colors.green,
          ))
              .toList(),
        ),
      ],
    );
  }

  // Build a toggle for selecting the timeframe.
  Widget buildTimeframeToggle() {
    return Wrap(
      spacing: 8.0,
      children: timeframes.map((tf) {
        bool isSelected = tf == selectedTimeframe;
        return ChoiceChip(
          label: Text(tf),
          selected: isSelected,
          selectedColor: Colors.green,
          onSelected: (_) {
            setState(() {
              selectedTimeframe = tf;
            });
          },
        );
      }).toList(),
    );
  }

  // Build a card widget for an investment product without the "Invest Now" button.
  Widget buildProductCard(InvestmentProduct product) {
    // Get the return value based on the selected timeframe.
    double displayReturn;
    if (selectedTimeframe == '1D') {
      displayReturn = product.oneDayReturn;
    } else if (selectedTimeframe == '1W') {
      displayReturn = product.oneWeekReturn;
    } else {
      displayReturn = product.oneMonthReturn;
    }
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Category: ${product.category}'),
            Text('Return ($selectedTimeframe): ${displayReturn.toStringAsFixed(2)}%'),
            // "Invest Now" button removed.
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    // Apply filters on the products.
    List<InvestmentProduct> filteredProducts = products.where((product) {
      bool categoryMatch =
          selectedCategories.isEmpty || selectedCategories.contains(product.category);
      double returnValue;
      if (selectedTimeframe == '1D') {
        returnValue = product.oneDayReturn;
      } else if (selectedTimeframe == '1W') {
        returnValue = product.oneWeekReturn;
      } else {
        returnValue = product.oneMonthReturn;
      }
      bool returnMatch = selectedReturnRanges.isEmpty ||
          selectedReturnRanges.contains(getReturnRange(returnValue));
      return categoryMatch && returnMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Investment Screener'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset Type Filter
            buildFilterSection('Asset Type', categories, selectedCategories,
                    (option, isSelected) {
                  setState(() {
                    if (isSelected) {
                      selectedCategories.add(option);
                    } else {
                      selectedCategories.remove(option);
                    }
                  });
                }),
            SizedBox(height: 16),
            // Timeframe Toggle
            Text('Select Timeframe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            buildTimeframeToggle(),
            SizedBox(height: 16),
            // Return Range Filter
            buildFilterSection('Return Range ($selectedTimeframe)', returnRanges,
                selectedReturnRanges, (option, isSelected) {
                  setState(() {
                    if (isSelected) {
                      selectedReturnRanges.add(option);
                    } else {
                      selectedReturnRanges.remove(option);
                    }
                  });
                }),
            SizedBox(height: 16),
            // Display Filtered Products
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(child: Text('No products match the filters.'))
                  : ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) => buildProductCard(filteredProducts[index]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
