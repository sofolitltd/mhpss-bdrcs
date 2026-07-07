// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clientBills)
final clientBillsProvider = ClientBillsFamily._();

final class ClientBillsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Bill>>,
          List<Bill>,
          Stream<List<Bill>>
        >
    with $FutureModifier<List<Bill>>, $StreamProvider<List<Bill>> {
  ClientBillsProvider._({
    required ClientBillsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clientBillsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clientBillsHash();

  @override
  String toString() {
    return r'clientBillsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Bill>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Bill>> create(Ref ref) {
    final argument = this.argument as String;
    return clientBills(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientBillsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clientBillsHash() => r'24595f04a16c1ea7d3e7445a3c9d144f763c1625';

final class ClientBillsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Bill>>, String> {
  ClientBillsFamily._()
    : super(
        retry: null,
        name: r'clientBillsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClientBillsProvider call(String clientId) =>
      ClientBillsProvider._(argument: clientId, from: this);

  @override
  String toString() => r'clientBillsProvider';
}
