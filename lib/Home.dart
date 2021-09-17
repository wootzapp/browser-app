import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';

bool _initialUriIsHandled = false;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int indexPosition = 1;

  StreamSubscription? _sub;

  String urlTo = 'https://google.lk';

  final urlController = TextEditingController();

  final Completer<WebViewController> _webViewController =
      Completer<WebViewController>();

  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    urlController.text = urlTo;

    _handleIncomingLinks();
    _handleInitialUri();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  void dispose() {
    urlController.dispose();

    _sub?.cancel();

    super.dispose();
  }

  Future<void> _handleInitialUri() async {
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;

      try {
        final uri = await getInitialUri();
        if (uri == null) {
        } else {
          updateWebView(uri.toString());
        }
      } on PlatformException {
        print('falied to get initial uri');
      } on FormatException catch (err) {
        print('malformed initial uri');
      }
    }
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      _sub = uriLinkStream.listen((Uri? uri) {
        updateWebView(uri.toString());
      }, onError: (Object err) {
        print('malformed initial uri' + err.toString());
      });
    }
  }

  Future updateWebView(String url) async {
    controller = await _webViewController.future;
    urlController.text = url;
    controller.loadUrl(url);
  }

  beginLoading(String A) {
    setState(() {
      indexPosition = 1;
    });
  }

  Future<void> loadHtmlFromAssets(String filename, controller) async {
    String fileText = await rootBundle.loadString(filename);
    controller.loadUrl(Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                color: const Color.fromARGB(255, 204, 204, 255),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(children: [
                    Expanded(
                        child: FutureBuilder<WebViewController>(
                      future: _webViewController.future,
                      builder: (BuildContext context,
                          AsyncSnapshot<WebViewController> snapshot) {
                        final bool webViewReady =
                            snapshot.connectionState == ConnectionState.done;

                        if (snapshot.hasData) {
                          final WebViewController controller = snapshot.data!;
                          return Row(
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Iconsax.previous1),
                                onPressed: !webViewReady
                                    ? null
                                    : () async {
                                        if (await controller.canGoBack()) {
                                          await controller.goBack();
                                        } else {
                                          // ignore: deprecated_member_use
                                          Scaffold.of(context).showSnackBar(
                                            const SnackBar(
                                                content: Text("No history")),
                                          );
                                          return;
                                        }
                                      },
                              ),
                              IconButton(
                                icon: const Icon(Iconsax.next1),
                                onPressed: !webViewReady
                                    ? null
                                    : () async {
                                        if (await controller.canGoForward()) {
                                          await controller.goForward();
                                        } else {
                                          // ignore: deprecated_member_use
                                          Scaffold.of(context).showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text("No forward history")),
                                          );
                                          return;
                                        }
                                      },
                              ),
                              IconButton(
                                icon: const Icon(Iconsax.refresh),
                                onPressed: !webViewReady
                                    ? null
                                    : () {
                                        controller.reload();
                                      },
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: TextField(
                                      textInputAction: TextInputAction.search,
                                      onTap: () => urlController.selection =
                                          TextSelection(
                                              baseOffset: 0,
                                              extentOffset: urlController
                                                  .value.text.length),
                                      controller: urlController,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                      ),
                                      onSubmitted: (value) {
                                        setState(() {
                                          indexPosition = 1;
                                        });
                                        if (Uri.parse(urlController.text)
                                            .isAbsolute) {
                                          controller
                                              .loadUrl(urlController.text);
                                        } else {
                                          controller.loadUrl(("https://" +
                                              urlController.text));
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    )),
                  ]),
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: indexPosition,
                  children: [
                    WebView(
                      debuggingEnabled: true,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        _webViewController.complete(webViewController);
                      },
                      initialUrl: urlTo,
                      onPageStarted: beginLoading,
                      onPageFinished: (String url) async {
                        WebViewController webViewController =
                            await _webViewController.future;
                            String trust =
                            await rootBundle.loadString("assets/trust_ios.js");
                        String init =
                            await rootBundle.loadString("assets/init.js");
                        
                        await webViewController.evaluateJavascript(trust);
                        await webViewController.evaluateJavascript(init);

                        urlController.text =
                            (await webViewController.currentUrl()).toString();

                        setState(()  {
                          indexPosition = 0;
                        });
                      },
                      onWebResourceError: (WebResourceError error) async {
                        loadHtmlFromAssets('assets/error_page.html',
                            await _webViewController.future);
                      },
                    ),
                    Container(
                      color: Colors.white,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
