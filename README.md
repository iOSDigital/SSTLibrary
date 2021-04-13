# SSTLibrary

## Overview
A simple Swift package wrapper for SFSpeechRecognizer. Returns a SSTResult object, which contains .string (the string with the highest confidence level), and .result which is an [SFSpeechRecognitionResult](https://developer.apple.com/documentation/speech/sfspeechrecognitionresult) object, which contains all the possible transcripts, confidence levels etc.

## Installation
Using Swift Package Manager, in Xcode:

#### File > Swift Packages > Add Package Dependency
https://github.com/iOSDigital/SSTLibrary.git

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

Init a **global** instance of the class:

```swift
let sstManager = SSTLibrary()
or
let sstManager = SSTLibrary(reportPartialResults: true)
```

On say, a button press, start the recognizing process:

```swift
sstManager.startRecognizing { (result) in
    switch result {
        case .success(let sstResult):
            // This is your speech to text result!
            print(sstResult.string)
            // The SSTResult contains the SFSpeechRecognitionResult
            let speechResult = sstResult.speechRecognitionResult
            let transcriptions = speechResult?.transcriptions

        case .failure(let error):
            // Something went wrong :(
            print("Error: \(error)")
    }
}
```

The completion block above will be called once you call stopRecognizing, say when you press another button.
OR the completion block will be regularly called if reportPartialResults == true.
Either way, call the stop method anyway, and a final SSTResult will be sent.
The "sstResult" in the .success block is an SSTResult object.

```swift
sstManager.stopRecording()
```

## Real world example

Take a ViewController that has a record UIButton, and a global isRecording Bool.

```swift
@IBAction func record(_ sender: UIButton) {

    if isRecording {
        sstManager.stopRecognizing()
        sender.setTitle("Record", for: .normal)
    } else {
        sender.setTitle("Stop", for: .normal)
        sstManager.startRecognizing { (result) in
        switch result {
            case .success(let sstResult):
                // This is your speech to text result!
                print(sstResult.string)
                // The SSTResult contains the SFSpeechRecognitionResult
                let speechResult = sstResult.speechRecognitionResult
                let transcriptions = speechResult?.transcriptions

            case .failure(let error):
                // Something went wrong :(
                print("Error: \(error)")
            }
        }
    }

    isRecording = !isRecording
}
```

## Licence
STTLibrary is licensed under the MIT License.

### Latest version: 1.0.2
