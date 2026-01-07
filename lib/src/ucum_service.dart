import 'models/models.dart';
import 'parser/unit_parser.dart';
import 'converter/unit_converter.dart';
import 'data/ucum_definitions.dart';

/// Main entry point for UCUM unit operations.
///
/// Provides a high-level API for:
/// - Unit validation
/// - Unit conversion
/// - Unit lookup and search
/// - Finding commensurable units
///
/// Example usage:
/// ```dart
/// final ucum = UcumService();
///
/// // Validate a unit string
/// final validation = ucum.validateUnitString('mg/dL');
/// print(validation.isValid); // true
///
/// // Convert between units
/// final result = ucum.convertUnitTo('kg', 1.0, 'g');
/// print(result.value); // 1000.0
///
/// // Search for units
/// final units = ucum.searchUnits('meter');
/// ```
class UcumService {
  static UcumService? _instance;

  final UnitParser _parser;
  final UnitConverter _converter;

  /// Private constructor for singleton pattern
  UcumService._internal()
      : _parser = UnitParser(),
        _converter = UnitConverter();

  /// Factory constructor returns singleton instance
  factory UcumService() {
    _instance ??= UcumService._internal();
    return _instance!;
  }

  /// Get the singleton instance
  static UcumService getInstance() => UcumService();

