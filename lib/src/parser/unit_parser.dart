import '../models/models.dart';
import '../data/ucum_definitions.dart';

/// Token types for lexical analysis
enum TokenType {
  unit,
  prefix,
  number,
  multiply,
  divide,
  power,
  openParen,
  closeParen,
  openBracket,
  closeBracket,
  annotation,
  end,
}

/// Represents a token from the lexer
class Token {
  final TokenType type;
  final String value;
  final int position;

  const Token(this.type, this.value, this.position);

  @override
  String toString() => 'Token($type, "$value", pos=$position)';
}

/// Parses UCUM unit expressions into structured ParsedUnit objects.
///
/// Supports:
/// - Simple units: m, kg, s
/// - Prefixed units: km, mg, ns
/// - Compound units: m/s, kg.m/s2
/// - Powers: m2, m-1
/// - Parentheses: kg/(m.s2)
/// - Annotations: {annotation}
class UnitParser {
  final Map<String, UcumUnit> _unitsByCode = {};
  final Map<String, UcumUnit> _unitsByCiCode = {};
  final Map<String, UcumPrefix> _prefixesByCode = {};
  final Map<String, UcumPrefix> _prefixesByCiCode = {};

  /// Whether to use case-sensitive matching (default true)
  final bool caseSensitive;

  UnitParser({this.caseSensitive = true}) {
    _initializeMaps();
  }

  void _initializeMaps() {
    // Build unit maps
    for (final unit in UcumDefinitions.allUnits) {
      _unitsByCode[unit.code] = unit;
      _unitsByCiCode[unit.ciCode.toUpperCase()] = unit;
    }

    // Build prefix maps
    for (final prefix in UcumDefinitions.prefixes) {
      _prefixesByCode[prefix.code] = prefix;
      _prefixesByCiCode[prefix.ciCode.toUpperCase()] = prefix;
    }
  }

  /// Add a custom unit to the parser
  void addUnit(UcumUnit unit) {
    _unitsByCode[unit.code] = unit;
    _unitsByCiCode[unit.ciCode.toUpperCase()] = unit;
  }

  /// Get a unit by code
  UcumUnit? getUnit(String code) {
    if (caseSensitive) {
      return _unitsByCode[code];
    } else {
      return _unitsByCiCode[code.toUpperCase()] ?? _unitsByCode[code];
    }
  }

  /// Get all registered units
  List<UcumUnit> get allUnits => _unitsByCode.values.toList();

  /// Get a prefix by code
  UcumPrefix? getPrefix(String code) {
    if (caseSensitive) {
      return _prefixesByCode[code];
    } else {
      return _prefixesByCiCode[code.toUpperCase()] ?? _prefixesByCode[code];
    }
  }

  /// Parse a UCUM unit string into a ParsedUnit
  ParsedUnit parse(String unitString) {
    if (unitString.isEmpty) {
      return ParsedUnit(
        original: unitString,
        magnitude: 1.0,
        dimension: const Dimension(),
        error: 'Empty unit string',
      );
    }

    try {
      final tokens = _tokenize(unitString);
      return _parseExpression(tokens, unitString);
    } catch (e) {
      return ParsedUnit(
        original: unitString,
        magnitude: 1.0,
        dimension: const Dimension(),
        error: 'Parse error: $e',
      );
    }
  }

