import 'package:flutter/material.dart';

abstract class BasePage extends StatelessWidget {
  const BasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: buildBody(context));
  }

  Widget buildBody(BuildContext context);
}
