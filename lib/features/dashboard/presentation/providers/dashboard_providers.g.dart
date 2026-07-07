// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allSessions)
final allSessionsProvider = AllSessionsProvider._();

final class AllSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Session>>,
          List<Session>,
          FutureOr<List<Session>>
        >
    with $FutureModifier<List<Session>>, $FutureProvider<List<Session>> {
  AllSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allSessionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Session>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Session>> create(Ref ref) {
    return allSessions(ref);
  }
}

String _$allSessionsHash() => r'e0d9c70266bf775881589b63b9b0eb2a3c169342';

@ProviderFor(allAssessmentSessions)
final allAssessmentSessionsProvider = AllAssessmentSessionsProvider._();

final class AllAssessmentSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AssessmentSession>>,
          List<AssessmentSession>,
          FutureOr<List<AssessmentSession>>
        >
    with
        $FutureModifier<List<AssessmentSession>>,
        $FutureProvider<List<AssessmentSession>> {
  AllAssessmentSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allAssessmentSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allAssessmentSessionsHash();

  @$internal
  @override
  $FutureProviderElement<List<AssessmentSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssessmentSession>> create(Ref ref) {
    return allAssessmentSessions(ref);
  }
}

String _$allAssessmentSessionsHash() =>
    r'd5c42147178d44d9bac0bf5bb49a27e88c548b82';

@ProviderFor(dashboardData)
final dashboardDataProvider = DashboardDataProvider._();

final class DashboardDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardData>,
          DashboardData,
          FutureOr<DashboardData>
        >
    with $FutureModifier<DashboardData>, $FutureProvider<DashboardData> {
  DashboardDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardDataHash();

  @$internal
  @override
  $FutureProviderElement<DashboardData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardData> create(Ref ref) {
    return dashboardData(ref);
  }
}

String _$dashboardDataHash() => r'f3096f157fbe7b76d69c85594777958291b7636d';
