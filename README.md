# STTLibrary

## Overview
A simple Swift package wrapper for SFSpeechRecognizer. Returns a string.

## Installation
Using Swift Package Manager, in Xcode:

#### File > Swift Packages > Add Package Dependency
https://github.com/iOSDigital/STTLibrary.git

#### Or manually
Just drop SSTLibrary.swift into your project.

## Requirements
* Swift 5
* iOS 13+
* macOS 10.15+
* Untested on tvOS, might work!

## Usage
Firstly, before you do anything, add the Microphone and Speech privacy entries into your app's info.plist, otherwise it will hard crash!

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>Need speech</string>
<key>NSMicrophoneUsageDescription</key>
<string>Need microphone</string>
```

Then, once you have imported the module:

```swift
import SSTLibrary
```

Create a global instance of the Shared Instance:

```swift
let sstManager = SSTLibrary.shared
```

On say, a button press, start the recognizing process:

```swift
sstManager.startRecognizing { (result) in
    switch result {
        case .success(let string):
            // This is your speech to text result!
            print(string)

        case .failure(let error):
            // Something went wrong :(
            print("Error: \(error)")
    }
}
```

The completion block above will be called once you call stopRecognizing, say when you press another button:

```swift
sstManager.stopRecording()
```

## Licence
STTLibrary is licensed under the MIT License.
