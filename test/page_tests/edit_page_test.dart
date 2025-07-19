import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lournal/pages/edit_page.dart';
import 'package:lournal/services/firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:network_image_mock/network_image_mock.dart';

// Import the generated mock file
import 'edit_page_test.mocks.dart';

// Generate a mock for FirestoreService.
@GenerateMocks([FirestoreService])
void main() {
  late MockFirestoreService mockFirestoreService;
  final navigatorKey = GlobalKey<NavigatorState>();

  setUp(() {
    mockFirestoreService = MockFirestoreService();
  });

  // Updated helper to accept an optional imageUrl
  Future<void> pumpEditPage(WidgetTester tester, {String? imageUrl}) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: EditPage(
          docID: 'testDocID',
          title: 'Test Title',
          content: 'Test Content',
          translation: 'Test Translation',
          feedback: 'Test Feedback',
          type: 'Test Type',
          language: 'Test Language',
          score: 80,
          firestoreService: mockFirestoreService,
          imageUrl: imageUrl, // Pass the imageUrl to the widget
        ),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.blue,
            secondary: Colors.white,
            inversePrimary: Colors.black,
            tertiary: Colors.green,
          ),
        ),
      ),
    );
  }

  testWidgets('EditPage renders all UI elements correctly', (WidgetTester tester) async {
    await pumpEditPage(tester);

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test Content'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('Tapping the back button pops the page', (WidgetTester tester) async {
    await pumpEditPage(tester);
    expect(find.byType(EditPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(EditPage), findsNothing);
  });

  // New test case for when an image URL is provided
  testWidgets('EditPage with imageUrl displays an Image widget', (WidgetTester tester) async {
    // Use mockNetworkImagesFor to handle the Image.network call
    await mockNetworkImagesFor(() async {
      await pumpEditPage(tester, imageUrl: 'https://fakeurl.com/image.jpg');

      // Check if the Image widget is present
      expect(find.byType(Image), findsOneWidget);
    });
  });

  // New test case for when the image URL is null
  testWidgets('EditPage without imageUrl does not display an Image widget', (WidgetTester tester) async {
    await pumpEditPage(tester, imageUrl: null);

    // Check that no Image widget is rendered
    expect(find.byType(Image), findsNothing);
  });
}
