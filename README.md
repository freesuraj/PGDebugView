
<!-- 
[![CI Status](http://img.shields.io/travis/freesuraj/PGDebugView.svg?style=flat)](https://travis-ci.org/freesuraj/PGDebugView) -->
[![Version](https://img.shields.io/cocoapods/v/PGDebugView.svg?style=flat)](http://cocoapods.org/pods/PGDebugView)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/PGDebugView.svg?style=flat)](http://cocoapods.org/pods/PGDebugView)
[![Platform](https://img.shields.io/cocoapods/p/PGDebugView.svg?style=flat)](http://cocoapods.org/pods/PGDebugView)

### What's PGDebugView?

It's a common requirement to tweak different configurations of the app for debug purposes. The general way of doing it is using Settings.bundle where the Settings are located inside `Setting` of the iPhone. It has a few drawbacks..

- Setting up Settings.bundle is a hassale and needs some research do to 
- Creating custom pages and changing values on the go are hard
- There are limitations to what values you can set
- It's just cubersome to go back to settings to see how app behavior changes when some configs are tweaked.

**In comes `PGDebugView` **

Now everybody is very familiar with `.plist` files. All you need to do is put all the debuggable configurations in a `.plist` file and that's it. You will be able to `modify` , `remove` or even `add new` configs right from your app, without ever leaving the app.

See the `Example` to see how easy it is to use.


![screenshot](https://github.com/freesuraj/PGDebugView/blob/master/Resources/pgdebugview_gif.gif)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

PGDebugView is available under the MIT license. See the LICENSE file for more info. 

### Cocoapods
Add the following line to your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'PGDebugView', :git => 'git@github.com:propertyguru/PGDebugView.git', :branch=> 'master'
end
```

### Carthage
Add the following line to your Cartfile:

```ruby
github "freesuraj/PGDebugView"
```

## Author

[Suraj Pathak](https://twitter.com/iOSCook)

## License

PGDebugView is available under the MIT license. See the LICENSE file for more info.


