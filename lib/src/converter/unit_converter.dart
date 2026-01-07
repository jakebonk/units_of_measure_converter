import 'dart:math' as math;
import '../models/models.dart';
import '../parser/unit_parser.dart';

/// Handles special unit conversions (non-linear conversions like temperature).
class SpecialUnitConverter {
  SpecialUnitConverter._();

  /// Convert from a special unit to its base unit representation
  static double toBaseUnit(String functionName, double value, {double prefix = 1.0}) {
    switch (functionName) {
      case 'Cel': // Celsius to Kelvin
        return value + 273.15;
      case 'degF': // Fahrenheit to Kelvin
        return (value + 459.67) * 5.0 / 9.0;
      case 'degRe': // Réaumur to Kelvin
        return value * 5.0 / 4.0 + 273.15;
      case 'pH': // pH
        return math.pow(10, -value).toDouble();
      case 'ln': // Natural logarithm
        return math.exp(value);
      case 'lg': // Common logarithm (base 10)
        return math.pow(10, value).toDouble();
      case '2lg': // Binary logarithm (base 2)
        return math.pow(2, value).toDouble();
      case 'ld': // Binary logarithm (alternate name)
        return math.pow(2, value).toDouble();
      case 'tan': // Tangent
        return math.tan(value);
      case '100tan': // Tangent * 100
        return math.tan(value / 100);
      case 'hpX': // Homeopathic potency X
        return math.pow(10, -value).toDouble();
      case 'hpC': // Homeopathic potency C
        return math.pow(100, -value).toDouble();
      case 'hpM': // Homeopathic potency M
        return math.pow(1000, -value).toDouble();
      case 'hpQ': // Homeopathic potency Q
        return math.pow(50000, -value).toDouble();
      default:
        return value * prefix;
    }
  }

  /// Convert from base unit to a special unit representation
  static double fromBaseUnit(String functionName, double value, {double prefix = 1.0}) {
    switch (functionName) {
      case 'Cel': // Kelvin to Celsius
        return value - 273.15;
      case 'degF': // Kelvin to Fahrenheit
        return value * 9.0 / 5.0 - 459.67;
      case 'degRe': // Kelvin to Réaumur
        return (value - 273.15) * 4.0 / 5.0;
      case 'pH': // from concentration to pH
        return -_log10(value);
      case 'ln': // Natural logarithm
        return math.log(value);
      case 'lg': // Common logarithm
        return _log10(value);
      case '2lg': // Binary logarithm
        return _log2(value);
      case 'ld': // Binary logarithm (alternate)
        return _log2(value);
      case 'tan': // Arc tangent
        return math.atan(value);
      case '100tan': // Arc tangent * 100
        return math.atan(value) * 100;
      case 'hpX': // Homeopathic potency X
        return -_log10(value);
      case 'hpC': // Homeopathic potency C
        return -math.log(value) / math.log(100);
      case 'hpM': // Homeopathic potency M
        return -math.log(value) / math.log(1000);
      case 'hpQ': // Homeopathic potency Q
        return -math.log(value) / math.log(50000);
      default:
        return value / prefix;
    }
  }

  static double _log10(double x) => math.log(x) / math.ln10;
  static double _log2(double x) => math.log(x) / math.ln2;
}

/// Converts between UCUM units using dimensional analysis.
class UnitConverter {
  final UnitParser _parser;

  /// Optional molecular weight for mass-to-mole conversions
  double? molecularWeight;

  /// Optional charge for equivalents conversions
  int? charge;

  UnitConverter({UnitParser? parser}) : _parser = parser ?? UnitParser();

  /// Access the underlying parser
  UnitParser get parser => _parser;

