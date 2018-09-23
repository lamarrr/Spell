library spell;
// Copyright (c) 2018, Basit Ayantunde.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

/// Number(Integer) to English interpreter
///
/// Spell is a small library containing a sort of lexer and parser for interpreting integers to words in english

import 'dart:collection' show Queue;
import './htu_parser.dart';
import './defs.dart';

// TODO(@lamarrr): remove isLeading for Parser.parse, arg not required
// TODO(@lamarrr): add seperator for each parsed hundred

/// Parses 3 digit Hundreds (HTU)
/// [HTU] - hundreds digit to parse
/// [isLeading] - is it a leading HTU digit?
String _parseHTU(String HTU, [bool isLeading = false]) {
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
  Queue<String> tokens = Queue.from(HTU.split(""));
  // parser for HTU
  HTUParser parser = HTUParser();

  // HTU token iterator
  Iterator<String> tokenIterator = tokens.iterator;
  // Any more tokens? Add to respective HTU position, else do nothing
  tokenIterator.moveNext() ? parser.hundred = tokenIterator.current : 0;
  tokenIterator.moveNext() ? parser.tens = tokenIterator.current : 0;
  tokenIterator.moveNext() ? parser.unit = tokenIterator.current : 0;

  return parser.parse(true);
}

String _numberToWords(int number, String seperator) {
  String numberString = number.toString();
  int nHundreds = (numberString.length / 3).floor();
  int nLeading = (numberString.length % 3);

  // split and reverse for processing
  Iterable<String> numCharsI = numberString.split("");
  List<String> numCharsL = numCharsI.toList();
  List<String> revNumSubL = numCharsL.reversed.toList();

  Queue<String> tokens = Queue<String>();

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

    result += _parseHTU(token) +
        " " +
        HundredsMap[thousandth] +
        (tokens.length != 0 ? seperator : " ");
  }

  return result;
}

RegExp _regExMultipleANDs = RegExp(r"(.*?)and and(.*?)");
RegExp _regExIsolatedAND = RegExp(r"(.*?) and \W");

/// spells out an integer as a word
/// floating point numbers not supported in the mean time until future versions
///
/// [toSpell] integer to interpret to words
/// [seperator] for each thousand folds
String spell(int toSpell, [String seperator = " , "]) {
  String cleaned = _numberToWords(toSpell, seperator)
      .replaceAllMapped(_regExMultipleANDs, (Match match) {
    return "${match.group(1)}and${match.group(2)}";
  });

  cleaned = cleaned.replaceAllMapped(_regExIsolatedAND, (Match match) {
    return "${match.group(1)}";
  });

  return cleaned;
}
