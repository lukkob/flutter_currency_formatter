import 'package:example/pages/money_format_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef PageBuilder = Widget Function();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi formatter demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void openPage(Widget page) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
  }

  Widget _buildButton({
    required Color color,
    required IconData iconData,
    required String label,
    required PageBuilder pageBuilder,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      child: Container(
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            openPage(
              pageBuilder(),
            );
          },
          child: Row(
            children: <Widget>[
              Icon(iconData),
              Expanded(
                child: Center(
                  child: Text(label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formatters Demo App'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(
            30.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildButton(
                color: Colors.pink[400]!,
                iconData: Icons.attach_money,
                label: 'Money formatter',
                pageBuilder: () => MoneyFormatPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
