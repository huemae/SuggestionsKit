# SuggestionsKit

![SuggestionsKit](http://f.cl.ly/items/2G1F1Z0M0k0h2U3V1p39/SVProgressHUD.gif)

[![CI Status](https://img.shields.io/travis/huemae/SuggestionsKit.svg?style=flat)](https://travis-ci.org/huemae/SuggestionsKit)
[![Version](https://img.shields.io/cocoapods/v/SuggestionsKit.svg?style=flat)](https://cocoapods.org/pods/SuggestionsKit)
[![License](https://img.shields.io/cocoapods/l/SuggestionsKit.svg?style=flat)](https://cocoapods.org/pods/SuggestionsKit)
[![Platform](https://img.shields.io/cocoapods/p/SuggestionsKit.svg?style=flat)](https://cocoapods.org/pods/SuggestionsKit)

## Description

SuggestionsKit is a framework for iOS written in Swift that was created in order to provide developers with the opportunity to educate users on various features of applications.

## Features

* Easy to use in project
* Nice looking animations
* Customizable settings

## Usage

First of all you simply just create reference
```swift
var manager: SuggestionsManager?
```
For creating ```SuggestionsManager``` you need to create array of suggestions.
Suggestion is simple typealias to tuple of UIView and String
```swift
public typealias Suggestion = (view: UIView, text: String)
```
After you create array of suggestion you are ready to create SuggestionManager. Simply call this to create Manager and instanly start to show suggestions to users
```swift
manager = SuggestionsManager(with: suggestions, mainView: view, config: nil)
manager?.startShowing()
```
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

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
