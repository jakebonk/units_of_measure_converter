import 'dimension.dart';
import 'prefix.dart';

/// The category of a unit for filtering purposes
enum UnitCategory {
  /// Clinical units commonly used in healthcare
  clinical,

  /// Non-clinical units
  nonclinical,

  /// Obsolete units (kept for historical compatibility)
  obsolete,

  /// Physical constants
  constant,
}

/// Represents a UCUM unit definition.
class UcumUnit {
  /// Whether this is a base unit
  final bool isBase;

  /// Full name of the unit (e.g., 'meter', 'kilogram')
  final String name;

  /// Plural form of the unit name (e.g., 'meters', 'kilograms')
  final String? pluralName;

  /// Case-sensitive UCUM code (e.g., 'm', 'kg')
  final String code;

  /// Case-insensitive UCUM code (e.g., 'M', 'KG')
  final String ciCode;

  /// The physical property this unit measures (e.g., 'length', 'mass')
  final String property;

  /// The magnitude relative to base units
  final double magnitude;

  /// The dimensional vector
  final Dimension dimension;

  /// Print symbol for display
  final String? printSymbol;

  /// Unit class (e.g., 'SI', 'dimless')
  final String? unitClass;

  /// Whether this unit accepts metric prefixes
  final bool isMetric;

  /// Whether this is a special unit (requires non-linear conversion)
  final bool isSpecial;

  /// Whether this is an arbitrary unit
  final bool isArbitrary;

  /// Conversion function name for special units (e.g., 'Cel' for Celsius)
  final String? conversionFunction;

  /// Conversion prefix for special units
  final double? conversionPrefix;

  /// Alternative names/synonyms for this unit
  final List<String> synonyms;

  /// Source of the unit definition
  final String? source;

  /// LOINC property
  final String? loincProperty;

  /// Category of the unit
  final UnitCategory? category;

  /// Guidance for using this unit
  final String? guidance;

  /// The unit string this unit is defined in terms of
  final String? definitionUnit;

  /// The numeric factor for the definition
  final double? definitionFactor;

  const UcumUnit({
    required this.isBase,
    required this.name,
    this.pluralName,
    required this.code,
    required this.ciCode,
    required this.property,
    required this.magnitude,
    required this.dimension,
    this.printSymbol,
    this.unitClass,
    this.isMetric = false,
    this.isSpecial = false,
    this.isArbitrary = false,
    this.conversionFunction,
    this.conversionPrefix,
    this.synonyms = const [],
    this.source,
    this.loincProperty,
    this.category,
    this.guidance,
    this.definitionUnit,
    this.definitionFactor,
  });

  /// Creates a unit from JSON data
  factory UcumUnit.fromJson(Map<String, dynamic> json) {
    final synonyms =
        (json['synonyms'] as List?)?.cast<String>() ?? const <String>[];
    final name = json['name'] as String;
    return UcumUnit(
      isBase: json['isBase'] as bool? ?? false,
      name: name,
      pluralName: json['pluralName'] as String? ?? _extractPluralName(name, synonyms),
      code: json['code'] as String,
      ciCode: json['ciCode'] as String? ?? json['code'] as String,
      property: json['property'] as String? ?? '',
      magnitude: (json['magnitude'] as num?)?.toDouble() ?? 1.0,
      dimension: json['dimVec'] != null
          ? Dimension.fromVector(
              (json['dimVec'] as List).map((e) => e as int).toList())
          : const Dimension(),
      printSymbol: json['printSymbol'] as String?,
      unitClass: json['class'] as String?,
      isMetric: json['isMetric'] as bool? ?? false,
      isSpecial: json['isSpecial'] as bool? ?? false,
      isArbitrary: json['isArbitrary'] as bool? ?? false,
      conversionFunction: json['cnv'] as String?,
      conversionPrefix: (json['cnvPfx'] as num?)?.toDouble(),
      synonyms: synonyms,
      source: json['source'] as String?,
      loincProperty: json['loincProperty'] as String?,
      category: _parseCategory(json['category'] as String?),
      guidance: json['guidance'] as String?,
      definitionUnit: json['csUnitString'] as String?,
      definitionFactor: (json['baseFactor'] as num?)?.toDouble(),
    );
  }

  /// Extracts the plural name from synonyms if available.
  /// Looks for a synonym that ends with 's' and starts with the same letters as the name.
  static String? _extractPluralName(String name, List<String> synonyms) {
    if (synonyms.isEmpty) return null;
    final nameLower = name.toLowerCase();
    // Look for a synonym that is the plural form of the name
    for (final synonym in synonyms) {
      final synLower = synonym.toLowerCase();
      // Check if synonym ends with 's' and the name (without trailing 's') matches
      if (synLower.endsWith('s') && synLower != nameLower) {
        // Check if it's a simple plural (name + 's') or (name + 'es')
        if (synLower == '${nameLower}s' || synLower == '${nameLower}es') {
          return synonym;
        }
        // Check for irregular plurals where the synonym starts similarly
        if (synLower.startsWith(nameLower.substring(0, (nameLower.length * 0.6).floor()))) {
          return synonym;
        }
      }
    }
    return null;
  }

