#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint privacy_scope.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'privacy_scope'
  s.version          = '0.1.0'
  s.summary          = 'Context-aware privacy protection for Flutter apps.'
  s.description      = <<-DESC
Context-aware privacy protection for Flutter apps. Apply screenshot protection, app-switcher privacy, and sensitive-screen policies only where your app needs them.
                       DESC
  s.homepage         = 'https://github.com/impintooprajapati/privacy_scope'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Pintoo Prajapati' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
