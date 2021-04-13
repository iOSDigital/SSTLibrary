//
//  SSTLibrary.swift
//  SpeechToText Library
//  A quick and easy way to leverage SFSpeech
//  Copyright © 2020 DERBS.CO. All rights reserved.
//

import AVFoundation
import Speech

public enum SSTError: Error {
	case AudioEngineError
	case SpeechRecognizerError
}

public class SSTResult {
	public var string: String
	public var speechRecognitionResult: SFSpeechRecognitionResult?
	init(withString: String, result: SFSpeechRecognitionResult?) {
		string = withString
		speechRecognitionResult = result
	}
}

open class SSTLibrary {
	
	// MARK: - Global Settings
	private let audioEngine = AVAudioEngine()
	private var audioRecorder: AVAudioRecorder!
	#if os(iOS)
	private let audioSession = AVAudioSession.sharedInstance()
	#endif
	public var audioSettings = [
		AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
		AVSampleRateKey: 22000,
		AVNumberOfChannelsKey: 1,
		AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
	]
	
	private let speechRecogniser = SFSpeechRecognizer()
	private var speechRequest = SFSpeechAudioBufferRecognitionRequest()
	private var reportPartialResults = false
	
	public var amplitude: Float {
		audioRecorder.updateMeters()
		var power = audioRecorder.averagePower(forChannel: 0) + 60
		power = max(power, 10)
		return power
	}
	
	public typealias ProgressHandler = (_:Float) -> Void
	public typealias Completion = (Result<SSTResult, SSTError>) -> Void
	
	
	// MARK: - Initialisation
	
	public init() {
		SFSpeechRecognizer.requestAuthorization { (authStatus) in
			switch authStatus {
				case .authorized:
					print("Authorised!")
				case .denied, .notDetermined, .restricted:
					print("Not authorised!")
					return
				@unknown default:
					print("Error")
					return
			}
		}
		#if os(iOS)
		audioSession.requestRecordPermission { (allowed) in
			if allowed {
				try? self.audioSession.setCategory(.playAndRecord, mode: .default)
				try? self.audioSession.setActive(true)
			}else {
				print("SSTLibrary: Record permission not allowed")
			}
		}
		#endif
		
	}
	
	public init(reportPartialResults: Bool = false) {
		self.reportPartialResults = reportPartialResults
	}
	
	public func startRecognizing(completion: @escaping Completion) {
		
		speechRequest = SFSpeechAudioBufferRecognitionRequest()
		speechRequest.shouldReportPartialResults = self.reportPartialResults
		speechRequest.taskHint = .dictation
		let speechNode = audioEngine.inputNode
		let speechFormat = speechNode.outputFormat(forBus: 0)
		speechNode.installTap(onBus: 0, bufferSize: 1024, format: speechFormat) { (buffer, time) in
			self.speechRequest.append(buffer)
		}
		
		audioEngine.prepare()
		do {
			try audioEngine.start()
			audioRecorder = try AVAudioRecorder(url: recordLocation, settings: audioSettings)
			audioRecorder.isMeteringEnabled = true
			audioRecorder.record()
			
			speechRecogniser?.recognitionTask(with: speechRequest, resultHandler: { (result, error) in
				if error != nil {
					print("SSTLibraryError: " + error!.localizedDescription)
					self.stopRecognizing()
					completion(.failure(.SpeechRecognizerError))
				} else {
					if let transcription = result?.bestTranscription {
						let sstResult = SSTResult(withString: transcription.formattedString, result: result)
						completion(.success(sstResult))
					} else {
						let sstResult = SSTResult(withString: "", result: nil)
						completion(.success(sstResult))
					}
				}
			})
			
		}catch{
			print("SSTLibraryError: \(error.localizedDescription)")
			stopRecognizing()
			completion(.failure(.AudioEngineError))
		}
		
		
	}
	
	public func stopRecognizing() {
		self.audioEngine.inputNode.removeTap(onBus: 0)
		self.audioEngine.stop()
		self.speechRequest.endAudio()
		if audioRecorder != nil {
			audioRecorder.stop()
		}
	}
	
}


extension SSTLibrary {
	
	var recordLocation: URL {
		get {
			let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("m4a")
			print(url.path)
			return url
		}
	}
	
}

