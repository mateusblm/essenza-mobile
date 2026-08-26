import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:essenza_mobile/catalog/data/catalog_repository.dart';
import 'package:essenza_mobile/catalog/models/collection_insights.dart';
import 'package:essenza_mobile/core/theme/app_theme.dart';
import 'package:essenza_mobile/diary/data/diary_repository.dart';
import 'package:essenza_mobile/home/home_page.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

class MockDiaryRepository extends Mock implements DiaryRepository {}

void main() {
  test('uses modern sage palette in both themes', () {
    expect(EssenzaColors.burgundy, const Color(0xFF3F5B50));
    expect(EssenzaColors.gold, const Color(0xFFC98662));
    expect(EssenzaColors.darkBackground, const Color(0xFF121916));
  });

  testWidgets('shows daily recommendation from collection insights', (tester) async {
    final catalog = MockCatalogRepository();
    final diary = MockDiaryRepository();
    when(() => catalog.collectionInsights()).thenAnswer(
      (_) async => const CollectionInsights(
        perfumeCount: 2,
        olfactiveProfile: [
          CollectionInsightScore(label: 'Amadeirado', percentage: 70),
        ],
        climates: [
          CollectionInsightScore(label: 'Frio', percentage: 80),
        ],
        occasions: ['Noite'],
        recommendations: ['Terre d’Hermès'],
      ),
    );

    Future<void> upload(
      Uint8List bytes, {
      required String filename,
      required String contentType,
    }) async {}

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'Open Sans'),
        home: HomePage(
          repository: catalog,
          diaryRepository: diary,
          onLogout: () async {},
          themeMode: ThemeMode.light,
          onThemeModeChanged: (_) {},
          loadAvatar: () async => null,
          uploadAvatar: upload,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ESCOLHA DO DIA'), findsOneWidget);
    expect(find.text('Terre d’Hermès'), findsWidgets);
  });
}
