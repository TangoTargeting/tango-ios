#
# Be sure to run `pod lib lint Tango.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TangoRichNotification'
  s.version          = '1.0.10'
  s.summary          = 'This is the Tango Targeting Rich Notification extension for Mobile Marketing Automation.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

#   s.description      = <<-DESC
# TODO: Add long description of the pod here.
#                        DESC

  s.homepage         = 'http://www.tangotargeting.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'COMMERCIAL', :file => 'LICENSE' }
  s.author           = { 'Tango Targeting Inc.' => 'dev@tangotargeting.com' }
  s.source           = { :git => 'https://github.com/tangotargeting/tango-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.3'

  s.source_files = 'TangoRichNotification/Classes/**/*'
  s.documentation_url = 'https://tangotargeting.github.io/tango-documentation/developer-guide/ios/installation/'
  
  # s.resource_bundles = {
  #   'Tango' => ['TangoRichNotification/Assets/*.png']
  # }

  s.public_header_files = 'TangoRichNotification/Classes/**/*.h'
  s.frameworks   = 'SystemConfiguration', 'UIKit', 'CoreGraphics', 'CoreLocation'

end
