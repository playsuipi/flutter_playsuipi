#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_playsuipi.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_playsuipi'
  s.version          = '1.0.2'
  s.summary          = 'Flutter plugin for embedding the native Play Suipi Core library.'
  s.description      = <<-DESC
Flutter plugin for embedding the native Play Suipi Core library.
                       DESC
  s.homepage         = 'https://playsuipi.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Play Suipi LLC' => 'playsuipi@gmail.com' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'ENABLE_BITCODE' => 'NO',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64',
    'OTHER_LDFLAGS[sdk=iphoneos*][arch=arm64]' => '-force_load ${PODS_TARGET_SRCROOT}/core/target/aarch64-apple-ios/release/libplaysuipi_core.a',
    'OTHER_LDFLAGS[sdk=iphonesimulator*][arch=x86_64]' => '-force_load ${PODS_TARGET_SRCROOT}/core/target/x86_64-apple-ios/release/libplaysuipi_core.a',
    'OTHER_LDFLAGS[sdk=iphonesimulator*][arch=arm64]' => '-force_load ${PODS_TARGET_SRCROOT}/core/target/aarch64-apple-ios-sim/release/libplaysuipi_core.a',
  }
  s.swift_version = '5.0'

  s.script_phase = {
    :name => 'Build playsuipi_core library',
    :script => 'cd ${PODS_TARGET_SRCROOT}/core && make ios',
    :execution_position => :before_compile,
    :output_files => [
      "${PODS_TARGET_SRCROOT}/core/target/aarch64-apple-ios/release/libplaysuipi_core.a",
      "${PODS_TARGET_SRCROOT}/core/target/x86_64-apple-ios/release/libplaysuipi_core.a",
      "${PODS_TARGET_SRCROOT}/core/target/aarch64-apple-ios-sim/release/libplaysuipi_core.a",
    ],
  }
end
