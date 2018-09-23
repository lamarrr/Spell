import './defs.dart';
import 'dart:collection' show Queue;

/// Parser for 3 figure digits
/// [hundred]
/// [tens]
/// [unit]
class HTUParser {
  String hundred;
  String tens;
  String unit;
  HTUParser();

  String parse([bool isLeading = false]) {
    Queue<String> result = Queue<String>();

    // handle hundreds
    if (hundred == "0") {
      if (!isLeading) {
        result.add("and");
      } else {
        throw ArgumentError("0 preceding, number to be parsed");
      }
    } else {
      if (hundred != "?") result.add(NUnits[hundred] + " hundred and");
    }

    // handle tens
    /// handle zero preceeded values
    if (tens == "0") {
      if (result.last != "and") result.add("and");
      if (unit == "0") {
      } else {
        result.add(NUnits[unit]);
      }
      ;
    } else if (tens == "1") {
      if (unit == "0") {
        result.add("ten");
      } else {
        result.add(NFirstTens["1$unit"]);
      }
    } else {
      if (tens != "?") result.add(NTens[tens]);
      assert(unit != "?");
      if (unit != "0") result.add(NUnits[unit]);
    }

    return result.join(" ");
  }
}