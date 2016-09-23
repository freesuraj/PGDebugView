Pod::Spec.new do |s|
  s.name = 'PGDebugView'
  s.version = '0.2.0'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'PGDebugView converts Plist into a visual editor' 

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  It's a common requirement to tweak different configurations of the app for debug purposes. The general way of doing it is using Settings.bundle where the Settings are located inside Setting of the iPhone. It has a few drawbacks..

  Setting up Settings.bundle is a hassale and needs some research do to
  Creating custom pages and changing values on the go are hard
  There are limitations to what values you can set
  It's just cubersome to go back to settings to see how app behavior changes when some configs are tweaked.
  *In comes PGDebugView *

  Now everybody is very familiar with .plist files. All you need to do is put all the debuggable configurations in a .plist file and that's it. You will be able to modify , remove or even add new configs right from your app, without ever leaving the app.
                       DESC

  s.homepage         = 'https://github.com/freesuraj/PGDebugView'
  s.authors = { 'PROJECT_OWNER' => 'USER_EMAIL' }
  s.source = { :git => 'https://github.com/freesuraj/PGDebugView.git', :tag => s.version }
  s.ios.deployment_target = '9.0'
  s.source_files = 'Source/**/*.{h,m,swift}'
  s.resource_bundles = {
    'PGDebugView' => ['Resources/Assets.xcassets']
  }
end