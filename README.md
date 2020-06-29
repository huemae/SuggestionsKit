# SuggestionsKit

![SuggestionsKit](https://i.imgur.com/Z9SfxiO.gif)
<img src="https://i.imgur.com/xfGnJ90.gif" width="100" height="100">

[![CI Status](https://travis-ci.org/huemae/SuggestionsKit.svg?branch=master)](https://travis-ci.org/huemae/SuggestionsKit)
[![Version](https://img.shields.io/cocoapods/v/SuggestionsKit.svg?style=flat)](https://cocoapods.org/pods/SuggestionsKit)
[![License](https://img.shields.io/cocoapods/l/SuggestionsKit.svg?style=flat)](https://cocoapods.org/pods/SuggestionsKit)
[![Platform](https://img.shields.io/cocoapods/p/SuggestionsKit.svg?style=flat)](https://cocoapods.org/pods/SuggestionsKit)

## Description

SuggestionsKit is a framework for iOS that was created in order to provide developers with the opportunity to educate users on various features of applications.

## Requirements
* Xcode 11 / Swift 5+
* iOS 9.0+

## Features

* Easy to use in project
* Nice looking animations
* Supports device rotations
* Supports navigation items and tab bar items
* Supports view resizing and changing of position via observation
* Customizable settings

## Usage

Import ```SuggestionsKit```

```swift
import SuggestionsKit
```

Next you need to create one or more suggestions. Simple init method takes ```UIVIew``` and ```String ``` as arguments.
```swift
let suggestion = Suggestion(view: sendMessageButton, text: "Tap here to send message to user")
```

After you just call ```apply``` method of ```SuggestionManager``` class
```swift
SuggestionsManager.apply(suggestions)
```
Optionaly you could call ```configre``` method to setup suggestions which will presented to user. If this method will not be called then default configuration will be used
```swift
SuggestionsManager.apply(suggestions)
    .configre(config)
```
And you are done! Next step is just call ```startShowing``` method to start showing suggestions.
```swift
SuggestionsManager.apply(suggestions)
    .configre(config)
    .startShowing()
```

If suggestions ended whole view will dissapear automaticaly.  
If you want to stop process manualy simply call ```stopShowing``` method of ```SuggestionManager``` class
```swift
SuggestionsManager.stopShowing()
```
If you want to be notified when suggestion come to an end just call ```completion``` method of ```SuggestionManager``` that takes void closure as an argument
```swift
SuggestionsManager.apply(suggestions)
    .configre(config)
    .startShowing()
    .completion {
        print("suggestions finished")
    }
 ```
 
 Additionally you could create suggestion from ```tabBarController.tabBar``` or ```navigationController.navigationBar``` with help of ```SuggestionsHelper``` class
```swift
let tabBarItems = SuggestionsHelper.findAllBarItems(in: tabBarController?.tabBar)
suggestions += tabBarItems.enumerated()
    .map { Suggestion(view: $0.element, text: "Tab bar item \($0.offset)") }
    
let navItems = SuggestionsHelper.findAllBarItems(in: navigationController?.navigationBar)
let navSuggestions = navItems.enumerated()
    .map { Suggestion(view: $0.element, text: $0.offset == 0 ? "back button" : "bar button item") }
suggestions += navSuggestions
```
Please keep in mind that this functionality is implemented using recursive search of visual elements and may be broken in future versions of iOS  
This method does not use private properties for searching

## Example

To run the example project, clone the repo, open the ```SuggestionsKit.xcworkspace``` workspace, then select target ```SuggestionsKit-Example``` and you are ready to test the example
## Installation

### CocoaPods

SuggestionsKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SuggestionsKit'
```

### Swift Package Manager
```swift
dependencies: [.package(url: "https://github.com/huemae/SuggestionsKit", Package.Dependency.Requirement.branch("master"))]
```
## Author

huemae

## License

SuggestionsKit is available under the MIT license. See the LICENSE file for more info.
