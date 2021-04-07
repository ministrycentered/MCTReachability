#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "MCTReachability"
  s.version          = "1.0.0"
  s.summary          = "MCTReachability is a replacement for Reachability"
  s.homepage         = "https://github.com/ministrycentered/MCTReachability"
  s.license          = 'MIT'
  s.author           = { "Skylar Schipper" => "ss@schipp.co" }
  s.source           = { :git => "https://github.com/ministrycentered/MCTReachability.git", :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true
  s.source_files = "MCTReachability/*.{h,m}"
  s.ios.exclude_files = 'MCTReachability/osx'
  s.osx.exclude_files = 'MCTReachability/ios'
  s.frameworks = 'Foundation', 'SystemConfiguration'
end
