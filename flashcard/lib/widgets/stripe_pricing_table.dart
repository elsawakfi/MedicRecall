import 'package:universal_html/html.dart';
import 'dart:io' if (dart.library.html) 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';

class SubscriptionPricingTable extends StatefulWidget {
  const SubscriptionPricingTable({super.key});

  @override
  State<SubscriptionPricingTable> createState() => _SubscriptionPricingTableState();
}

class _SubscriptionPricingTableState extends State<SubscriptionPricingTable> {
  final IFrameElement iframe = IFrameElement();
  late Widget res;
  final double height = 2112;
  final double width = 640;

  @override
  void initState() {
    super.initState();
    iframe.height = height.toString();
    iframe.width = width.toString();
    iframe.src = 'https://billing.stripe.com/p/login/test_eVqfZa8B98iU5BM7ir4ko00';
    iframe.style.border = 'none';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'iframe',
      (int viewId) => iframe,
    );

    res = HtmlElementView(
      key: UniqueKey(),
      viewType: 'iframe',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: res,
    );
  }
}