  /// Create a new non-singleton instance (useful for testing)
  static UcumService createInstance() {
    return UcumService._internal();
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  /// Validates a unit string.
  ///
  /// This method validates a unit string by checking if it matches a known
  /// unit code or can be parsed as a valid unit expression.
  ///
  /// Parameters:
  /// - [unitString]: The unit string to validate
  /// - [suggest]: If true, returns suggestions for invalid units
  ///
  /// Returns a [ValidationResult] containing:
  /// - [isValid]: Whether the unit is valid
  /// - [normalizedCode]: The normalized UCUM code
  /// - [messages]: Any error or warning messages
  /// - [suggestions]: Suggested corrections (if requested)
  ///
  /// Example:
  /// ```dart
  /// final result = ucum.validateUnitString('kg/m2');
  /// if (result.isValid) {
  ///   print('Valid unit: ${result.normalizedCode}');
  /// }
  /// ```
  ValidationResult validateUnitString(String unitString, {bool suggest = false}) {
    return _converter.validate(unitString, suggest: suggest);
  }

  // ============================================================
  // CONVERSION
  // ============================================================

  /// Converts a value from one unit to another.
  ///
  /// This method converts a numeric value from the source unit to the target unit.
  /// Both units must be commensurable (have the same dimensions).
  ///
  /// Parameters:
  /// - [fromUnitCode]: The source unit code (e.g., 'kg', 'm/s')
  /// - [fromVal]: The numeric value to convert
  /// - [toUnitCode]: The target unit code
  /// - [molecularWeight]: Optional molecular weight for mass-mole conversions
  /// - [charge]: Optional charge for equivalents conversions
  ///
  /// Returns a [ConversionResult] containing:
  /// - [success]: Whether the conversion succeeded
  /// - [value]: The converted value (if successful)
  /// - [message]: Error message (if failed)
  ///
  /// Example:
  /// ```dart
  /// final result = ucum.convertUnitTo('km', 5.0, 'm');
  /// if (result.success) {
  ///   print('${result.fromValue} km = ${result.value} m'); // 5.0 km = 5000.0 m
  /// }
  /// ```
  ConversionResult convertUnitTo(
    String fromUnitCode,
    double fromVal,
    String toUnitCode, {
    double? molecularWeight,
    int? charge,
  }) {
    return _converter.convert(
      fromVal,
      fromUnitCode,
      toUnitCode,
      molecularWeight: molecularWeight,
      charge: charge,
    );
  }

  /// Converts a value to base UCUM units.
  ///
  /// Decomposes the unit into its base unit components and returns
  /// the value expressed in those base units.
  ///
  /// Example:
  /// ```dart
  /// final result = ucum.convertToBaseUnits('km', 1.0);
  /// print(result.value); // 1000.0 (in meters)
  /// print(result.dimension); // L^1 (length dimension)
  /// ```
  ({double value, Dimension dimension, bool isSpecial}) convertToBaseUnits(
    String fromUnit,
    double fromVal,
  ) {
    return _converter.convertToBaseUnits(fromVal, fromUnit);
  }

  /// Checks if two units can be converted between each other.
  ///
  /// Returns true if the units have the same dimensions.
  ///
  /// Example:
  /// ```dart
  /// ucum.areCommensurable('kg', 'lb'); // true (both are mass)
  /// ucum.areCommensurable('m', 's'); // false (length vs time)
  /// ```
  bool areCommensurable(String unit1, String unit2) {
    return _converter.areCommensurable(unit1, unit2);
  }

  // ============================================================
  // LOOKUP & SEARCH
  // ============================================================

  /// Gets a list of units that can be converted to/from the given unit.
  ///
  /// Parameters:
  /// - [unitString]: The unit to find commensurable units for
  /// - [categories]: Optional set of categories to filter by
  ///
  /// Returns a list of units with the same dimensions.
  ///
  /// Example:
  /// ```dart
  /// final lengthUnits = ucum.commensurablesList('m');
  /// // Returns: [meter, inch, foot, yard, mile, ...]
  /// ```
  List<UcumUnit> commensurablesList(
    String unitString, {
    Set<UnitCategory>? categories,
  }) {
    return _converter.getCommensurableUnits(unitString, categories: categories);
  }

  /// Looks up a unit by its exact UCUM code.
  ///
  /// Returns the unit if found, null otherwise.
  ///
  /// Example:
  /// ```dart
  /// final meter = ucum.getUnitByCode('m');
  /// print(meter?.name); // 'meter'
  /// ```
  UcumUnit? getUnitByCode(String code) {
    return _parser.getUnit(code);
  }

  /// Searches for units by name, code, or synonyms.
  ///
  /// Returns units whose name, code, or synonyms contain the search term.
  ///
  /// Parameters:
  /// - [query]: The search term
  /// - [maxResults]: Maximum number of results to return (default 20)
  /// - [categories]: Optional categories to filter by
  ///
  /// Example:
  /// ```dart
  /// final results = ucum.searchUnits('meter');
  /// // Returns units like: meter, centimeter, kilometer, etc.
  /// ```
  List<UcumUnit> searchUnits(
    String query, {
    int maxResults = 20,
    Set<UnitCategory>? categories,
  }) {
    final lowerQuery = query.toLowerCase();
    final results = <UcumUnit>[];

    for (final unit in _parser.allUnits) {
      // Check category filter
      if (categories != null && categories.isNotEmpty) {
        if (unit.category == null || !categories.contains(unit.category)) {
          continue;
        }
      }

      // Check for match in code, name, or synonyms
      if (unit.code.toLowerCase().contains(lowerQuery) ||
          unit.name.toLowerCase().contains(lowerQuery) ||
          unit.synonyms.any((s) => s.toLowerCase().contains(lowerQuery))) {
        results.add(unit);
        if (results.length >= maxResults) break;
      }
    }

    return results;
  }

  /// Searches for units that match a synonym.
  ///
  /// Similar to [searchUnits] but focuses on synonym matching.
  ///
  /// Example:
  /// ```dart
  /// final results = ucum.checkSynonyms('inches');
  /// // Returns the inch unit
  /// ```
  List<UcumUnit> checkSynonyms(String synonym) {
    final lowerSynonym = synonym.toLowerCase();
    return _parser.allUnits
        .where((unit) =>
            unit.synonyms.any((s) => s.toLowerCase() == lowerSynonym) ||
            unit.name.toLowerCase() == lowerSynonym)
        .toList();
  }

  /// Gets all units of a specific property type.
  ///
  /// Example:
  /// ```dart
  /// final lengthUnits = ucum.getUnitsByProperty('length');
  /// ```
  List<UcumUnit> getUnitsByProperty(String property) {
    final lowerProperty = property.toLowerCase();
    return _parser.allUnits
        .where((unit) => unit.property.toLowerCase() == lowerProperty)
        .toList();
  }

  /// Gets all units in a specific category.
  ///
  /// Example:
  /// ```dart
  /// final clinicalUnits = ucum.getUnitsByCategory(UnitCategory.clinical);
  /// ```
  List<UcumUnit> getUnitsByCategory(UnitCategory category) {
    return _parser.allUnits.where((unit) => unit.category == category).toList();
  }

  /// Gets all available units.
  List<UcumUnit> getAllUnits() {
    return _parser.allUnits;
  }

  /// Gets all available prefixes.
  List<UcumPrefix> getAllPrefixes() {
    return UcumDefinitions.prefixes;
  }

  /// Gets all base units.
  List<UcumUnit> getBaseUnits() {
    return UcumDefinitions.baseUnits;
  }

  // ============================================================
  // PARSING
  // ============================================================

  /// Parses a unit string into a structured representation.
  ///
  /// Returns detailed information about the unit including its
  /// magnitude, dimensions, and components.
  ///
  /// Example:
  /// ```dart
  /// final parsed = ucum.parseUnit('kg.m/s2');
  /// print(parsed.magnitude); // magnitude relative to base units
  /// print(parsed.dimension); // M^1·L^1·T^-2 (force dimension)
  /// ```
  ParsedUnit parseUnit(String unitString) {
    return _parser.parse(unitString);
  }

  // ============================================================
  // CUSTOM UNITS
  // ============================================================

  /// Registers a custom unit.
  ///
  /// Allows adding new units not in the standard UCUM definitions.
  ///
  /// Example:
  /// ```dart
  /// ucum.addCustomUnit(UcumUnit(
  ///   isBase: false,
  ///   name: 'custom unit',
  ///   code: 'cust',
  ///   ciCode: 'CUST',
  ///   property: 'custom',
  ///   magnitude: 1.0,
  ///   dimension: Dimension(),
  /// ));
  /// ```
  void addCustomUnit(UcumUnit unit) {
    _parser.addUnit(unit);
  }
}
