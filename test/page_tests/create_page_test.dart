import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:lournal/pages/create_page.dart';
import 'package:lournal/pages/finish_page.dart';
import 'package:lournal/services/firestore.dart';
import 'package:lournal/services/storage_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'create_page_test.mocks.dart';

// Mock for ImagePicker using the correct PickedFile type
class MockImagePicker extends Mock
    with MockPlatformInterfaceMixin
    implements ImagePickerPlatform {

  @override
  Future<PickedFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) {
    return super.noSuchMethod(
      Invocation.method(
        #pickImage,
        [],
        {
          #source: source,
          #maxWidth: maxWidth,
          #maxHeight: maxHeight,
          #imageQuality: imageQuality,
          #preferredCameraDevice: preferredCameraDevice,
        },
      ),
      // Use PickedFile to match the expected type
      returnValue: Future.value(PickedFile('fake_path')),
    );
  }
}

@GenerateMocks([
  FirebaseFunctions,
  HttpsCallable,
  FirestoreService,
  StorageService,
  HttpsCallableResult
])
void main() {
  late MockFirebaseFunctions mockFirebaseFunctions;
  late MockHttpsCallable mockHttpsCallable;
  late MockFirestoreService mockFirestoreService;
  late MockStorageService mockStorageService;
  late MockHttpsCallableResult mockHttpsCallableResult;
  late MockImagePicker mockImagePicker;

  setUp(() {
    mockFirebaseFunctions = MockFirebaseFunctions();
    mockHttpsCallable = MockHttpsCallable();
    mockFirestoreService = MockFirestoreService();
    mockStorageService = MockStorageService();
    mockHttpsCallableResult = MockHttpsCallableResult();
    mockImagePicker = MockImagePicker();
    ImagePickerPlatform.instance = mockImagePicker;

    provideDummy<HttpsCallable>(mockHttpsCallable);
    when(mockFirebaseFunctions.httpsCallable(any)).thenReturn(mockHttpsCallable);
  });

  Widget createTestableWidget({
    String? docID,
    String language = 'en',
    String type = 'journal',
    String title = '',
    String content = '',
    String? imageUrl,
  }) {
    return MaterialApp(
      home: CreatePage(
        docID: docID,
        language: language,
        type: type,
        title: title,
        content: content,
        imageUrl: imageUrl,
        firestoreService: mockFirestoreService,
        functions: mockFirebaseFunctions,
        storageService: mockStorageService,
      ),
    );
  }

  final titleField = find.byKey(const ValueKey('title_field'));
  final contentField = find.byKey(const ValueKey('content_field'));
  final saveButton = find.widgetWithText(ElevatedButton, 'Save');
  final addImageButton = find.byIcon(Icons.add);

  group('Image Handling', () {
    testWidgets('displays existing network image on load', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createTestableWidget(imageUrl: 'http://example.com/image.png'));
        expect(find.byType(Image), findsOneWidget);
        expect(find.byWidgetPredicate((widget) => widget is Image && widget.image is NetworkImage), findsOneWidget);
      });
    });

    testWidgets('picking an image displays it and removes network image', (tester) async {
      await mockNetworkImagesFor(() async {
        final fakeImage = PickedFile('test/fake_image.jpg');
        when(mockImagePicker.pickImage(source: ImageSource.gallery)).thenAnswer((_) async => fakeImage);

        await tester.pumpWidget(createTestableWidget(imageUrl: 'http://example.com/image.png'));

        expect(find.byWidgetPredicate((widget) => widget is Image && widget.image is NetworkImage), findsOneWidget);

        await tester.tap(addImageButton);
        await tester.pumpAndSettle();

        expect(find.byWidgetPredicate((widget) => widget is Image && widget.image is FileImage), findsOneWidget);
        expect(find.byWidgetPredicate((widget) => widget is Image && widget.image is NetworkImage), findsNothing);
      });
    });

    testWidgets('saves a new note with a newly picked image', (tester) async {
      final fakeImage = PickedFile('test/fake_image.jpg');
      const uploadedUrl = 'http://example.com/uploaded.png';

      when(mockImagePicker.pickImage(source: ImageSource.gallery)).thenAnswer((_) async => fakeImage);
      when(mockStorageService.uploadNoteImage(any)).thenAnswer((_) async => uploadedUrl);

      final fakeAiResponse = {'translation': '', 'feedback': '', 'score': '100'};
      when(mockHttpsCallableResult.data).thenReturn(fakeAiResponse);
      when(mockHttpsCallable.call(any)).thenAnswer((_) async => mockHttpsCallableResult);

      await tester.pumpWidget(createTestableWidget());

      await tester.enterText(titleField, 'Image Note');
      await tester.enterText(contentField, 'Note with an image.');
      await tester.tap(addImageButton);
      await tester.pumpAndSettle();

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      verify(mockStorageService.uploadNoteImage(any)).called(1);
      verify(mockFirestoreService.addNote(
        title: 'Image Note',
        content: 'Note with an image.',
        language: 'en',
        type: 'journal',
        translation: '',
        feedback: '',
        score: 100,
        imageUrl: uploadedUrl,
      )).called(1);
    });

    testWidgets('updates an existing note with a new image', (tester) async {
      final fakeImage = PickedFile('test/fake_image.jpg');
      const newUploadedUrl = 'http://example.com/new_image.png';

      when(mockImagePicker.pickImage(source: ImageSource.gallery)).thenAnswer((_) async => fakeImage);
      when(mockStorageService.uploadNoteImage(any)).thenAnswer((_) async => newUploadedUrl);

      final fakeAiResponse = {'translation': '', 'feedback': '', 'score': '100'};
      when(mockHttpsCallableResult.data).thenReturn(fakeAiResponse);
      when(mockHttpsCallable.call(any)).thenAnswer((_) async => mockHttpsCallableResult);

      await tester.pumpWidget(createTestableWidget(
        docID: 'noteToUpdate',
        title: 'Original Title',
        content: 'Original Content',
        imageUrl: 'http://example.com/original.png',
      ));

      await tester.tap(addImageButton);
      await tester.pumpAndSettle();

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      verify(mockStorageService.uploadNoteImage(any)).called(1);
      verify(mockFirestoreService.updateNote(
        docID: 'noteToUpdate',
        title: 'Original Title',
        content: 'Original Content',
        language: 'en',
        type: 'journal',
        translation: '',
        feedback: '',
        score: 100,
        imageUrl: newUploadedUrl,
      )).called(1);
    });
  });
}
