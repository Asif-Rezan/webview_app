import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../../app/config/app_config.dart';
import '../../viewmodel/home_viewmodel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum _WebViewStatus { loading, loaded, error }

enum _ErrorType { ssl, http, unknown }

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final WebViewController _controller;

  _WebViewStatus _status = _WebViewStatus.loading;
  _ErrorType _errorType = _ErrorType.unknown;
  String _errorDescription = '';
  int _loadProgress = 0;
  bool _isRefreshing = false;

  // RefreshIndicator needs a GlobalKey to trigger programmatically
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  Timer? _progressDebounce;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void dispose() {
    _progressDebounce?.cancel();
    super.dispose();
  }

  // ── Controller init ────────────────────────────────────────────────────────

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..enableZoom(false)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10) '
            'AppleWebKit/537.36 (KHTML, like Gecko) '
            'Chrome/120.0.0.0 Mobile Safari/537.36 '
            '${AppConfig.appName}/${AppConfig.appVersion}',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: _onPageStarted,
          onPageFinished: _onPageFinished,
          onProgress: _onProgress,
          onWebResourceError: _onWebResourceError,
          onNavigationRequest: _onNavigationRequest,
          onHttpError: _onHttpError,
        ),
      )
      ..loadRequest(
        Uri.parse(AppConfig.webviewUrl),
        headers: _defaultHeaders,
      );
  }

  Map<String, String> get _defaultHeaders => {
    'Accept-Language': 'en-US,en;q=0.9',
    'X-App-Version': AppConfig.appVersion,
    'X-App-Name': AppConfig.appName,
  };

  // ── Navigation delegate callbacks ─────────────────────────────────────────

  void _onPageStarted(String url) {
    if (!mounted) return;
    setState(() {
      _status = _WebViewStatus.loading;
      _isRefreshing = false;
    });
  }

  void _onPageFinished(String url) async {
    if (!mounted) return;

    // Enforce non-zoomable viewport for native feel
    await _controller.runJavaScript(
      "var m = document.querySelector('meta[name=\"viewport\"]');"
          "if(m) m.setAttribute('content',"
          "'width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no');",
    );

    if (mounted) {
      setState(() {
        _status = _WebViewStatus.loaded;
        _loadProgress = 100;
      });
    }
  }

  void _onProgress(int progress) {
    _progressDebounce?.cancel();
    _progressDebounce = Timer(const Duration(milliseconds: 16), () {
      if (mounted) setState(() => _loadProgress = progress);
    });
  }

  void _onWebResourceError(WebResourceError error) {
    // Ignore sub-resource errors (ads, fonts, tracking pixels, etc.)
    if (error.isForMainFrame != true) return;
    if (!mounted) return;

    final type = switch (error.errorCode) {
      -202 || -203 || -200 => _ErrorType.ssl,
      _ => _ErrorType.unknown,
    };

    setState(() {
      _status = _WebViewStatus.error;
      _errorType = type;
      _errorDescription = error.description;
    });
  }

  void _onHttpError(HttpResponseError error) {
    if (!mounted) return;
    final code = error.response?.statusCode ?? 0;
    if (code >= 400) {
      setState(() {
        _status = _WebViewStatus.error;
        _errorType = _ErrorType.http;
        _errorDescription = 'HTTP $code';
      });
    }
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.prevent;
    // Block non-http(s) schemes (tel:, mailto:, intent:, etc.)
    if (uri.scheme != 'https' && uri.scheme != 'http') {
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Called by RefreshIndicator — awaits page reload completion.
  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
      _status = _WebViewStatus.loading;
      _loadProgress = 0;
    });
    await _controller.reload();

    // Wait until the page finishes (status flips to loaded/error)
    // with a safety timeout so the spinner never hangs forever.
    const timeout = Duration(seconds: 15);
    const interval = Duration(milliseconds: 100);
    var elapsed = Duration.zero;
    while (_status == _WebViewStatus.loading && elapsed < timeout) {
      await Future.delayed(interval);
      elapsed += interval;
    }
  }

  Future<void> _loadHome() async {
    setState(() {
      _status = _WebViewStatus.loading;
      _loadProgress = 0;
    });
    await _controller.loadRequest(
      Uri.parse(AppConfig.webviewUrl),
      headers: _defaultHeaders,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
        theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: cs.surface,
        systemNavigationBarIconBrightness:
        theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Column(
            children: [
              _buildProgressBar(cs),
              Expanded(child: _buildBody(theme, cs)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Progress bar ───────────────────────────────────────────────────────────

  Widget _buildProgressBar(ColorScheme cs) {
    final visible = _status == _WebViewStatus.loading;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: visible ? 3 : 0,
      child: visible
          ? TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _loadProgress / 100),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        builder: (_, value, __) => LinearProgressIndicator(
          value: value < 0.95 ? value : null,
          backgroundColor: Colors.transparent,
          color: cs.primary,
          minHeight: 3,
        ),
      )
          : const SizedBox.shrink(),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody(ThemeData theme, ColorScheme cs) {
    return Stack(
      children: [
        // WebView fills the entire body — owns all scroll gestures.
        WebViewWidget(controller: _controller),

        // Pull-to-refresh overlay: sits on top but is fully transparent
        // to touches except for the drag-down gesture at y=0.
        _PullToRefresh(
          refreshKey: _refreshKey,
          onRefresh: _onRefresh,
          color: cs.primary,
          backgroundColor: cs.surface,
        ),

        // First-load shimmer (not shown during pull-to-refresh)
        if (_status == _WebViewStatus.loading &&
            _loadProgress < 25 &&
            !_isRefreshing)
          _FirstLoadOverlay(cs: cs),

        // Error state
        if (_status == _WebViewStatus.error)
          _ErrorOverlay(
            errorType: _errorType,
            description: _errorDescription,
            onRetry: () => _refreshKey.currentState?.show(),
            onGoHome: _loadHome,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pull-to-refresh overlay
//
// WebViewWidget owns its own scroll view internally, so wrapping it in a
// Flutter ScrollView breaks native web scrolling. Instead, we overlay a
// transparent RefreshIndicator-backed widget that only responds to the
// overscroll drag gesture at the very top of the screen, leaving all other
// touch/scroll events to pass through to the WebView.
// ─────────────────────────────────────────────────────────────────────────────

class _PullToRefresh extends StatelessWidget {
  final GlobalKey<RefreshIndicatorState> refreshKey;
  final Future<void> Function() onRefresh;
  final Color color;
  final Color backgroundColor;

  const _PullToRefresh({
    required this.refreshKey,
    required this.onRefresh,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: refreshKey,
      onRefresh: onRefresh,
      displacement: 48,
      strokeWidth: 2.5,
      color: color,
      backgroundColor: backgroundColor,
      // A single-item ListView that is invisible and non-interactive.
      // It provides the scroll context RefreshIndicator needs without
      // intercepting any touch events intended for the WebView below.
      child: IgnorePointer(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox.shrink()],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// First-load shimmer
// ─────────────────────────────────────────────────────────────────────────────

class _FirstLoadOverlay extends StatefulWidget {
  final ColorScheme cs;
  const _FirstLoadOverlay({required this.cs});

  @override
  State<_FirstLoadOverlay> createState() => _FirstLoadOverlayState();
}

class _FirstLoadOverlayState extends State<_FirstLoadOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    final base = cs.surfaceContainerHighest.withOpacity(0.45);
    final highlight = cs.surfaceContainerHighest.withOpacity(0.9);

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) {
        final gradient = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.5, 1.0],
          colors: [base, highlight, base],
          transform: _SlideGradient(_shimmer.value),
        );
        return Container(
          color: cs.surface,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(
                  gradient: gradient,
                  width: double.infinity,
                  height: 180,
                  radius: 14),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: _ShimmerBox(
                          gradient: gradient, height: 100, radius: 10)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _ShimmerBox(
                          gradient: gradient, height: 100, radius: 10)),
                ],
              ),
              const SizedBox(height: 20),
              for (var i = 0; i < 5; i++) ...[
                Row(
                  children: [
                    _ShimmerBox(
                        gradient: gradient,
                        width: 48,
                        height: 48,
                        radius: 10),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ShimmerBox(
                              gradient: gradient,
                              width: double.infinity,
                              height: 13,
                              radius: 6),
                          const SizedBox(height: 6),
                          _ShimmerBox(
                              gradient: gradient,
                              width: 120,
                              height: 11,
                              radius: 6),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final LinearGradient gradient;
  final double? width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.gradient,
    this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _SlideGradient extends GradientTransform {
  final double value;
  const _SlideGradient(this.value);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
        bounds.width * 2 * (value - 0.5), 0, 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error overlay
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorOverlay extends StatelessWidget {
  final _ErrorType errorType;
  final String description;
  final VoidCallback onRetry;
  final VoidCallback onGoHome;

  const _ErrorOverlay({
    required this.errorType,
    required this.description,
    required this.onRetry,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final (icon, title, body) = switch (errorType) {
      _ErrorType.ssl => (
      Icons.security_rounded,
      'Connection is not private',
      'This page has a certificate or security issue.',
      ),
      _ErrorType.http => (
      Icons.error_outline_rounded,
      'Page unavailable',
      'The server returned an error ($description).',
      ),
      _ErrorType.unknown => (
      Icons.browser_not_supported_outlined,
      'Something went wrong',
      description.isNotEmpty ? description : 'Unable to load this page.',
      ),
    };

    return Container(
      color: cs.surface,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: cs.errorContainer.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: cs.error),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onGoHome,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: cs.outlineVariant),
              ),
              child: const Text('Go to home page'),
            ),
          ),
        ],
      ),
    );
  }
}