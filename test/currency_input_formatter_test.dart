import 'package:flutter/cupertino.dart';
import 'package:flutter_multi_formatter/currency_input_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CurrencyInputFormatter currencyInputFormatter;

  setUp(() {
    currencyInputFormatter = CurrencyInputFormatter();
  });

  test('should correctly remove a comma from thousands', () {
    final currentNumber = "1,000.0";
    final inputNumber = "1,00.0";
    final formattedNumber = currencyInputFormatter
        .formatEditUpdate(
            TextEditingValue(
                text: currentNumber,
                selection: TextSelection(baseOffset: 4, extentOffset: 5),
                composing: TextRange(start: -1, end: -1)),
            TextEditingValue(
                text: inputNumber,
                selection: TextSelection(baseOffset: 4, extentOffset: 4),
                composing: TextRange(start: -1, end: -1)))
        .text;
    expect(formattedNumber, "100.0");
  });

  test('should return true if input contains mantissa separator', () {
    final input = "1,000.0".split('');
    final formattedNumber =
        currencyInputFormatter.containsMantissaSeparator(input);
    expect(formattedNumber, true);
  });

  test('should return false if input doesnt contain mantissa separator', () {
    final input = "1000".split('');
    final formattedNumber =
        currencyInputFormatter.containsMantissaSeparator(input);
    expect(formattedNumber, false);
  });

  test('should return characters which changed', () {
    final input1 = "1,000,000,000.00";
    final input2 = "1,000,000,000.09";
    final formattedNumber = currencyInputFormatter.findDifferentChars(
      longerString: input1,
      shorterString: input2,
    );
    expect(formattedNumber, ['0']);
  });

  test('should return no characters when inputs are the same', () {
    final input1 = "1,000,000,000.00";
    final input2 = "1,000,000,000.00";
    final formattedNumber = currencyInputFormatter.findDifferentChars(
      longerString: input1,
      shorterString: input2,
    );
    expect(formattedNumber, []);
  });

  test('should return false when input doesnt containt illegal chars', () {
    final input = "1,000,000,000.00";
    final formattedNumber = currencyInputFormatter.containsIllegalChars(input);
    expect(formattedNumber, false);
  });

  test('should return true when input contains illegal chars', () {
    final input = "100,xyz";
    final formattedNumber = currencyInputFormatter.containsIllegalChars(input);
    expect(formattedNumber, true);
  });
}
