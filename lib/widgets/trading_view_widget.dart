import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TradingViewWidget extends StatefulWidget {
  const TradingViewWidget({super.key});

  @override
  _TradingViewWidgetState createState() => _TradingViewWidgetState();
}

class _TradingViewWidgetState extends State<TradingViewWidget> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enable JavaScript
      ..setBackgroundColor(const Color(0x00000000));   // Transparent background
    _loadHtmlContent(); // Load content immediately
  }

  void _loadHtmlContent() {
    // Define the HTML content with TradingView script
    String htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="margin:0; padding:0;">
      <div class="tradingview-widget-container" style="width:100%; height:100%;">
        <div class="tradingview-widget-container__widget"></div>
        <div class="tradingview-widget-copyright">
          <a href="https://www.tradingview.com/" rel="noopener nofollow" target="_blank">
            <span class="blue-text">Track all markets on TradingView</span>
          </a>
        </div>
        <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-technical-analysis.js" async>
        {
          "interval": "1m",
          "width": "100%",
          "isTransparent": false,
          "height": "100%",
          "symbol": "NSE:ADANIENT",
          "showIntervalTabs": true,
          "displayMode": "single",
          "locale": "en",
          "colorTheme": "dark"
        }
        </script>
      </div>
    </body>
    </html>
    ''';
    // Load the HTML content into the WebView
    _controller.loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}