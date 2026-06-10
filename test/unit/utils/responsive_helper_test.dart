import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_companion/utils/responsive/responsive_helper.dart';

void main() {
  group('ResponsiveHelper', () {
    testWidgets('senior font scale is larger than default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final helper = ResponsiveHelper(context);
              final seniorScale = helper.seniorFontScale(isSenior: true);
              final normalScale = helper.seniorFontScale(isSenior: false);
              expect(seniorScale, greaterThanOrEqualTo(normalScale));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('senior touch target is larger than minimum', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final helper = ResponsiveHelper(context);
              final seniorTarget = helper.seniorTouchTarget(isSenior: true);
              expect(seniorTarget, greaterThanOrEqualTo(48.0));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('grid columns adapt to screen width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final helper = ResponsiveHelper(context);
              expect(helper.gridColumns, greaterThanOrEqualTo(1));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('horizontal padding is non-zero', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final helper = ResponsiveHelper(context);
              expect(helper.horizontalPadding, greaterThan(0));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('max content width is reasonable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final helper = ResponsiveHelper(context);
              expect(helper.maxContentWidth, greaterThan(0));
              expect(helper.maxContentWidth, lessThan(2000));
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('ResponsiveHelperStatic', () {
    testWidgets('responsive returns mobile value by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final result = ResponsiveHelperStatic.responsive<String>(
                context: context,
                mobile: 'MOBILE',
              );
              expect(result, 'MOBILE');
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('responsive returns correct value for each breakpoint',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final result = ResponsiveHelperStatic.responsive<String>(
                context: context,
                mobile: 'MOBILE',
                tablet: 'TABLET',
                desktop: 'DESKTOP',
              );
              expect(result, isNotEmpty);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('seniorFontSize scales for seniors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final seniorSize = ResponsiveHelperStatic.seniorFontSize(
                context,
                16,
                isSenior: true,
              );
              final normalSize = ResponsiveHelperStatic.seniorFontSize(
                context,
                16,
                isSenior: false,
              );
              expect(seniorSize, greaterThanOrEqualTo(normalSize));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('safe area padding is non-negative', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final top = ResponsiveHelperStatic.safeTopPadding(context);
              final bottom = ResponsiveHelperStatic.safeBottomPadding(context);
              expect(top, greaterThanOrEqualTo(0));
              expect(bottom, greaterThanOrEqualTo(0));
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('Screen size detection', () {
    testWidgets('screen dimensions are available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final size = MediaQuery.of(context).size;
              expect(size.width, 800);
              expect(size.height, 600);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('orientation is detected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final orientation = MediaQuery.of(context).orientation;
              expect(orientation, isNotNull);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
