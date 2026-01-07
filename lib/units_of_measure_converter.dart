/// A Dart/Flutter implementation of the Unified Code for Units of Measure (UCUM).
///
/// This package provides comprehensive support for unit validation, conversion,
/// and lookup following the UCUM specification.
///
/// ## Features
///
/// - **Unit Validation**: Validate UCUM unit strings and get suggestions for invalid units
/// - **Unit Conversion**: Convert between any commensurable units using dimensional analysis
/// - **Unit Lookup**: Search units by code, name, or synonyms
/// - **Commensurable Units**: Find all units that can be converted to/from a given unit
/// - **Special Units**: Handle non-linear conversions (temperature, logarithmic scales)
///
/// ## Quick Start
///
/// ```dart
/// import 'package:units_of_measure_converter/units_of_measure_converter.dart';
///
/// void main() {
///   final ucum = UcumService();
///
///   // Validate a unit
///   final validation = ucum.validateUnitString('mg/dL');
///   print('Valid: ${validation.isValid}');
///
///   // Convert between units
///   final result = ucum.convertUnitTo('km', 5.0, 'm');
///   print('${result.fromValue} km = ${result.value} m');
///
///   // Search for units
///   final units = ucum.searchUnits('meter');
///   for (final unit in units) {
///     print('${unit.code}: ${unit.name}');
///   }
///
///   // Find commensurable units
///   final lengthUnits = ucum.commensurablesList('m');
///   print('Units convertible to meters: ${lengthUnits.map((u) => u.code)}');
/// }
/// ```
///
/// ## UCUM Compliance
///
/// This package follows the Unified Code for Units of Measure (UCUM) specification
/// as defined at https://ucum.org/ucum. It supports:
///
/// - All 7 base units (meter, second, gram, radian, kelvin, coulomb, candela)
/// - SI prefixes (yotta to yocto)
/// - Binary prefixes (kibi, mebi, gibi, tebi)
/// - Compound unit expressions (e.g., kg.m/s2)
/// - Unit annotations (e.g., {annotation})
/// - Special units with non-linear conversions (Celsius, Fahrenheit, pH, etc.)
library units_of_measure_converter;

export 'src/models/models.dart';
export 'src/parser/unit_parser.dart';
export 'src/converter/unit_converter.dart';
export 'src/ucum_service.dart';
export 'src/data/ucum_definitions.dart';
