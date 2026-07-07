// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bills_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedBillsMonth)
final selectedBillsMonthProvider = SelectedBillsMonthProvider._();

final class SelectedBillsMonthProvider
    extends $NotifierProvider<SelectedBillsMonth, DateTime> {
  SelectedBillsMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedBillsMonthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedBillsMonthHash();

  @$internal
  @override
  SelectedBillsMonth create() => SelectedBillsMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedBillsMonthHash() =>
    r'61b2cf98d5947ea7d627f0714d0034797b9aee06';

abstract class _$SelectedBillsMonth extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedBillsSessions)
final selectedBillsSessionsProvider = SelectedBillsSessionsProvider._();

final class SelectedBillsSessionsProvider
    extends $NotifierProvider<SelectedBillsSessions, Set<String>> {
  SelectedBillsSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedBillsSessionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedBillsSessionsHash();

  @$internal
  @override
  SelectedBillsSessions create() => SelectedBillsSessions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$selectedBillsSessionsHash() =>
    r'eeafccbef940db34a93b0f7810d371dbaa2ae676';

abstract class _$SelectedBillsSessions extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(billsSessionRows)
final billsSessionRowsProvider = BillsSessionRowsProvider._();

final class BillsSessionRowsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BillSessionRow>>,
          List<BillSessionRow>,
          FutureOr<List<BillSessionRow>>
        >
    with
        $FutureModifier<List<BillSessionRow>>,
        $FutureProvider<List<BillSessionRow>> {
  BillsSessionRowsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billsSessionRowsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billsSessionRowsHash();

  @$internal
  @override
  $FutureProviderElement<List<BillSessionRow>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BillSessionRow>> create(Ref ref) {
    return billsSessionRows(ref);
  }
}

String _$billsSessionRowsHash() => r'ccbf089691c3c51ef741756a09352073e585d561';
