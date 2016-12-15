Pod::Spec.new do |s|
  s.name = 'PGDebugView'
  s.version = '0.4.2'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'PGDebugView converts Plist into a visual editor'
  s.social_media_url = 'http://twitter.com/ioscook'
  s.homepage = 'https://github.com/freesuraj/PGDebugView'
  s.authors = { 'Suraj Pathak' => 'freesuraj@gmail.com' }
  s.source = { :git => 'https://github.com/freesuraj/PGDebugView.git', :tag => s.version }
  s.ios.deployment_target = '9.0'
  s.source_files = 'Source/'
  s.resource_bundles = {
    'PGDebugView' => ['Resources/Assets.xcassets']
  }
end