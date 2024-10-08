import 'package:universal_html/html.dart';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

class EmbeddedForm extends StatefulWidget{
  const EmbeddedForm ({Key? key}) : super(key: key);

  @override
  State<EmbeddedForm> createState() => _EmbeddedFormState();
}

class _EmbeddedFormState extends State<EmbeddedForm> {
  final IFrameElement iframe = IFrameElement();
  late Widget res;
  final double height = 2112;
  final double width = 640;

  @override
  void initState() {
    iframe.height = height.toString();
    iframe.width = width.toString();
    iframe.src = 'https://docs.google.com/forms/d/e/1FAIpQLSf10CDlLeFpaONtjS1pU0qcEsdQPfngeXh70-hhZpXUGCQDqA/viewform?embedded=true';
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
    super.initState();
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