  static UnitCategory? _parseCategory(String? category) {
    if (category == null) return null;
    switch (category.toLowerCase()) {
      case 'clinical':
        return UnitCategory.clinical;
      case 'nonclinical':
        return UnitCategory.nonclinical;
      case 'obsolete':
        return UnitCategory.obsolete;
      case 'constant':
        return UnitCategory.constant;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() => {
        'isBase': isBase,
        'name': name,
        if (pluralName != null) 'pluralName': pluralName,
        'code': code,
        'ciCode': ciCode,
        'property': property,
        'magnitude': magnitude,
        'dimVec': dimension.toVector(),
        if (printSymbol != null) 'printSymbol': printSymbol,
        if (unitClass != null) 'class': unitClass,
        'isMetric': isMetric,
        'isSpecial': isSpecial,
        'isArbitrary': isArbitrary,
        if (conversionFunction != null) 'cnv': conversionFunction,
        if (conversionPrefix != null) 'cnvPfx': conversionPrefix,
        if (synonyms.isNotEmpty) 'synonyms': synonyms,
        if (source != null) 'source': source,
        if (loincProperty != null) 'loincProperty': loincProperty,
        if (category != null) 'category': category.toString().split('.').last,
        if (guidance != null) 'guidance': guidance,
        if (definitionUnit != null) 'csUnitString': definitionUnit,
        if (definitionFactor != null) 'baseFactor': definitionFactor,
      };

  /// Returns true if this unit can be converted to another unit
  bool isCommensurableWith(UcumUnit other) {
    return dimension == other.dimension;
  }

  @override
  String toString() => 'UcumUnit($code: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UcumUnit &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// Represents a parsed unit expression with its components.
class ParsedUnit {
  /// The original unit string
  final String original;

  /// The base unit
  final UcumUnit? unit;

  /// The prefix applied (if any)
  final UcumPrefix? prefix;

  /// The exponent (default 1)
  final int exponent;

  /// The combined magnitude (unit magnitude * prefix value ^ exponent)
  final double magnitude;

  /// The dimension (unit dimension ^ exponent)
  final Dimension dimension;

  /// List of component units (for compound units)
  final List<ParsedUnit> components;

  /// Whether this unit is special (requires non-linear conversion)
  final bool isSpecial;

  /// Any error message from parsing
  final String? error;

  const ParsedUnit({
    required this.original,
    this.unit,
    this.prefix,
    this.exponent = 1,
    required this.magnitude,
    required this.dimension,
    this.components = const [],
    this.isSpecial = false,
    this.error,
  });

  /// Returns true if this is a valid parsed unit
  bool get isValid =>
      error == null &&
      (unit != null || components.isNotEmpty || _isDimensionlessUnity);

  /// Returns true if this represents dimensionless unity (1)
  bool get _isDimensionlessUnity =>
      unit == null &&
      components.isEmpty &&
      magnitude == 1.0 &&
      dimension.isDimensionless;

  /// Returns the combined unit code
  String get code {
    if (components.isNotEmpty) {
      return components.map((c) => c.code).join('.');
    }
    final prefixCode = prefix?.code ?? '';
    final unitCode = unit?.code ?? '';
    final expStr = exponent == 1 ? '' : exponent.toString();
    return '$prefixCode$unitCode$expStr';
  }

  /// Returns the full name of the parsed unit.
  ///
  /// If [plural] is true, returns the plural form (e.g., 'kilometers').
  /// If [plural] is false, returns the singular form (e.g., 'kilometer').
  /// For compound units, returns names joined with spaces.
  String getName({required bool plural}) {
    if (components.isNotEmpty) {
      return components.map((c) => c.getName(plural: plural)).join(' ');
    }
    if (unit == null) {
      return original;
    }
    final prefixName = prefix?.name ?? '';
    final unitName = plural ? (unit!.pluralName ?? unit!.name) : unit!.name;
    return '$prefixName$unitName';
  }

  @override
  String toString() => 'ParsedUnit($original -> $code, mag=$magnitude)';
}

/// Result of a unit conversion operation
class ConversionResult {
  /// Whether the conversion was successful
  final bool success;

  /// The converted value
  final double? value;

  /// The source unit
  final String fromUnit;

  /// The target unit
  final String toUnit;

  /// The original value
  final double fromValue;

  /// Error or status message
  final String? message;

  /// Parsed source unit
  final ParsedUnit? fromParsed;

  /// Parsed target unit
  final ParsedUnit? toParsed;

  const ConversionResult({
    required this.success,
    this.value,
    required this.fromUnit,
    required this.toUnit,
    required this.fromValue,
    this.message,
    this.fromParsed,
    this.toParsed,
  });

  @override
  String toString() {
    if (success) {
      return '$fromValue $fromUnit = $value $toUnit';
    } else {
      return 'ConversionResult(failed: $message)';
    }
  }
}

/// Result of unit validation
class ValidationResult {
  /// Whether the unit string is valid
  final bool isValid;

  /// The parsed unit (if valid)
  final ParsedUnit? unit;

  /// The normalized UCUM code
  final String? normalizedCode;

  /// Error or warning messages
  final List<String> messages;

  /// Suggested corrections (for invalid units)
  final List<String> suggestions;

  const ValidationResult({
    required this.isValid,
    this.unit,
    this.normalizedCode,
    this.messages = const [],
    this.suggestions = const [],
  });

  @override
  String toString() {
    if (isValid) {
      return 'ValidationResult(valid: $normalizedCode)';
    } else {
      return 'ValidationResult(invalid: ${messages.join(", ")})';
    }
  }
}
