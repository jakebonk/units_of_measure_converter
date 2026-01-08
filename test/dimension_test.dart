import 'package:flutter_test/flutter_test.dart';
import 'package:units_of_measure_converter/units_of_measure_converter.dart';

void main() {
  group('Dimension', () {
    test('creates dimensionless by default', () {
      const dim = Dimension();
      expect(dim.isDimensionless, isTrue);
      expect(dim.toVector(), equals([0, 0, 0, 0, 0, 0, 0]));
    });

    test('creates dimension with specific exponents', () {
      const dim = Dimension(length: 1, time: -2, mass: 1);
      expect(dim.length, equals(1));
      expect(dim.time, equals(-2));
      expect(dim.mass, equals(1));
      expect(dim.isDimensionless, isFalse);
    });

    test('creates dimension from vector', () {
      final dim = Dimension.fromVector([1, -2, 1, 0, 0, 0, 0]);
      expect(dim.length, equals(1));
      expect(dim.time, equals(-2));
      expect(dim.mass, equals(1));
    });

    test('multiplies dimensions (adds exponents)', () {
      const dim1 = Dimension(length: 1, time: -1);
      const dim2 = Dimension(length: 1, time: -1);
      final result = dim1 * dim2;
      expect(result.length, equals(2));
      expect(result.time, equals(-2));
    });

    test('divides dimensions (subtracts exponents)', () {
      const dim1 = Dimension(length: 2);
      const dim2 = Dimension(length: 1);
      final result = dim1 / dim2;
      expect(result.length, equals(1));
    });

    test('raises dimension to power', () {
      const dim = Dimension(length: 1);
      final result = dim.pow(3);
      expect(result.length, equals(3));
    });

    test('inverts dimension', () {
      const dim = Dimension(length: 1, time: -2);
      final result = dim.inverse;
      expect(result.length, equals(-1));
      expect(result.time, equals(2));
    });

    test('equality works correctly', () {
      const dim1 = Dimension(length: 1, mass: 1);
      const dim2 = Dimension(length: 1, mass: 1);
      const dim3 = Dimension(length: 2, mass: 1);
      expect(dim1, equals(dim2));
      expect(dim1, isNot(equals(dim3)));
    });

    test('toString provides readable representation', () {
      const dim = Dimension(length: 1, time: -2, mass: 1);
      expect(dim.toString(), contains('L^1'));
      expect(dim.toString(), contains('T^-2'));
      expect(dim.toString(), contains('M^1'));
    });
  });
}
