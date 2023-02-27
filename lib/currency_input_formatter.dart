import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatter_utils.dart';

final RegExp _mantissaSeparatorRegexp = RegExp(r'[,.]');
final RegExp _illegalCharsRegexp = RegExp(r'[^0-9-,.]+');

class CurrencyInputFormatter extends TextInputFormatter {
  /// [mantissaLength] specifies how many digits will be added after a period sign
  CurrencyInputFormatter({
    this.mantissaLength = 2,
  });

  final int mantissaLength;
  final String _mantissaSeparator = '.';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldCaretIndex = max(oldValue.selection.start, oldValue.selection.end);
    final newCaretIndex = max(newValue.selection.start, newValue.selection.end);

    final oldText = oldValue.text;
    var newText = newValue.text;

    if (newText.length > 0 && newText.lastIndexOf(',') == newText.length - 1) {
      newText = newText.replaceRange(newText.lastIndexOf(','), null, '.');
    }
    final lastCharacterIsDot = newText.indexOf('.') == newText.length - 1;

    final newAsNumeric = toNumericString(
      newText,
      allowPeriod: true,
    );

    final newAsCurrency = toCurrencyString(
      newText,
      mantissaLength: mantissaLength,
    );

    final oldAsCurrency = toCurrencyString(
      oldText,
      mantissaLength: mantissaLength,
    );

    if (oldValue == newValue) return newValue;

    final isErasing = newText.length < oldText.length;
    if (isErasing) {
      if (_hasErasedMantissaSeparator(
        shorterString: newText,
        longerString: oldText,
      )) {
        return oldValue.copyWith(
          text: newAsCurrency,
          selection: TextSelection.collapsed(
            offset: min(
              oldValue.text.length,
              oldCaretIndex - 1,
            ),
          ),
        );
      }
    } else {
      if (containsIllegalChars(newText)) {
        return oldValue;
      }
    }

    final afterMantissaPosition = _countAfterMantissaPosition(
      oldText: oldText,
      oldCaretOffset: oldCaretIndex,
    );

    if (_switchToRightInWholePart(
      newText: newText,
      oldText: oldText,
    )) {
      final text = newAsCurrency + (lastCharacterIsDot ? '.' : '');

      return oldValue.copyWith(
        text: text,
        selection: TextSelection.collapsed(
          offset: text.length,
        ),
      );
    }

    if (afterMantissaPosition > 0) {
      if (_switchToLeftInMantissa(
        newText: newText,
        oldText: oldText,
        caretPosition: newCaretIndex,
      )) {
        return TextEditingValue(
          selection: TextSelection.collapsed(
            offset: newCaretIndex,
          ),
          text: newAsCurrency,
        );
      } else {
        return TextEditingValue(
          selection: TextSelection.collapsed(
            offset: newAsCurrency.length,
          ),
          text: newAsCurrency,
        );
      }
    }

    var initialCaretOffset = 0;
    if (_isZeroOrEmpty(newAsNumeric)) {
      int offset = min(
        newValue.text.length,
        initialCaretOffset + 1,
      );
      if (newValue.text == '') {
        offset = 1;
      }
      return newValue.copyWith(
        text: newAsCurrency,
        selection: TextSelection.collapsed(
          offset: offset,
        ),
      );
    }

    final lengthDiff = newAsCurrency.length - oldAsCurrency.length;

    initialCaretOffset = max(
      oldCaretIndex + lengthDiff,
      1,
    );

    if (initialCaretOffset < 1) {
      if (newAsCurrency.isNotEmpty) {
        initialCaretOffset += 1;
      }
    }
    return TextEditingValue(
      selection: TextSelection.collapsed(
        offset: initialCaretOffset,
      ),
      text: newAsCurrency,
    );
  }

  bool _isZeroOrEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return true;
    }
    value = toNumericString(
      value,
      allowPeriod: true,
    );

    try {
      return double.parse(value) == 0.0;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return false;
  }

  List<String> findDifferentChars({
    required String longerString,
    required String shorterString,
  }) {
    final newChars = longerString.split('');
    final oldChars = shorterString.split('');
    for (var i = 0; i < oldChars.length; i++) {
      final oldChar = oldChars[i];
      newChars.remove(oldChar);
    }
    return newChars;
  }

  bool containsMantissaSeparator(List<String> chars) =>
      chars.contains(_mantissaSeparator);

  bool _switchToRightInWholePart({
    required String newText,
    required String oldText,
  }) {
    if (newText.length > oldText.length) {
      final newChars = findDifferentChars(
        longerString: newText,
        shorterString: oldText,
      );
      if (containsMantissaSeparator(newChars)) return true;
    }
    return false;
  }

  bool _switchToLeftInMantissa({
    required String newText,
    required String oldText,
    required int caretPosition,
  }) {
    if (newText.length < oldText.length) {
      if (caretPosition < newText.length) {
        var nextChar = '';
        if (caretPosition < newText.length - 1) {
          nextChar = newText[caretPosition];
          if (!isDigit(nextChar, positiveOnly: true) ||
              int.tryParse(nextChar) == 0) {
            return true;
          }
        }
      }
    }
    return false;
  }

  int _countAfterMantissaPosition({
    required String oldText,
    required int oldCaretOffset,
  }) {
    if (mantissaLength < 1) {
      return 0;
    }
    final mantissaIndex = oldText.lastIndexOf(
      _mantissaSeparatorRegexp,
    );
    if (mantissaIndex < 0) {
      return 0;
    }
    if (oldCaretOffset > mantissaIndex) {
      return oldCaretOffset - mantissaIndex;
    }
    return 0;
  }

  bool _hasErasedMantissaSeparator({
    required String shorterString,
    required String longerString,
  }) {
    final differentChars = findDifferentChars(
      shorterString: shorterString,
      longerString: longerString,
    );
    if (containsMantissaSeparator(differentChars)) return true;
    return false;
  }

  bool containsIllegalChars(String input) {
    if (input.isEmpty) return false;
    var clearedInput = input;

    clearedInput = clearedInput.replaceAll(' ', '');
    return _illegalCharsRegexp.hasMatch(clearedInput);
  }
}
