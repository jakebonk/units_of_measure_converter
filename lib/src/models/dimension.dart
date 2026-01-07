/// Represents the dimensional vector of a unit.
///
/// UCUM uses 7 base dimensions:
/// - Length (meter)
/// - Time (second)
/// - Mass (gram)
/// - Plane angle (radian)
/// - Temperature (Kelvin)
/// - Electric charge (coulomb)
/// - Luminous intensity (candela)
class Dimension {
  /// Length dimension exponent (meter)
  final int length;

  /// Time dimension exponent (second)
  final int time;

  /// Mass dimension exponent (gram)
  final int mass;

  /// Plane angle dimension exponent (radian)
  final int angle;

  /// Temperature dimension exponent (Kelvin)
  final int temperature;

  /// Electric charge dimension exponent (coulomb)
  final int charge;

  /// Luminous intensity dimension exponent (candela)
  final int luminosity;

  const Dimension({
    this.length = 0,
    this.time = 0,
    this.mass = 0,
    this.angle = 0,
    this.temperature = 0,
    this.charge = 0,
    this.luminosity = 0,
  });

  /// Creates a dimension from a list of exponents in order:
  /// [length, time, mass, angle, temperature, charge, luminosity]
  factory Dimension.fromVector(List<int> vector) {
    return Dimension(
      length: vector.isNotEmpty ? vector[0] : 0,
      time: vector.length > 1 ? vector[1] : 0,
      mass: vector.length > 2 ? vector[2] : 0,
      angle: vector.length > 3 ? vector[3] : 0,
      temperature: vector.length > 4 ? vector[4] : 0,
      charge: vector.length > 5 ? vector[5] : 0,
      luminosity: vector.length > 6 ? vector[6] : 0,
    );
  }

  /// Dimensionless (unity)
  static const Dimension dimensionless = Dimension();

  /// Returns the dimension as a vector
  List<int> toVector() => [
        length,
        time,
        mass,
        angle,
        temperature,
        charge,
        luminosity,
      ];

  /// Returns true if this dimension is dimensionless (all exponents are 0)
  bool get isDimensionless =>
      length == 0 &&
      time == 0 &&
      mass == 0 &&
      angle == 0 &&
      temperature == 0 &&
      charge == 0 &&
      luminosity == 0;

  /// Multiplies two dimensions (adds exponents)
  Dimension operator *(Dimension other) => Dimension(
        length: length + other.length,
        time: time + other.time,
        mass: mass + other.mass,
        angle: angle + other.angle,
        temperature: temperature + other.temperature,
        charge: charge + other.charge,
        luminosity: luminosity + other.luminosity,
      );

  /// Divides two dimensions (subtracts exponents)
  Dimension operator /(Dimension other) => Dimension(
        length: length - other.length,
        time: time - other.time,
        mass: mass - other.mass,
        angle: angle - other.angle,
        temperature: temperature - other.temperature,
        charge: charge - other.charge,
        luminosity: luminosity - other.luminosity,
      );

  /// Raises dimension to a power (multiplies all exponents)
  Dimension pow(int exponent) => Dimension(
        length: length * exponent,
        time: time * exponent,
        mass: mass * exponent,
        angle: angle * exponent,
        temperature: temperature * exponent,
        charge: charge * exponent,
        luminosity: luminosity * exponent,
      );

  /// Returns the inverse dimension (negates all exponents)
  Dimension get inverse => Dimension(
        length: -length,
        time: -time,
        mass: -mass,
        angle: -angle,
        temperature: -temperature,
        charge: -charge,
        luminosity: -luminosity,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dimension &&
          runtimeType == other.runtimeType &&
          length == other.length &&
          time == other.time &&
          mass == other.mass &&
          angle == other.angle &&
          temperature == other.temperature &&
          charge == other.charge &&
          luminosity == other.luminosity;

  @override
  int get hashCode => Object.hash(
        length,
        time,
        mass,
        angle,
        temperature,
        charge,
        luminosity,
      );

  @override
  String toString() {
    if (isDimensionless) return '1';

    final parts = <String>[];
    if (length != 0) parts.add('L^$length');
    if (time != 0) parts.add('T^$time');
    if (mass != 0) parts.add('M^$mass');
    if (angle != 0) parts.add('A^$angle');
    if (temperature != 0) parts.add('Θ^$temperature');
    if (charge != 0) parts.add('Q^$charge');
    if (luminosity != 0) parts.add('J^$luminosity');
    return parts.join('·');
  }
}
