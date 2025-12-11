// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentThemeColorHash() => r'5080700190289894075597c09b328afcae231df1';

/// See also [currentThemeColor].
@ProviderFor(currentThemeColor)
final currentThemeColorProvider = AutoDisposeProvider<MaterialColor>.internal(
  currentThemeColor,
  name: r'currentThemeColorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentThemeColorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentThemeColorRef = AutoDisposeProviderRef<MaterialColor>;
String _$settingsControllerHash() =>
    r'f23952eb4ab8b5e67a3bddc60ee1543f377edf13';

/// See also [SettingsController].
@ProviderFor(SettingsController)
final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, UserSettingsData?>.internal(
      SettingsController.new,
      name: r'settingsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SettingsController = AsyncNotifier<UserSettingsData?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