  /// Convert a value from one unit to another.
  ///
  /// Example:
  /// ```dart
  /// final result = converter.convert(1.0, 'km', 'm');
  /// print(result.value); // 1000.0
  /// ```
  ConversionResult convert(
    double value,
    String fromUnit,
    String toUnit, {
    double? molecularWeight,
    int? charge,
  }) {
    final fromParsed = _parser.parse(fromUnit);
    final toParsed = _parser.parse(toUnit);

    // Check for parse errors
    if (fromParsed.error != null) {
      return ConversionResult(
        success: false,
        fromUnit: fromUnit,
        toUnit: toUnit,
        fromValue: value,
        message: 'Invalid source unit: ${fromParsed.error}',
        fromParsed: fromParsed,
        toParsed: toParsed,
      );
    }

    if (toParsed.error != null) {
      return ConversionResult(
        success: false,
        fromUnit: fromUnit,
        toUnit: toUnit,
        fromValue: value,
        message: 'Invalid target unit: ${toParsed.error}',
        fromParsed: fromParsed,
        toParsed: toParsed,
      );
    }

    // Check dimensional compatibility
    if (fromParsed.dimension != toParsed.dimension) {
      return ConversionResult(
        success: false,
        fromUnit: fromUnit,
        toUnit: toUnit,
        fromValue: value,
        message:
            'Units are not commensurable: ${fromParsed.dimension} vs ${toParsed.dimension}',
        fromParsed: fromParsed,
        toParsed: toParsed,
      );
    }

    // Handle special units (non-linear conversions)
    double result;
    if (fromParsed.isSpecial || toParsed.isSpecial) {
      result = _convertWithSpecialUnits(value, fromParsed, toParsed);
    } else {
      // Standard linear conversion using dimensional analysis
      // Convert to base units, then to target units
      result = value * fromParsed.magnitude / toParsed.magnitude;
    }

    return ConversionResult(
      success: true,
      value: result,
      fromUnit: fromUnit,
      toUnit: toUnit,
      fromValue: value,
      fromParsed: fromParsed,
      toParsed: toParsed,
    );
  }

  /// Handle conversions involving special (non-linear) units
  double _convertWithSpecialUnits(
    double value,
    ParsedUnit fromParsed,
    ParsedUnit toParsed,
  ) {
    double intermediateValue = value;

    // Convert from source special unit to base representation
    if (fromParsed.isSpecial && fromParsed.unit?.conversionFunction != null) {
      intermediateValue = SpecialUnitConverter.toBaseUnit(
        fromParsed.unit!.conversionFunction!,
        value,
        prefix: fromParsed.unit!.conversionPrefix ?? 1.0,
      );
    } else {
      // Convert to base magnitude
      intermediateValue = value * fromParsed.magnitude;
    }

    // Convert to target special unit from base representation
    if (toParsed.isSpecial && toParsed.unit?.conversionFunction != null) {
      return SpecialUnitConverter.fromBaseUnit(
        toParsed.unit!.conversionFunction!,
        intermediateValue,
        prefix: toParsed.unit!.conversionPrefix ?? 1.0,
      );
    } else {
      // Convert from base magnitude
      return intermediateValue / toParsed.magnitude;
    }
  }

  /// Check if two units are commensurable (can be converted between).
  bool areCommensurable(String unit1, String unit2) {
    final parsed1 = _parser.parse(unit1);
    final parsed2 = _parser.parse(unit2);

    if (parsed1.error != null || parsed2.error != null) {
      return false;
    }

    return parsed1.dimension == parsed2.dimension;
  }

  /// Get a list of units that are commensurable with the given unit.
  List<UcumUnit> getCommensurableUnits(
    String unitString, {
    Set<UnitCategory>? categories,
  }) {
    final parsed = _parser.parse(unitString);
    if (parsed.error != null) {
      return [];
    }

    return _parser.allUnits.where((unit) {
      // Check dimensional compatibility
      if (unit.dimension != parsed.dimension) {
        return false;
      }

      // Filter by category if specified
      if (categories != null && categories.isNotEmpty) {
        if (unit.category == null || !categories.contains(unit.category)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Convert a value to base units.
  ///
  /// Returns the value expressed in terms of the 7 UCUM base units.
  ({double value, Dimension dimension, bool isSpecial}) convertToBaseUnits(
    double value,
    String unitString,
  ) {
    final parsed = _parser.parse(unitString);

    if (parsed.error != null) {
      return (
        value: value,
        dimension: const Dimension(),
        isSpecial: false,
      );
    }

    double baseValue;
    if (parsed.isSpecial && parsed.unit?.conversionFunction != null) {
      baseValue = SpecialUnitConverter.toBaseUnit(
        parsed.unit!.conversionFunction!,
        value,
        prefix: parsed.unit!.conversionPrefix ?? 1.0,
      );
    } else {
      baseValue = value * parsed.magnitude;
    }

    return (
      value: baseValue,
      dimension: parsed.dimension,
      isSpecial: parsed.isSpecial,
    );
  }

  /// Validate a unit string.
  ValidationResult validate(String unitString, {bool suggest = false}) {
    return _parser.validate(unitString);
  }
}
