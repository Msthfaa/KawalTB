import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/app_colors.dart';

/// Screen to read the full article inside an in-app WebView
class ArticleWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const ArticleWebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<ArticleWebViewScreen> createState() => _ArticleWebViewScreenState();
}

class _ArticleWebViewScreenState extends State<ArticleWebViewScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setUserAgent(
        "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36",
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _loadingProgress = 0;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _loadingProgress = 100;
            });
            // Inject CSS to hide common ad elements
            _controller.runJavaScript("""
              (function() {
                var style = document.createElement('style');
                style.innerHTML = 'iframe, .ads, .adsbygoogle, [id*="google_ads"], [class*="advertisement"], [class*="ads-"], [id*="-ad-"], .taboola-ad, .outbrain-ad, a[href*="doubleclick.net"] { display: none !important; }';
                document.head.appendChild(style);
              })();
            """).catchError((e) {
              debugPrint("JS Injection Error: \$e");
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView Error: ${error.description}");
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loadingProgress < 100)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _loadingProgress / 100.0,
                backgroundColor: AppColors.border.withValues(alpha: 0.5),
                color: AppColors.primary,
                minHeight: 3,
              ),
            ),
        ],
      ),
    );
  }
}
