import 'package:units_of_measure_converter/ucum_units.dart';

/// Simple example demonstrating the UCUM units package capabilities.
void main() {
  final ucum = UcumService();

  print('=== UCUM Units Package Demo ===\n');

  // ============================================================
  // 1. Unit Validation
  // ============================================================
  print('1. UNIT VALIDATION');
  print('-' * 40);

  final validUnits = ['kg', 'mg/dL', 'm/s2', '[lb_av]', 'mmol/L'];
  for (final unit in validUnits) {
    final result = ucum.validateUnitString(unit);
    print('  $unit: ${result.isValid ? "Valid" : "Invalid"}');
  }

  final invalidResult = ucum.validateUnitString('invalid_unit');
  print('  invalid_unit: ${invalidResult.isValid ? "Valid" : "Invalid"}');
  if (invalidResult.messages.isNotEmpty) {
    print('    Error: ${invalidResult.messages.first}');
  }
  print('');

  // ============================================================
  // 2. Unit Conversion
  // ============================================================
  print('2. UNIT CONVERSION');
  print('-' * 40);

  // Length conversions
  var result = ucum.convertUnitTo('km', 5.0, 'm');
  print('  5 km = ${result.value} m');

  result = ucum.convertUnitTo('[mi_i]', 1.0, 'km');
  print('  1 mile = ${result.value?.toStringAsFixed(3)} km');

  result = ucum.convertUnitTo('[in_i]', 12.0, 'cm');
  print('  12 inches = ${result.value?.toStringAsFixed(2)} cm');

  // Mass conversions
  result = ucum.convertUnitTo('[lb_av]', 1.0, 'kg');
  print('  1 pound = ${result.value?.toStringAsFixed(4)} kg');

  result = ucum.convertUnitTo('kg', 70.0, '[lb_av]');
  print('  70 kg = ${result.value?.toStringAsFixed(2)} pounds');

  // Temperature conversions
  result = ucum.convertUnitTo('Cel', 0.0, 'K');
  print('  0 °C = ${result.value?.toStringAsFixed(2)} K');

  result = ucum.convertUnitTo('[degF]', 98.6, 'Cel');
  print('  98.6 °F = ${result.value?.toStringAsFixed(1)} °C');

  result = ucum.convertUnitTo('Cel', 100.0, '[degF]');
  print('  100 °C = ${result.value?.toStringAsFixed(1)} °F');

  // Compound unit conversions
  result = ucum.convertUnitTo('km/h', 100.0, 'm/s');
  print('  100 km/h = ${result.value?.toStringAsFixed(2)} m/s');

  result = ucum.convertUnitTo('mg/dL', 100.0, 'g/L');
  print('  100 mg/dL = ${result.value} g/L');
  print('');

  // ============================================================
  // 3. Unit Lookup
  // ============================================================
  print('3. UNIT LOOKUP');
  print('-' * 40);

  // Get unit by code
  final meter = ucum.getUnitByCode('m');
  print('  Unit "m": ${meter?.name} (${meter?.property})');

  // Search by name
  final lengthUnits = ucum.searchUnits('meter', maxResults: 3);
  print('  Search "meter": ${lengthUnits.map((u) => u.code).join(", ")}');

  // Search by synonym
  final poundResults = ucum.checkSynonyms('pounds');
  print('  Synonym "pounds": ${poundResults.map((u) => u.code).join(", ")}');
  print('');

  // ============================================================
  // 4. Commensurable Units
  // ============================================================
  print('4. COMMENSURABLE UNITS (units that can convert to each other)');
  print('-' * 40);

  final massUnits = ucum.commensurablesList('kg');
  print('  Units commensurable with kg:');
  for (final unit in massUnits.take(5)) {
    print('    - ${unit.code}: ${unit.name}');
  }
  print('    ... and ${massUnits.length - 5} more');
  print('');

  // ============================================================
  // 5. Check Commensurability
  // ============================================================
  print('5. COMMENSURABILITY CHECK');
  print('-' * 40);

  print('  kg and [lb_av]: ${ucum.areCommensurable("kg", "[lb_av]")}');
  print('  m and km: ${ucum.areCommensurable("m", "km")}');
  print('  m and s: ${ucum.areCommensurable("m", "s")}');
  print('  m/s and km/h: ${ucum.areCommensurable("m/s", "km/h")}');
  print('');

  // ============================================================
  // 6. Parse Unit Expression
  // ============================================================
  print('6. PARSE UNIT EXPRESSION');
  print('-' * 40);

  final parsed = ucum.parseUnit('kg.m/s2');
  print('  Expression: kg.m/s2 (force)');
  print('  Magnitude: ${parsed.magnitude}');
  print('  Dimension: ${parsed.dimension}');
  print('');

  final parsedCompound = ucum.parseUnit('mg/dL');
  print('  Expression: mg/dL (concentration)');
  print('  Magnitude: ${parsedCompound.magnitude}');
  print('  Dimension: ${parsedCompound.dimension}');
  print('');

  // ============================================================
  // 7. Convert to Base Units
  // ============================================================
  print('7. CONVERT TO BASE UNITS');
  print('-' * 40);

  var baseResult = ucum.convertToBaseUnits('km', 1.0);
  print('  1 km in base units: ${baseResult.value} (dimension: ${baseResult.dimension})');

  baseResult = ucum.convertToBaseUnits('h', 1.0);
  print('  1 hour in base units: ${baseResult.value} seconds');

  baseResult = ucum.convertToBaseUnits('Cel', 25.0);
  print('  25 °C in base units: ${baseResult.value} K (special: ${baseResult.isSpecial})');
  print('');

  // ============================================================
  // 8. Get All Units by Property
  // ============================================================
  print('8. UNITS BY PROPERTY');
  print('-' * 40);

  final timeUnits = ucum.getUnitsByProperty('time');
  print('  Time units: ${timeUnits.map((u) => u.code).join(", ")}');

  final pressureUnits = ucum.getUnitsByProperty('pressure');
  print('  Pressure units: ${pressureUnits.map((u) => u.code).join(", ")}');
  print('');

  // ============================================================
  // 9. List All Prefixes
  // ============================================================
  print('9. AVAILABLE PREFIXES');
  print('-' * 40);

  final prefixes = ucum.getAllPrefixes();
  print('  Total prefixes: ${prefixes.length}');
  print('  Examples:');
  for (final p in prefixes.take(5)) {
    print('    ${p.code} (${p.name}): 10^${p.exponent}');
  }
  print('');

  // ============================================================
  // 10. Base Units
  // ============================================================
  print('10. UCUM BASE UNITS');
  print('-' * 40);

  final baseUnits = ucum.getBaseUnits();
  for (final unit in baseUnits) {
    print('  ${unit.code}: ${unit.name} (${unit.property})');
  }

  print('\n=== Demo Complete ===');
}