  /// Tokenize the unit string
  List<Token> _tokenize(String input) {
    final tokens = <Token>[];
    var pos = 0;

    while (pos < input.length) {
      final char = input[pos];

      // Skip whitespace
      if (char == ' ' || char == '\t') {
        pos++;
        continue;
      }

      // Operators
      if (char == '.') {
        tokens.add(Token(TokenType.multiply, '.', pos));
        pos++;
        continue;
      }
      if (char == '/') {
        tokens.add(Token(TokenType.divide, '/', pos));
        pos++;
        continue;
      }
      if (char == '(') {
        tokens.add(Token(TokenType.openParen, '(', pos));
        pos++;
        continue;
      }
      if (char == ')') {
        tokens.add(Token(TokenType.closeParen, ')', pos));
        pos++;
        continue;
      }

      // Annotation in curly braces
      if (char == '{') {
        final endBrace = input.indexOf('}', pos);
        if (endBrace == -1) {
          throw FormatException('Unclosed annotation at position $pos');
        }
        tokens.add(Token(TokenType.annotation, input.substring(pos, endBrace + 1), pos));
        pos = endBrace + 1;
        continue;
      }

      // Number (exponent) - must check before unit atoms since units can start with [
      if (_isDigitOrSign(char, pos, input)) {
        final numResult = _parseNumber(input, pos);
        tokens.add(Token(TokenType.number, numResult.value, pos));
        pos = numResult.endPos;
        continue;
      }

      // Unit atom - can be letters, square brackets, or combinations
      // Per UCUM spec §5: square brackets are lexical elements (part of unit atom),
      // not syntactical tokens. They can appear anywhere: [abc], ab[cd], [ab]cd, ab[cd]ef
      final unitResult = _parseUnitAtom(input, pos);
      if (unitResult != null) {
        tokens.add(Token(TokenType.unit, unitResult.value, pos));
        pos = unitResult.endPos;

        // Check for exponent after unit
        if (pos < input.length) {
          final expResult = _tryParseExponent(input, pos);
          if (expResult != null) {
            tokens.add(Token(TokenType.number, expResult.value, pos));
            pos = expResult.endPos;
          }
        }
        continue;
      }

      throw FormatException('Unexpected character "$char" at position $pos');
    }

    tokens.add(Token(TokenType.end, '', pos));
    return tokens;
  }

  bool _isDigitOrSign(String char, int pos, String input) {
    if (char == '-' || char == '+') {
      // Only treat as number if followed by digit
      return pos + 1 < input.length && _isDigit(input[pos + 1]);
    }
    return _isDigit(char);
  }

  bool _isDigit(String char) {
    return char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
  }

