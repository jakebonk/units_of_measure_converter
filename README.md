# Units of Measure Converter

A Dart/Flutter implementation of the Unified Code for Units of Measure (UCUM). Provides comprehensive support for unit validation, conversion, and lookup following the UCUM specification.

## Features

- **Unit Validation**: Validate UCUM unit strings and get suggestions for invalid units
- **Unit Conversion**: Convert between any commensurable units using dimensional analysis
- **Unit Lookup**: Search units by code, name, or synonyms
- **Commensurable Units**: Find all units that can be converted to/from a given unit
- **Special Units**: Handle non-linear conversions (temperature, logarithmic scales)
- **Compound Units**: Full support for complex unit expressions (e.g., `mg/dL`, `kg.m/s2`)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  units_of_measure_converter: ^1.0.0
```

## Quick Start

```dart
import 'package:units_of_measure_converter/units_of_measure_converter.dart';

void main() {
  final ucum = UcumService();

  // Validate a unit
  final validation = ucum.validateUnitString('mg/dL');
  print('Valid: ${validation.isValid}'); // Valid: true

  // Convert between units
  final result = ucum.convertUnitTo('km', 5.0, 'm');
  print('${result.fromValue} km = ${result.value} m'); // 5.0 km = 5000.0 m

  // Search for units
  final units = ucum.searchUnits('meter');
  for (final unit in units) {
    print('${unit.code}: ${unit.name}');
  }

  // Find commensurable units
  final lengthUnits = ucum.commensurablesList('m');
  print('Units convertible to meters: ${lengthUnits.length}');
}
```

## API Reference

### UcumService

The main entry point for all UCUM operations.

#### Validation

```dart
// Validate a unit string
ValidationResult validateUnitString(String unitString, {bool suggest = false});
```

#### Conversion

```dart
// Convert between units
ConversionResult convertUnitTo(
  String fromUnitCode,
  double fromVal,
  String toUnitCode, {
  double? molecularWeight,
  int? charge,
});

// Convert to base UCUM units
({double value, Dimension dimension, bool isSpecial}) convertToBaseUnits(
  String fromUnit,
  double fromVal,
);

// Check if units can be converted
bool areCommensurable(String unit1, String unit2);
```

#### Lookup

```dart
// Get unit by exact code
UcumUnit? getUnitByCode(String code);

// Search by name, code, or synonym
List<UcumUnit> searchUnits(String query, {int maxResults = 20});

// Find units by synonym
List<UcumUnit> checkSynonyms(String synonym);

// Get commensurable units
List<UcumUnit> commensurablesList(String unitString, {Set<UnitCategory>? categories});

// Get units by property
List<UcumUnit> getUnitsByProperty(String property);

// Get units by category
List<UcumUnit> getUnitsByCategory(UnitCategory category);
```

#### Parsing

```dart
// Parse a unit expression
ParsedUnit parseUnit(String unitString);
```

## Supported Units

### Base Units (7)

| Code | Name | Property |
|------|------|----------|
| m | meter | length |
| s | second | time |
| g | gram | mass |
| rad | radian | plane angle |
| K | Kelvin | temperature |
| C | coulomb | electric charge |
| cd | candela | luminous intensity |

### Prefixes

All SI prefixes from yotta (10^24) to yocto (10^-24), plus binary prefixes (Ki, Mi, Gi, Ti).

### Common Unit Categories

- **Length**: m, km, cm, mm, [in_i], [ft_i], [yd_i], [mi_i], etc.
- **Mass**: g, kg, mg, [lb_av], [oz_av], t, etc.
- **Time**: s, min, h, d, wk, mo, a
- **Volume**: L, mL, [gal_us], [pt_us], m3, etc.
- **Temperature**: K, Cel, [degF]
- **Pressure**: Pa, bar, atm, mm[Hg], [psi]
- **Energy**: J, cal, eV, [Btu]
- **Power**: W, [HP]
- **And many more...**

## Unit String Syntax

UCUM unit strings follow specific syntax rules:

- **Simple units**: `m`, `kg`, `s`
- **Prefixed units**: `km`, `mg`, `ns`
- **Exponents**: `m2`, `s-1`, `m3`
- **Multiplication**: `kg.m` (dot operator)
- **Division**: `m/s`, `kg/m3`
- **Parentheses**: `kg/(m.s2)`
- **Bracketed codes**: `[in_i]`, `[lb_av]`
- **Annotations**: `{annotation}` (ignored in calculations)

## Examples

### Temperature Conversion

```dart
// Celsius to Fahrenheit
final result = ucum.convertUnitTo('Cel', 100.0, '[degF]');
print('100°C = ${result.value}°F'); // 100°C = 212.0°F

// Fahrenheit to Celsius
final result2 = ucum.convertUnitTo('[degF]', 98.6, 'Cel');
print('98.6°F = ${result2.value}°C'); // 98.6°F = 37.0°C
```

### Clinical Concentrations

```dart
// mg/dL to g/L
final result = ucum.convertUnitTo('mg/dL', 100.0, 'g/L');
print('100 mg/dL = ${result.value} g/L'); // 100 mg/dL = 1.0 g/L

// mmol/L conversions
final result2 = ucum.convertUnitTo('mmol/L', 5.0, 'umol/L');
print('5 mmol/L = ${result2.value} μmol/L'); // 5 mmol/L = 5000.0 μmol/L
```

### Velocity

```dart
// km/h to m/s
final result = ucum.convertUnitTo('km/h', 100.0, 'm/s');
print('100 km/h = ${result.value} m/s'); // 100 km/h = 27.78 m/s
```

### Finding Commensurable Units

```dart
// Find all units that can convert to/from meters
final lengthUnits = ucum.commensurablesList('m');
for (final unit in lengthUnits) {
  print('${unit.code}: ${unit.name}');
}
// Output:
// m: meter
// [in_i]: inch
// [ft_i]: foot
// [yd_i]: yard
// [mi_i]: mile
// ...
```

## UCUM Compliance

This package follows the Unified Code for Units of Measure (UCUM) specification as defined at [https://ucum.org/ucum](https://ucum.org/ucum).

## References

- [UCUM Specification](https://ucum.org/ucum)
- [UCUM-LHC (Reference Implementation)](https://github.com/lhncbc/ucum-lhc)
- [NLM UCUM Resources](https://ucum.nlm.nih.gov/)

## License

MIT License - see LICENSE file for details.
