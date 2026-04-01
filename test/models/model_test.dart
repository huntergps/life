import 'package:flutter_test/flutter_test.dart';
import 'package:galapagos_wildlife/models/category.model.dart';
import 'package:galapagos_wildlife/models/species.model.dart';
import 'package:galapagos_wildlife/models/island.model.dart';
import 'package:galapagos_wildlife/models/sighting.model.dart';
import 'package:galapagos_wildlife/models/visit_site.model.dart';
import 'package:galapagos_wildlife/models/user_profile.model.dart';

void main() {
  group('Category', () {
    test('primaryKey returns id', () {
      final c =
          Category(id: 5, slug: 'birds', nameEs: 'Aves', nameEn: 'Birds');
      expect(c.primaryKey, 5);
    });

    test('sortOrder defaults to 0', () {
      final c = Category(id: 1, slug: 's', nameEs: 'S', nameEn: 'S');
      expect(c.sortOrder, 0);
    });

    test('iconName is optional', () {
      final c = Category(id: 1, slug: 's', nameEs: 'S', nameEn: 'S');
      expect(c.iconName, isNull);

      final c2 = Category(
          id: 2, slug: 't', nameEs: 'T', nameEn: 'T', iconName: 'turtle');
      expect(c2.iconName, 'turtle');
    });
  });

  group('Species', () {
    test('primaryKey returns id', () {
      final s = Species(
        id: 42,
        categoryId: 1,
        commonNameEs: 'X',
        commonNameEn: 'X',
        scientificName: 'X x',
      );
      expect(s.primaryKey, 42);
    });

    test('isEndemic defaults to false', () {
      final s = Species(
        id: 1,
        categoryId: 1,
        commonNameEs: 'X',
        commonNameEn: 'X',
        scientificName: 'X x',
      );
      expect(s.isEndemic, false);
    });

    test('optional numeric fields are null by default', () {
      final s = Species(
        id: 1,
        categoryId: 1,
        commonNameEs: 'X',
        commonNameEn: 'X',
        scientificName: 'X x',
      );
      expect(s.weightKg, isNull);
      expect(s.sizeCm, isNull);
      expect(s.populationEstimate, isNull);
      expect(s.lifespanYears, isNull);
    });

    test('arachnid fields are accessible', () {
      final s = Species(
        id: 1,
        categoryId: 6,
        commonNameEs: 'Arana',
        commonNameEn: 'Spider',
        scientificName: 'Araneae sp',
        buildsWeb: true,
        webType: 'orb',
        venomousToHumans: false,
        sizeMmFemaleMin: 5.0,
        sizeMmFemaleMax: 12.0,
      );
      expect(s.buildsWeb, true);
      expect(s.webType, 'orb');
      expect(s.venomousToHumans, false);
      expect(s.sizeMmFemaleMin, 5.0);
      expect(s.sizeMmFemaleMax, 12.0);
    });
  });

  group('Island', () {
    test('primaryKey returns id', () {
      final i = Island(id: 3, nameEs: 'Isabela', nameEn: 'Isabela');
      expect(i.primaryKey, 3);
    });

    test('coordinates and area are optional', () {
      final i = Island(id: 1, nameEs: 'X', nameEn: 'X');
      expect(i.latitude, isNull);
      expect(i.longitude, isNull);
      expect(i.areaKm2, isNull);
    });
  });

  group('VisitSite', () {
    test('primaryKey returns id', () {
      final vs = VisitSite(id: 10, nameEs: 'Tortuga Bay');
      expect(vs.primaryKey, 10);
    });

    test('islandId and nameEn are nullable', () {
      final vs = VisitSite(id: 1, nameEs: 'Sitio');
      expect(vs.islandId, isNull);
      expect(vs.nameEn, isNull);
    });
  });

  group('Sighting', () {
    test('primaryKey returns id', () {
      final s = Sighting(id: 1, userId: 'u1', speciesId: 42);
      expect(s.primaryKey, 1);
    });

    test('observedAt is optional', () {
      final s = Sighting(id: 1, userId: 'u1', speciesId: 42);
      expect(s.observedAt, isNull);
    });
  });

  group('UserProfile', () {
    test('primaryKey returns id (String)', () {
      final p = UserProfile(id: 'abc-123');
      expect(p.primaryKey, 'abc-123');
    });

    test('isBirthdayToday returns true when month and day match', () {
      final today = DateTime.now();
      final p = UserProfile(
        id: 'abc',
        birthDate: DateTime(1990, today.month, today.day),
      );
      expect(p.isBirthdayToday, true);
    });

    test('isBirthdayToday returns false for different date', () {
      // Use a date guaranteed to differ from today
      final today = DateTime.now();
      final otherMonth = today.month == 1 ? 12 : today.month - 1;
      final p = UserProfile(
        id: 'def',
        birthDate: DateTime(1990, otherMonth, 15),
      );
      expect(p.isBirthdayToday, false);
    });

    test('isBirthdayToday returns false when birthDate is null', () {
      final p = UserProfile(id: 'ghi');
      expect(p.isBirthdayToday, false);
    });
  });
}
