import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Keyboard Visibility Example'),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => ProviderDemo()),
                //     );
                //   },
                //   child: Text('Provider Demo'),
                // ),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => KeyboardDismissDemo()),
                //     );
                //   },
                //   child: Text('KeyboardDismiss Demo'),
                // ),
                Spacer(),
                TextField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Input box for keyboard test',
                  ),
                ),
                Container(height: 60.0),
                KeyboardVisibilityBuilder(builder: (context, visible) {
                  return Text(
                    'The keyboard is: ${visible ? 'VISIBLE' : 'NOT VISIBLE'}',
                  );
                }),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );;
  }
}