  bool _isLetter(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) || // A-Z
        (code >= 97 && code <= 122) || // a-z
        char == '_' ||
        char == '%' ||
        char == "'" ;
  }

  ({String value, int endPos}) _parseNumber(String input, int pos) {
    var end = pos;
    if (input[end] == '-' || input[end] == '+') {
      end++;
    }
    while (end < input.length && _isDigit(input[end])) {
      end++;
    }
    return (value: input.substring(pos, end), endPos: end);
  }

  ({String value, int endPos})? _tryParseExponent(String input, int pos) {
    if (pos >= input.length) return null;

    final char = input[pos];
    if (_isDigit(char) || char == '-' || char == '+') {
      return _parseNumber(input, pos);
    }
    return null;
  }

  /// Parse a unit atom which may contain letters and square bracket pairs.
  /// Per UCUM spec §5: square brackets are lexical elements (part of unit atom).
  /// Valid patterns: [abc], ab[cd], [ab]cd, ab[cd]ef[gh], etc.
  /// Square brackets must be matched pairs and cannot be nested.
  ({String value, int endPos})? _parseUnitAtom(String input, int pos) {
    var end = pos;
    var inBracket = false;

    while (end < input.length) {
      final char = input[end];

      if (inBracket) {
        // Inside brackets: accept any printable ASCII (33-126) except nested [
        if (char == ']') {
          inBracket = false;
          end++;
        } else if (char == '[') {
          // Nested brackets not allowed per spec
          break;
        } else {
          final code = char.codeUnitAt(0);
          if (code >= 33 && code <= 126) {
            end++;
          } else {
            break;
          }
        }
      } else {
        // Outside brackets: accept letters or opening bracket
        if (char == '[') {
          inBracket = true;
          end++;
        } else if (_isLetter(char)) {
          end++;
        } else {
          break;
        }
      }
    }

    // Don't return partial result if we're still inside an unclosed bracket
    if (inBracket) {
      return null;
    }

    if (end == pos) return null;
    return (value: input.substring(pos, end), endPos: end);
  }

  /// Parse the token stream into a ParsedUnit
  ParsedUnit _parseExpression(List<Token> tokens, String original) {
    final helper = _ExpressionParser(
      tokens: tokens,
      original: original,
      parseAtomicUnit: _parseAtomicUnit,
      pow: _pow,
    );
    return helper.parse();
  }

  /// Parse an atomic unit (possibly with prefix)
  /// Per UCUM spec §5: Square brackets are lexical elements that don't determine
  /// the prefix boundary, but they never span the boundary of unit atoms.
  ParsedUnit _parseAtomicUnit(String code, int exponent, String original) {
    // First try exact match with original code
    var unit = getUnit(code);
    UcumPrefix? prefix;

    if (unit != null) {
      final magnitude = _pow(unit.magnitude, exponent);
      final dimension = unit.dimension.pow(exponent);
      return ParsedUnit(
        original: original,
        unit: unit,
        exponent: exponent,
        magnitude: magnitude,
        dimension: dimension,
        isSpecial: unit.isSpecial,
      );
    }

    // Per UCUM spec: brackets don't determine prefix boundary
    // Strip brackets to find the "semantic" content for prefix matching
    final strippedCode = _stripBrackets(code);

    // Try exact match with stripped code (in case brackets were just decorative)
    if (strippedCode != code) {
      unit = getUnit(strippedCode);
      if (unit != null) {
        final magnitude = _pow(unit.magnitude, exponent);
        final dimension = unit.dimension.pow(exponent);
        return ParsedUnit(
          original: original,
          unit: unit,
          exponent: exponent,
          magnitude: magnitude,
          dimension: dimension,
          isSpecial: unit.isSpecial,
        );
      }
    }

    // Try to find prefix + unit combination using stripped code
    // Try longer prefixes first (e.g., 'da' before 'd')
    final sortedPrefixes = _prefixesByCode.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final prefixCode in sortedPrefixes) {
      if (strippedCode.startsWith(prefixCode)) {
        final remainingCode = strippedCode.substring(prefixCode.length);
        unit = getUnit(remainingCode);

        if (unit != null && unit.isMetric) {
          prefix = _prefixesByCode[prefixCode];
          final prefixMagnitude = prefix!.value;
          final magnitude = _pow(unit.magnitude * prefixMagnitude, exponent);
          final dimension = unit.dimension.pow(exponent);

          return ParsedUnit(
            original: original,
            unit: unit,
            prefix: prefix,
            exponent: exponent,
            magnitude: magnitude,
            dimension: dimension,
            isSpecial: unit.isSpecial,
          );
        }
      }
    }

    // Unit not found
    return ParsedUnit(
      original: original,
      magnitude: 1.0,
      dimension: const Dimension(),
      error: 'Unknown unit: $code',
    );
  }

  /// Strip square brackets from a unit code for prefix matching.
  /// Per UCUM spec, brackets are lexical elements that don't affect prefix detection.
  String _stripBrackets(String code) {
    final buffer = StringBuffer();
    for (var i = 0; i < code.length; i++) {
      final char = code[i];
      if (char != '[' && char != ']') {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  double _pow(double base, int exponent) {
    if (exponent == 0) return 1.0;
    if (exponent == 1) return base;
    if (exponent == -1) return 1.0 / base;

    var result = 1.0;
    final absExp = exponent.abs();
    for (var i = 0; i < absExp; i++) {
      result *= base;
    }
    return exponent > 0 ? result : 1.0 / result;
  }

  /// Validate a unit string
  ValidationResult validate(String unitString) {
    final parsed = parse(unitString);

    if (parsed.error != null) {
      return ValidationResult(
        isValid: false,
        messages: [parsed.error!],
        suggestions: _getSuggestions(unitString),
      );
    }

    return ValidationResult(
      isValid: true,
      unit: parsed,
      normalizedCode: parsed.code,
    );
  }

  /// Get suggestions for an invalid unit string
  List<String> _getSuggestions(String invalidUnit) {
    final suggestions = <String>[];
    final lowerInput = invalidUnit.toLowerCase();

    // Search by name and synonyms
    for (final unit in _unitsByCode.values) {
      if (unit.name.toLowerCase().contains(lowerInput) ||
          unit.synonyms.any((s) => s.toLowerCase().contains(lowerInput))) {
        suggestions.add(unit.code);
        if (suggestions.length >= 5) break;
      }
    }

    return suggestions;
  }
}

/// Helper class for parsing expressions with mutual recursion
class _ExpressionParser {
  final List<Token> tokens;
  final String original;
  final ParsedUnit Function(String code, int exponent, String original) parseAtomicUnit;
  final double Function(double base, int exponent) pow;
  int _index = 0;

  _ExpressionParser({
    required this.tokens,
    required this.original,
    required this.parseAtomicUnit,
    required this.pow,
  });

  ParsedUnit parse() {
    return _parseTerm();
  }

  ParsedUnit _parseTerm() {
    var left = _parseUnit();

    while (_index < tokens.length) {
      final op = tokens[_index];

      if (op.type == TokenType.multiply) {
        _index++;
        final right = _parseUnit();
        left = ParsedUnit(
          original: original,
          magnitude: left.magnitude * right.magnitude,
          dimension: left.dimension * right.dimension,
          components: [...left.components, right],
          isSpecial: left.isSpecial || right.isSpecial,
        );
      } else if (op.type == TokenType.divide) {
        _index++;
        final right = _parseUnit();
        left = ParsedUnit(
          original: original,
          magnitude: left.magnitude / right.magnitude,
          dimension: left.dimension / right.dimension,
          components: [...left.components, right],
          isSpecial: left.isSpecial || right.isSpecial,
        );
      } else {
        break;
      }
    }

    return left;
  }

  ParsedUnit _parseUnit() {
    if (_index >= tokens.length) {
      return ParsedUnit(
        original: original,
        magnitude: 1.0,
        dimension: const Dimension(),
        error: 'Unexpected end of expression',
      );
    }

    final token = tokens[_index];

    // Handle parentheses
    if (token.type == TokenType.openParen) {
      _index++; // consume '('
      final inner = _parseTerm();
      if (_index < tokens.length && tokens[_index].type == TokenType.closeParen) {
        _index++; // consume ')'
      }

      // Check for exponent after parentheses
      var exponent = 1;
      if (_index < tokens.length && tokens[_index].type == TokenType.number) {
        exponent = int.parse(tokens[_index].value);
        _index++;
      }

      if (exponent != 1) {
        return ParsedUnit(
          original: original,
          magnitude: pow(inner.magnitude, exponent),
          dimension: inner.dimension.pow(exponent),
          components: inner.components,
          exponent: exponent,
        );
      }
      return inner;
    }

    // Handle unit token
    if (token.type == TokenType.unit) {
      _index++;

      // Get exponent if present
      var exponent = 1;
      if (_index < tokens.length && tokens[_index].type == TokenType.number) {
        exponent = int.parse(tokens[_index].value);
        _index++;
      }

      return parseAtomicUnit(token.value, exponent, original);
    }

    // Handle annotation (dimensionless with annotation)
    if (token.type == TokenType.annotation) {
      _index++;
      return ParsedUnit(
        original: original,
        magnitude: 1.0,
        dimension: const Dimension(),
      );
    }

    // Handle unity "1"
    if (token.type == TokenType.number && token.value == '1') {
      _index++;
      return ParsedUnit(
        original: original,
        magnitude: 1.0,
        dimension: const Dimension(),
      );
    }

    return ParsedUnit(
      original: original,
      magnitude: 1.0,
      dimension: const Dimension(),
      error: 'Unexpected token: ${token.value}',
    );
  }
}
