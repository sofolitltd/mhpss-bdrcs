// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(assessmentRepository)
final assessmentRepositoryProvider = AssessmentRepositoryProvider._();

final class AssessmentRepositoryProvider
    extends
        $FunctionalProvider<
          AssessmentRepository,
          AssessmentRepository,
          AssessmentRepository
        >
    with $Provider<AssessmentRepository> {
  AssessmentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assessmentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assessmentRepositoryHash();

  @$internal
  @override
  $ProviderElement<AssessmentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AssessmentRepository create(Ref ref) {
    return assessmentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssessmentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssessmentRepository>(value),
    );
  }
}

String _$assessmentRepositoryHash() =>
    r'6d1bebdbca4c92cf2eb7c39b5acd1c658ad3c3e5';
