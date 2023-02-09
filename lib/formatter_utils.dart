import 'package:flutter/foundation.dart';

final RegExp _digitRegExp = RegExp(r'[-0-9]+');
final RegExp _positiveDigitRegExp = RegExp(r'[0-9]+');
final RegExp _digitWithPeriodRegExp = RegExp(r'[-0-9]+(\.[0-9]+)?');
final RegExp _repeatingDotsRegExp = RegExp(r'\.{2,}');
final RegExp _startingWithZeroRegExp = RegExp(r'^0[0-9]+');

/// [errorText] if you don't want this method to throw any
/// errors, pass null here
String toNumericString(
  String? inputString, {
  bool allowPeriod = false,
  bool allowHyphen = true,
  String? errorText,
}) {
  if (inputString == null) {
    return '';
  } else if (inputString == '+') {
    return inputString;
  } else if (_startingWithZeroRegExp.hasMatch(inputString)) {
    return inputString.substring(1);
  }

  inputString = inputString.replaceAll(',', '');

  final startsWithPeriod = numericStringStartsWithOrphanPeriod(
    inputString,
  );

  final regexWithoutPeriod = allowHyphen ? _digitRegExp : _positiveDigitRegExp;
  final regExp = allowPeriod ? _digitWithPeriodRegExp : regexWithoutPeriod;
  var result = inputString.splitMapJoin(
    regExp,
    onMatch: (m) => m.group(0)!,
    onNonMatch: (nm) => '',
  );
  if (startsWithPeriod && allowPeriod) {
    result = '0.$result';
  }
  if (result.isEmpty) {
    return result;
  }
  try {
    result = _toDoubleString(
      result,
      allowPeriod: allowPeriod,
      errorText: errorText,
    );
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
  return result;
}

String toNumericStringByRegex(
  String? inputString, {
  bool allowPeriod = false,
  bool allowHyphen = true,
}) {
  if (inputString == null) return '';
  final regexWithoutPeriod = allowHyphen ? _digitRegExp : _positiveDigitRegExp;
  final regExp = allowPeriod ? _digitWithPeriodRegExp : regexWithoutPeriod;
  return inputString.splitMapJoin(
    regExp,
    onMatch: (m) => m.group(0)!,
    onNonMatch: (nm) => '',
  );
}

/// This hack is necessary because double.parse
/// fails at some point
/// while parsing too large numbers starting to convert
/// them into a scientific notation with e+/- power
/// This function doesnt' really care for numbers, it works
/// with strings from the very beginning
/// [input] a value to be converted to a string containing only numbers
/// [allowPeriod] if you need int pass false here
/// [errorText] if you don't want this method to throw an
/// error if a number cannot be formatted
/// pass null
/// [allowAllZeroes] might be useful e.g. for phone masks
String _toDoubleString(
  String input, {
  bool allowPeriod = true,
  String? errorText = 'Invalid number',
}) {
  const period = '.';
  const zero = '0';
  const dash = '-';
  final temp = <String>[];
  if (input.startsWith(period)) {
    if (allowPeriod) {
      temp.add(zero);
    } else {
      return zero;
    }
  }
  bool periodUsed = false;

  for (var i = 0; i < input.length; i++) {
    final char = input[i];
    if (!isDigit(char, positiveOnly: true)) {
      if (char == dash) {
        if (i > 0) {
          if (errorText != null) {
            throw errorText;
          } else {
            continue;
          }
        }
      } else if (char == period) {
        if (!allowPeriod) {
          break;
        } else if (periodUsed) {
          continue;
        }
        periodUsed = true;
      }
    }
    temp.add(char);
  }
  if (temp.contains(period)) {
    while (temp.isNotEmpty && temp[0] == zero) {
      temp.removeAt(0);
    }
    if (temp.isEmpty) {
      return zero;
    } else if (temp[0] == period) {
      temp.insert(0, zero);
    }
  }
  final test = temp.join();
  return test;
}

bool numericStringStartsWithOrphanPeriod(String string) {
  var result = false;
  for (var i = 0; i < string.length; i++) {
    final char = string[i];
    if (isDigit(char)) {
      break;
    }
    if (char == '.' || char == ',') {
      result = true;
      break;
    }
  }
  return result;
}

/// [mantissaLength] specifies how many digits will be added after a period sign
/// [leadingSymbol] any symbol (except for the ones that contain digits) the will be
/// added in front of the resulting string. E.g. $ or €
/// some of the signs are available via constants like [MoneySymbols.EURO_SIGN]
/// but you can basically add any string instead of it. The main rule is that the string
/// must not contain digits, preiods, commas and dashes
/// [trailingSymbol] is the same as leading but this symbol will be added at the
/// end of your resulting string like 1,250€ instead of €1,250
/// [useSymbolPadding] adds a space between the number and trailing / leading symbols
/// like 1,250€ -> 1,250 € or €1,250€ -> € 1,250
String toCurrencyString(
  String value, {
  int mantissaLength = 2,
}) {
  if (mantissaLength <= 0) {
    mantissaLength = 0;
  }
  const tSeparator = ',';

  value = value.replaceAll(_repeatingDotsRegExp, '.');

  if (mantissaLength == 0) {
    if (value.contains('.')) {
      value = value.substring(
        0,
        value.indexOf('.'),
      );
    }
  }
  value = toNumericString(
    value,
    allowPeriod: mantissaLength > 0,
  );

  final isNegative = value.contains('-');

  final list = <String?>[];
  var mantissa = '';
  final split = value.split('');
  final mantissaList = <String>[];
  final mantissaSeparatorIndex = value.indexOf('.');

  if (mantissaSeparatorIndex > -1) {
    final start = mantissaSeparatorIndex + 1;
    final end = start + mantissaLength;
    for (var i = start; i < end; i++) {
      if (i < split.length) {
        mantissaList.add(split[i]);
      }
    }
  }

  mantissa = _postProcessMantissa(mantissaList.join(), mantissaLength);

  var maxIndex = split.length - 1;
  if (mantissaSeparatorIndex > 0) {
    maxIndex = mantissaSeparatorIndex - 1;
  }
  var digitCounter = 0;
  if (maxIndex > -1) {
    for (var i = maxIndex; i >= 0; i--) {
      digitCounter++;
      list.add(split[i]);
      if (digitCounter % 3 == 0 && i > (isNegative ? 1 : 0)) {
        list.add(tSeparator);
      }
    }
  } else {
    list.add('0');
  }

  final reversed = list.reversed.join();
  return '$reversed$mantissa';
}

/// simply adds a period to an existing fractional part
/// or adds an empty fractional part if it was not filled
String _postProcessMantissa(String mantissaValue, int mantissaLength) {
  if (mantissaLength == 0 || mantissaValue == '' || mantissaValue.isEmpty) return '';
  if (mantissaValue == '0') return '.0';
  if (mantissaValue == '') return '';
  return '.$mantissaValue';
}

/// [character] a character to check if it's a digit against
/// [positiveOnly] if true it will not allow a minus (dash) character
/// to be accepted as a part of a digit
bool isDigit(
  String? character, {
  bool positiveOnly = false,
}) {
  if (character == null || character.isEmpty || character.length > 1) {
    return false;
  }
  if (positiveOnly) {
    return _positiveDigitRegExp.stringMatch(character) != null;
  }
  return _digitRegExp.stringMatch(character) != null;
}
