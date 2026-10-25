import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fikir_sign/app.dart';

void main() {
  setUp(() async {
    dotenv.testLoad(fileInput: '''
API_BASE_URL=https://example.execute-api.region.amazonaws.com/prod
API_KEY=changeme
USE_MOCK_API=true
''');
  });

  testWidgets('FikirSignApp smoke test - loads initial consent screen', (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const FikirSignApp());
    await tester.pump();

    // Verify initial consent screen elements are rendered
    expect(find.text('FikirSign'), findsWidgets);
    expect(find.textContaining('Welcome to FikirSign'), findsOneWidget);
    expect(find.textContaining('Continue to Chat'), findsOneWidget);
  });
}
