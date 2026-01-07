/// Represents a UCUM metric prefix (e.g., kilo, milli, micro).
class UcumPrefix {
  /// Case-sensitive code (e.g., 'k' for kilo)
  final String code;

  /// Case-insensitive code (e.g., 'K' for kilo)
  final String ciCode;

  /// Full name (e.g., 'kilo')
  final String name;

  /// Print symbol (e.g., 'k')
  final String printSymbol;

  /// The numeric value of the prefix (e.g., 1000 for kilo)
  final double value;

  /// The exponent (e.g., 3 for kilo = 10^3)
  final int exponent;

  const UcumPrefix({
    required this.code,
    required this.ciCode,
    required this.name,
    required this.printSymbol,
    required this.value,
    required this.exponent,
  });

  /// Creates a prefix from JSON data
  factory UcumPrefix.fromJson(Map<String, dynamic> json) {
    return UcumPrefix(
      code: json['code'] as String,
      ciCode: json['ciCode'] as String,
      name: json['name'] as String,
      printSymbol: json['printSymbol'] as String,
      value: (json['value'] as num).toDouble(),
      exponent: json['exponent'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'ciCode': ciCode,
        'name': name,
        'printSymbol': printSymbol,
        'value': value,
        'exponent': exponent,
      };

  @override
  String toString() => 'UcumPrefix($code: $name = 10^$exponent)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UcumPrefix &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// Standard UCUM metric prefixes
class UcumPrefixes {
  UcumPrefixes._();

  static const yotta = UcumPrefix(
    code: 'Y',
    ciCode: 'YA',
    name: 'yotta',
    printSymbol: 'Y',
    value: 1e24,
    exponent: 24,
  );

  static const zetta = UcumPrefix(
    code: 'Z',
    ciCode: 'ZA',
    name: 'zetta',
    printSymbol: 'Z',
    value: 1e21,
    exponent: 21,
  );

  static const exa = UcumPrefix(
    code: 'E',
    ciCode: 'EX',
    name: 'exa',
    printSymbol: 'E',
    value: 1e18,
    exponent: 18,
  );

  static const peta = UcumPrefix(
    code: 'P',
    ciCode: 'PT',
    name: 'peta',
    printSymbol: 'P',
    value: 1e15,
    exponent: 15,
  );

  static const tera = UcumPrefix(
    code: 'T',
    ciCode: 'TR',
    name: 'tera',
    printSymbol: 'T',
    value: 1e12,
    exponent: 12,
  );

  static const giga = UcumPrefix(
    code: 'G',
    ciCode: 'GA',
    name: 'giga',
    printSymbol: 'G',
    value: 1e9,
    exponent: 9,
  );

  static const mega = UcumPrefix(
    code: 'M',
    ciCode: 'MA',
    name: 'mega',
    printSymbol: 'M',
    value: 1e6,
    exponent: 6,
  );

  static const kilo = UcumPrefix(
    code: 'k',
    ciCode: 'K',
    name: 'kilo',
    printSymbol: 'k',
    value: 1e3,
    exponent: 3,
  );

  static const hecto = UcumPrefix(
    code: 'h',
    ciCode: 'H',
    name: 'hecto',
    printSymbol: 'h',
    value: 1e2,
    exponent: 2,
  );

  static const deka = UcumPrefix(
    code: 'da',
    ciCode: 'DA',
    name: 'deka',
    printSymbol: 'da',
    value: 1e1,
    exponent: 1,
  );

  static const deci = UcumPrefix(
    code: 'd',
    ciCode: 'D',
    name: 'deci',
    printSymbol: 'd',
    value: 1e-1,
    exponent: -1,
  );

  static const centi = UcumPrefix(
    code: 'c',
    ciCode: 'C',
    name: 'centi',
    printSymbol: 'c',
    value: 1e-2,
    exponent: -2,
  );

  static const milli = UcumPrefix(
    code: 'm',
    ciCode: 'M',
    name: 'milli',
    printSymbol: 'm',
    value: 1e-3,
    exponent: -3,
  );

  static const micro = UcumPrefix(
    code: 'u',
    ciCode: 'U',
    name: 'micro',
    printSymbol: 'μ',
    value: 1e-6,
    exponent: -6,
  );

  static const nano = UcumPrefix(
    code: 'n',
    ciCode: 'N',
    name: 'nano',
    printSymbol: 'n',
    value: 1e-9,
    exponent: -9,
  );

  static const pico = UcumPrefix(
    code: 'p',
    ciCode: 'P',
    name: 'pico',
    printSymbol: 'p',
    value: 1e-12,
    exponent: -12,
  );

  static const femto = UcumPrefix(
    code: 'f',
    ciCode: 'F',
    name: 'femto',
    printSymbol: 'f',
    value: 1e-15,
    exponent: -15,
  );

  static const atto = UcumPrefix(
    code: 'a',
    ciCode: 'A',
    name: 'atto',
    printSymbol: 'a',
    value: 1e-18,
    exponent: -18,
  );

  static const zepto = UcumPrefix(
    code: 'z',
    ciCode: 'ZO',
    name: 'zepto',
    printSymbol: 'z',
    value: 1e-21,
    exponent: -21,
  );

  static const yocto = UcumPrefix(
    code: 'y',
    ciCode: 'YO',
    name: 'yocto',
    printSymbol: 'y',
    value: 1e-24,
    exponent: -24,
  );

  // Binary prefixes (for information units)
  static const kibi = UcumPrefix(
    code: 'Ki',
    ciCode: 'KIB',
    name: 'kibi',
    printSymbol: 'Ki',
    value: 1024,
    exponent: 10,
  );

  static const mebi = UcumPrefix(
    code: 'Mi',
    ciCode: 'MIB',
    name: 'mebi',
    printSymbol: 'Mi',
    value: 1048576,
    exponent: 20,
  );

  static const gibi = UcumPrefix(
    code: 'Gi',
    ciCode: 'GIB',
    name: 'gibi',
    printSymbol: 'Gi',
    value: 1073741824,
    exponent: 30,
  );

  static const tebi = UcumPrefix(
    code: 'Ti',
    ciCode: 'TIB',
    name: 'tebi',
    printSymbol: 'Ti',
    value: 1099511627776,
    exponent: 40,
  );

  /// All standard prefixes
  static const List<UcumPrefix> all = [
    yotta,
    zetta,
    exa,
    peta,
    tera,
    giga,
    mega,
    kilo,
    hecto,
    deka,
    deci,
    centi,
    milli,
    micro,
    nano,
    pico,
    femto,
    atto,
    zepto,
    yocto,
    kibi,
    mebi,
    gibi,
    tebi,
  ];

  /// Map of code to prefix for quick lookup
  static final Map<String, UcumPrefix> byCode = {
    for (final p in all) p.code: p,
  };

  /// Map of case-insensitive code to prefix
  static final Map<String, UcumPrefix> byCiCode = {
    for (final p in all) p.ciCode.toUpperCase(): p,
  };
}
