// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clientDocuments)
final clientDocumentsProvider = ClientDocumentsFamily._();

final class ClientDocumentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ClientDocument>>,
          List<ClientDocument>,
          Stream<List<ClientDocument>>
        >
    with
        $FutureModifier<List<ClientDocument>>,
        $StreamProvider<List<ClientDocument>> {
  ClientDocumentsProvider._({
    required ClientDocumentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clientDocumentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clientDocumentsHash();

  @override
  String toString() {
    return r'clientDocumentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ClientDocument>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ClientDocument>> create(Ref ref) {
    final argument = this.argument as String;
    return clientDocuments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientDocumentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clientDocumentsHash() => r'9c0a0b3a000b48c1100b27d95bc219a5ce06d659';

final class ClientDocumentsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ClientDocument>>, String> {
  ClientDocumentsFamily._()
    : super(
        retry: null,
        name: r'clientDocumentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClientDocumentsProvider call(String clientId) =>
      ClientDocumentsProvider._(argument: clientId, from: this);

  @override
  String toString() => r'clientDocumentsProvider';
}
