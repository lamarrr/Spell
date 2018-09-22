import 'dart:collection' as coll;
import "dart:io" as io;
import 'package:meta/meta.dart';

/// TODO(@lamarrr): remove isLeading for Parser.parse, arg not required

/// Numeric Units in String Format
const Map<String, String> _NUnits = {
  "1": "one",
  "2": "two",
  "3": "three",
  "4": "four",
  "5": "five",
  "6": "six",
  "7": "seven",
  "8": "eight",
  "9": "nine"
};

/// Special Numeric cases
const Map<String, String> _NFirstTens = {
  "11": "eleven",
  "12": "twelve",
  "13": "thirteen",
  "14": "fourteen",
  "15": "fifteen",
  "16": "sixteen",
  "17": "seventeen",
  "18": "eighteen",
  "19": "nineteen"
};

/// Numeric Tens
const Map<String, String> _NTens = {
  "1": "ten",
  "2": "twenty",
  "3": "thirty",
  "4": "fourty",
  "5": "fifty",
  "6": "sixty",
  "7": "seventy",
  "8": "eighty",
  "9": "ninety"
};

/// Map representing Identifiers based on preceding hundreds
const Map<int, String> _HundredsMap = {
  0: "",
  1: "thousand",
  2: "million",
  3: "billion",
  4: "trillion",
  5: "quadrillion",
  6: "quintillion",
  7: "sextillion",
  8: "septillion",
  9: "octillion",
  10: "nonillion",
  11: "decillion",
  12: "undecillion",
  13: "duodecillion"
};

/// Parser for 3 figure digits
/// [hundred]
/// [tens]
/// [unit]
class _HTUParser {
  String hundred;
  String tens;
  String unit;
  _HTUParser();


  String parse([bool isLeading = false]) {
    coll.Queue<String> result = coll.Queue<String>();

    // handle hundreds
    if (hundred == "0") {
      if (!isLeading) {
        result.add("and");
      } else {
        throw ArgumentError("0 preceding, number to be parsed");
      }
    } else {
      if (hundred != "?") result.add(_NUnits[hundred] + " hundred and");
    }

    // handle tens
    /// handle zero preceeded values
    if (tens == "0") {
      if (result.last != "and") result.add("and");
      if (unit == "0") {
      } else {
        result.add(_NUnits[unit]);
      }
      ;
    } else if (tens == "1") {
      if (unit == "0") {
        result.add("ten");
      } else {
        
        result.add(_NFirstTens["1$unit"]);
      }
    } else {
      
      if (tens != "?") result.add(_NTens[tens]);
      assert(unit != "?");
      if (unit != "0") result.add(_NUnits[unit]);
    }

    return result.join(" ");
  }
}

/// Parses 3 digit Hundreds (HTU)
/// [HTU] - hundreds digit to parse
/// [isLeading] - is it a leading HTU digit?
String parseHTU(String HTU, [bool isLeading = false]) {
  /*
    345
    3 ----> 1 ----> Hundredth
    4 ----> 2 ----> Tenth
    5 ----> 3 ----> Unit
  */

  // HTU token

  // pad HTU by [?] in case of empty character
  HTU = HTU.padLeft(3, "?");

  // Transform HTU String to Queue
  coll.Queue<String> tokens = coll.Queue.from(HTU.split(""));
  // parser for HTU
  _HTUParser parser = _HTUParser();

  // HTU token iterator
  Iterator<String> tokenIterator = tokens.iterator;
  // Any more tokens? Add to respective HTU position, else do nothing
  tokenIterator.moveNext() ? parser.hundred = tokenIterator.current : 0;
  tokenIterator.moveNext() ? parser.tens = tokenIterator.current : 0;
  tokenIterator.moveNext() ? parser.unit = tokenIterator.current : 0;

  return parser.parse(true);
}

String numberToWords(int number) {
  String numberString = number.toString();
  int nHundreds = (numberString.length / 3).floor();
  int nLeading = (numberString.length % 3);

  // split and reverse for processing
  Iterable<String> numCharsI = numberString.split("");
  List<String> numCharsL = numCharsI.toList();
  List<String> revNumSubL = numCharsL.reversed.toList();

  coll.Queue<String> tokens = coll.Queue<String>();

  // reversed number string
  String revNumSub = revNumSubL.join("");
  //print(revNumSub);

  // fetch all hundreds-digits in the number, in reversed order
  for (int a = 0; a < nHundreds * 3; a += 3) {
    String token = revNumSub.substring(a, a + 3).split("").reversed.join();
    //print(token);
    //print("added token: $token");
    tokens.add(token);
  }
  // if any leading non-3 digit number left, fetch it
  if (nLeading != 0) {
    String token = revNumSub
        .substring(revNumSub.length - nLeading, revNumSub.length)
        .split("")
        .reversed
        .join();

    tokens.add(token);
  }

  String result = "";

  int tokensCount = tokens.length;
  for (int count = 0; tokensCount > count; count++) {
    int thousandth =
        nLeading != 0 ? (nHundreds - count) : (nHundreds - count - 1);
    String token = tokens.removeLast();

    result += parseHTU(token) + " " + _HundredsMap[thousandth] + " ";
  }

  return result;
}

void main() {
  RegExp regExMultipleANDs = RegExp(r"(.*?)and and(.*?)");
  RegExp regExIsolatedAND = RegExp(r"(.*?) and\W");

  while (true) {
    print("Enter Number to Interpret");
    int numToParse = int.parse(io.stdin.readLineSync());
    //print(numToParse);
    String cleaned = numberToWords(numToParse)
        .replaceAllMapped(regExMultipleANDs, (Match match) {
      return "${match.group(1)}and${match.group(2)}";
    });

    cleaned = cleaned.replaceAllMapped(regExIsolatedAND, (Match match) {
      return "${match.group(1)}";
    });

    print("Interpreter: $cleaned\n");
  }
}
