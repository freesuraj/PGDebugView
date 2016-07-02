
Pod::Spec.new do |s|
  s.name             = 'PGDebugView'
  s.version          = '0.1.0'
  s.summary          = 'Convert Plist into a visual editor'
  s.description      = 'A replacement for Settings.bundle for easier debug configuration'
  s.homepage         = 'https://github.com/freesuraj/PGDebugView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Suraj Pathak' => 'freesuraj@gmail.com' }
  s.source           = { :git => 'https://github.com/freesuraj/PGDebugView.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/iOSCook'
  s.ios.deployment_target = '8.0'
  s.source_files = 'PGDebugView/Classes/**/*'
end
