#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_playsuipi.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_playsuipi'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter FFI plugin project.'
  s.description      = <<-DESC
A new Flutter FFI plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'ENABLE_BITCODE' => 'NO',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64',
    'OTHER_LDFLAGS' => '-force_load ${PODS_TARGET_SRCROOT}/core/target/universal/release/libplaysuipi_core.a',
  }
  s.swift_version = '5.0'

  s.script_phase = {
    :name => 'Build playsuipi_core library',
    :script => 'cargo lipo --release --manifest-path "$PODS_TARGET_SRCROOT/core/Cargo.toml"',
    :execution_position => :before_compile,
    :output_files => ["${PODS_TARGET_SRCROOT}/core/target/universal/release/libplaysuipi_core.a"],
  }
end
