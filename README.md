# SuggestionsKit

![SuggestionsKit](https://i.imgur.com/Z9SfxiO.gif)

[![CI Status](https://img.shields.io/travis/huemae/SuggestionsKit.svg?style=flat)](https://travis-ci.org/huemae/SuggestionsKit)
[![Version](https://img.shields.io/cocoapods/v/SuggestionsKit.svg?style=flat)](https://cocoapods.org/pods/SuggestionsKit)
[![License](https://img.shields.io/cocoapods/l/SuggestionsKit.svg?style=flat)](https://cocoapods.org/pods/SuggestionsKit)
[![Platform](https://img.shields.io/cocoapods/p/SuggestionsKit.svg?style=flat)](https://cocoapods.org/pods/SuggestionsKit)

## Description

SuggestionsKit is a framework for iOS written in Swift that was created in order to provide developers with the opportunity to educate users on various features of applications.

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


For first you need to create one or more suggestions. Simple init method takes ```UIVIew``` and ```String ``` as arguments.
```swift
let suggestion = Suggestion(view: sendMessageButton, text: "Tap here to send message to user")
```
Additionally you could create suggestion from ```UITabBarItem``` or ```UIBarButtonItem``` with help of ```SuggestionsHelper``` class
```swift
let barItems = navigationItem.rightBarButtonItems
let rightBarSuggestions = SuggestionsHelper.createSuggestionsFromBarItems(items: barItems) { index in
    return "Right bar item \(index)"
}
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
If suggestions ended whole view will dissapear automaticaly. If you want to stop process manualy simply call ```stopShowing``` method of ```SuggestionManager``` class
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

## Example

To run the example project, clone the repo, open the ```SuggestionsKit.xcworkspace``` workspace, then select target ```SuggestionsKit-Example``` and you are ready to test the example

## Requirements

## Installation

SuggestionsKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SuggestionsKit'
```

## Author

huemae

## License

SuggestionsKit is available under the MIT license. See the LICENSE file for more info.
