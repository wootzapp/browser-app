import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:io';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uni_links/uni_links.dart';
import 'package:wootzapp/wallet/Wallet.dart';

class InAppWeb extends StatefulWidget {
  @override
  _InAppWebState createState() => _InAppWebState();
}

class _InAppWebState extends State<InAppWeb> {
  StreamSubscription? _sub;

  final JavascriptRuntime javascriptRuntime = getJavascriptRuntime();

  bool _initialUriIsHandled = false;

  final GlobalKey webViewKey = GlobalKey();

  // late Web3Provider web3;

  InAppWebViewController? webViewController;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;

  late ContextMenu contextMenu;

  String url = "https://pancakeswap.finance/";

  double progress = 0;

  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _handleIncomingLinks();
    _handleInitialUri();

    // getEthersJsFile();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  getEthersJsFile() async {
    // javascriptRuntime.evaluate(code)
    // var asyncResult = await javascriptRuntime.evaluate("""if (typeof MyClass == 'undefined') {
    //           var MyClass = class  {
    //             constructor(id) {
    //               this.id = id;
    //             }

    //             getId() {
    //               return this.id;
    //             }
    //           }
    //         }
    //         var obj = new MyClass(1);
    //    JSON.stringify(obj);
    //      """).stringResult;
    final opts = null;
    final asyncResult = await getEthersJsRuntime();

    final result = asyncResult.evaluate('''
      const wallet = global.ethers.Wallet.createRandom($opts);
      // Return from evaluation
      JSON.stringify({
        address: wallet.address,
        publicKey: wallet.publicKey
      });
    ''');
    print("promisesss " + result.toString());
  }

  Future<JavascriptRuntime> getEthersJsRuntime() async {
    final JavascriptRuntime jsRuntime = getJavascriptRuntime();
    jsRuntime.evaluate('var window = global = globalThis;');
    await javascriptRuntime
        .evaluate(await rootBundle.loadString('assets/ethers.js'));

    return jsRuntime;
  }

  @override
  void dispose() {
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
          url = uri.toString();
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: Uri.parse(url)));
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
        url = uri.toString();
        webViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));
      }, onError: (Object err) {
        print('malformed initial uri' + err.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: SafeArea(
          child: Column(children: <Widget>[
        Container(
          color: const Color.fromARGB(255, 204, 204, 255),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Iconsax.previous1),
                  onPressed: () {
                    webViewController?.goBack();
                  },
                ),
                IconButton(
                  icon: const Icon(Iconsax.next1),
                  onPressed: () {
                    webViewController?.goForward();
                  },
                ),
                IconButton(
                  icon: const Icon(Iconsax.refresh),
                  onPressed: () {
                    webViewController?.reload();
                  },
                ),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: TextField(
                        textInputAction: TextInputAction.search,
                        onTap: () => urlController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: urlController.value.text.length),
                        controller: urlController,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        onSubmitted: (value) {
                          var url = Uri.parse(value);
                          if (url.scheme.isEmpty) {
                            url = Uri.parse(
                                "https://www.google.com/search?q=" + value);
                          }
                          webViewController?.loadUrl(
                              urlRequest: URLRequest(url: url));
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: Uri.parse(url)),
                initialUserScripts: UnmodifiableListView<UserScript>([]),
                initialOptions: options,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) async {
                  webViewController = controller;

                  // if (!Platform.isAndroid ||
                  //     await AndroidWebViewFeature.isFeatureSupported(
                  //         AndroidWebViewFeature.WEB_MESSAGE_LISTENER)) {
                  await controller.addWebMessageListener(WebMessageListener(
                    jsObjectName: "test",
                    onPostMessage:
                        (message, sourceOrigin, isMainFrame, replyProxy) {},
                  ));

                  await controller.addWebMessageListener(WebMessageListener(
                    jsObjectName: "eth_requestAccounts",
                    onPostMessage:
                        (message, sourceOrigin, isMainFrame, replyProxy) async {
                          
                      final wallet = await Wallet.createRandom(extraEntropy: '0xbaadf00d');

                      String address = wallet.address;
                      var messageList = message!.split("#");
                      var id = messageList[0];
                      print("hi all" + address);

                      if (id.length > 4) {
                        String responseString =
                            "window.ethereum.sendResponse($id, ['$address'])";

                        await webViewController
                            ?.evaluateJavascript(source: responseString)
                            .then((value) {
                          print(value);
                        });
                      }

                      showCupertinoModalBottomSheet(
                        expand: false,
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const SizedBox(
                          height: 250,
                          child: Scaffold(
                            backgroundColor: Color.fromARGB(255, 204, 204, 255),
                            body: Center(
                                child: Text(
                              'Hello Meta mask',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                        ),
                      );
                    },
                  ));
                  // }
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                androidOnPermissionRequest:
                    (controller, origin, resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
                onLoadStop: (controller, url) async {
                  if (Platform.isAndroid) {
                    await controller.injectJavascriptFileFromAsset(
                        assetFilePath: "assets/trust.js");
                  } else {
                    await controller.injectJavascriptFileFromAsset(
                        assetFilePath: "assets/trust_ios.js");
                  }

                  await controller.injectJavascriptFileFromAsset(
                      assetFilePath: "assets/init.js");
                  pullToRefreshController.endRefreshing();

                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onLoadError: (controller, url, code, message) {
                  controller.loadFile(assetFilePath: "assets/error_page.html");
                  pullToRefreshController.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress / 100;
                    urlController.text = this.url;
                  });
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
              ),
              progress < 1.0
                  ? LinearProgressIndicator(value: progress)
                  : Container(),
            ],
          ),
        ),
      ])),
    ));
  }
}
