import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/currency_input_formatter.dart';

class MoneyFormatPage extends StatefulWidget {
  @override
  _MoneyFormatPageState createState() => _MoneyFormatPageState();
}

class _MoneyFormatPageState extends State<MoneyFormatPage> {
  Widget _getText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Money Formatter Demo',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(
            30.0,
          ),
          child: Column(
            children: <Widget>[
              _getText(
                'The first field uses no trailing or leading symbols, and no decimal points',
              ),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a flat numeric value',
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(
                      .3,
                    ),
                  ),
                  errorStyle: TextStyle(
                    color: Colors.red,
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  CurrencyInputFormatter(
                    mantissaLength: 2,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
