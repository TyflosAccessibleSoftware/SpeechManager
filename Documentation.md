# SpeechManager Documentation

SpeechManager is a Swift Package Manager library that wraps `AVFoundation` text-to-speech APIs and adds a small, app-friendly API for speaking text, queuing utterances, selecting voices, using accessibility speech, tracking spoken ranges, controlling punctuation verbosity, and speaking SSML.

## Requirements

SpeechManager supports:

| Platform | Minimum version |
| --- | --- |
| iOS | 15.0 |
| iPadOS | 15.0 |
| macOS | 12.0 |
| tvOS | 15.0 |
| watchOS | 4.0 |

SSML is available through AVFoundation on iOS 16, macOS 13, watchOS 9, and tvOS 16 or newer. On older OS versions SpeechManager falls back to readable plain text and reports an error.

## Importing

```swift
import SpeechManager
```

SpeechManager is exposed as a singleton:

```swift
let speech = SpeechManager.shared
```

## Basic Speech

Speak a plain string with the system speech synthesizer:

```swift
SpeechManager.shared.speak("Hello world!")
```

You can pass individual options directly:

```swift
let speech = SpeechManager.shared

speech.speak(
    "Welcome to SpeechManager.",
    volume: 0.9,
    rate: 0.55,
    pitch: 1.1,
    language: .English
)
```

Or you can create a reusable `SpeechConfiguration`:

```swift
let configuration = SpeechConfiguration(
    volume: 1.0,
    rate: 0.5,
    pitch: 1.0,
    language: .English,
    voiceName: nil,
    alone: false,
    withAccessibilitySettings: false,
    preDelay: 0.0,
    postDelay: 0.0
)

SpeechManager.shared.speak("This uses a configuration.", settings: configuration)
```

## SpeechConfiguration

`SpeechConfiguration` stores the options used to build an `AVSpeechUtterance`.

| Property | Default | Description |
| --- | --- | --- |
| `volume` | `1.0` | Utterance volume from `0.0` to `1.0`. |
| `rate` | `0.5` | Speech rate. AVFoundation clamps the final value to its supported range. |
| `pitch` | `1.0` | Pitch multiplier. |
| `language` | `.unknown` | Preferred `SpeechLanguage`. |
| `voiceId` | `nil` | Preferred `AVSpeechSynthesisVoice.identifier`. |
| `voiceName` | `nil` | Preferred SpeechManager long voice name. |
| `alone` | `false` | Stops screen reader speech before speaking. |
| `withAccessibilitySettings` | `false` | Lets AVFoundation prefer assistive technology speech settings when available. |
| `preDelay` | `0.0` | Delay before speaking the utterance. |
| `postDelay` | `0.0` | Delay after speaking the utterance. |
| `punctuationVerbosity` | `.none` | Controls explicit punctuation verbalization. |
| `textFormat` | `.plainText` | Selects plain text or SSML input. |

Example:

```swift
var configuration = SpeechConfiguration(language: .Spanish)
configuration.rate = 0.48
configuration.pitch = 1.05
configuration.preDelay = 0.15
configuration.postDelay = 0.2
configuration.punctuationVerbosity = .some

SpeechManager.shared.speak("Email: user@example.com", settings: configuration)
```

## Punctuation Verbosity

Use `SpeechPunctuationVerbosity` to decide how much punctuation should be explicitly spoken.

| Value | Behavior |
| --- | --- |
| `.none` | Keeps the original text unchanged. This is the default and preserves compatibility with previous versions. |
| `.some` | Verbalizes useful symbols such as `@`, `#`, `/`, `+`, `%`, while keeping normal sentence punctuation for natural prosody. |
| `.all` | Verbalizes all supported punctuation marks, including commas, periods, question marks, and exclamation marks. |

Examples:

```swift
let speech = SpeechManager.shared

speech.speak(
    "Email: user@example.com!",
    language: .Spanish,
    punctuationVerbosity: .some
)

speech.speak(
    "Ready, set, go!",
    language: .English,
    punctuationVerbosity: .all
)
```

The punctuation dictionary verbalizes supported punctuation names in English.

## SSML

Use `speakSSML(_:)` for Speech Synthesis Markup Language input:

```swift
let ssml = """
<speak>
    Hello <break time="300ms"/> world.
</speak>
"""

SpeechManager.shared.speakSSML(ssml)
```

You can also pass a configuration:

```swift
var configuration = SpeechConfiguration(language: .English)
configuration.volume = 0.8

SpeechManager.shared.speakSSML(
    "<speak>This is <emphasis>important</emphasis>.</speak>",
    settings: configuration
)
```

Alternatively, set `textFormat` manually:

```swift
var configuration = SpeechConfiguration(language: .English)
configuration.textFormat = .ssml

SpeechManager.shared.speak(
    "<speak>Hello <break time=\"200ms\"/> again.</speak>",
    settings: configuration
)
```

If the OS does not support AVFoundation SSML, SpeechManager reports `.ssmlUnavailable` and falls back to readable plain text. If the SSML string is invalid, it reports `.invalidSSML` and also falls back.

```swift
let speech = SpeechManager.shared

speech.onSpeechManagerError = { error in
    switch error {
    case .ssmlUnavailable:
        print("SSML is not available on this OS version.")
    case .invalidSSML:
        print("The SSML string is invalid.")
    }
}
```

## Queueing Speech

Use `speakEnqueued(_:configuration:)` to speak multiple items in order:

```swift
let speech = SpeechManager.shared

speech.speakEnqueued("First message.")
speech.speakEnqueued("Second message.")
speech.speakEnqueued("Third message.")
```

Each item can have its own configuration:

```swift
let english = SpeechConfiguration(language: .English)
let spanish = SpeechConfiguration(language: .Spanish)

let speech = SpeechManager.shared
speech.speakEnqueued("Hello.", configuration: english)
speech.speakEnqueued("Hello again.", configuration: spanish)
```

Queue SSML with `speakSSMLEnqueued(_:configuration:)`:

```swift
let speech = SpeechManager.shared

speech.speakSSMLEnqueued("<speak>First <break time=\"150ms\"/> item.</speak>")
speech.speakSSMLEnqueued("<speak>Second item.</speak>")
```

Queue management:

```swift
let speech = SpeechManager.shared

speech.clearQueue()          // Removes pending items.
speech.stopAndClearQueue()   // Stops current speech and removes pending items.
```

## Playback Controls

```swift
let speech = SpeechManager.shared

speech.pause()                 // Pause immediately.
speech.pause(immediate: false) // Pause at the next word boundary.
speech.resume()                // Continue speaking.
speech.stop()                  // Stop current speech and clear the queue.
```

Check the current synthesizer state:

```swift
if SpeechManager.shared.isSpeaking {
    print("Speech is active.")
}

if SpeechManager.shared.isPaused {
    print("Speech is paused.")
}
```

Mute or unmute SpeechManager output:

```swift
SpeechManager.shared.muteSpeech(true)
SpeechManager.shared.muteSpeech(false)
```

`muteSpeech(true)` keeps the utterance flow but sets utterance volume to zero.

## Accessibility Speech

SpeechManager can speak through the screen reader announcement APIs.

```swift
let speech = SpeechManager.shared
speech.speakWithScreenReader("This uses the accessibility announcement API.")
```

You can delay the announcement in milliseconds:

```swift
SpeechManager.shared.speakWithScreenReader(
    "Delayed announcement.",
    delay: 500
)
```

Enable accessibility speech for normal `speak` calls:

```swift
let speech = SpeechManager.shared
speech.accessibilityVoiceEnabled = true
speech.speak("This will be sent to the screen reader path.")
```

Stop current screen reader speech before starting another utterance:

```swift
SpeechManager.shared.stopWithScreenReader()
```

Use `alone: true` when speaking if you want SpeechManager to stop screen reader speech before the utterance starts:

```swift
SpeechManager.shared.speak(
    "Important message.",
    alone: true
)
```

## Spoken Range Tracking

AVFoundation provides a callback before a range is spoken. SpeechManager exposes both the original "will speak" range and a higher-level "finished speaking" range.

Use `onSpokenTextWithRange` to know what is about to be spoken:

```swift
SpeechManager.shared.onSpokenTextWithRange = { range, fullText, utterance in
    print("About to speak range:", range, "in:", fullText)
}
```

Use `onFinishedSpokenTextWithRange` to know what has just finished:

```swift
SpeechManager.shared.onFinishedSpokenTextWithRange = { range, fullText, utterance in
    let nsText = fullText as NSString
    let finishedFragment = nsText.substring(with: range)
    print("Finished:", finishedFragment)
}
```

The finished callback is emitted when the next AVFoundation range starts. The final pending range is flushed when the utterance finishes.

Legacy-style string callbacks are also available:

```swift
SpeechManager.shared.onSpokenText = { prefix, suffix, utterance in
    print("Already passed:", prefix)
    print("Still to speak:", suffix)
}

SpeechManager.shared.onFinishedSpokenText = { spokenPrefix, remainingSuffix, utterance in
    print("Finished so far:", spokenPrefix)
    print("Remaining:", remainingSuffix)
}
```

Use `onUtteranceFinished` to observe complete utterances:

```swift
SpeechManager.shared.onUtteranceFinished = { text, utterance in
    print("Finished utterance:", text)
}
```

## Delegate API

Assign a `SpeechManagerDelegate` when you prefer delegate callbacks over closures.

```swift
final class ReaderController: SpeechManagerDelegate {
    func speechManagerDidStart() {
        print("Started")
    }

    func speechManagerDidFinish() {
        print("All queued speech finished")
    }

    func speechManagerDidPause() {
        print("Paused")
    }

    func speechManagerDidContinue() {
        print("Continued")
    }

    func speechManagerDidCancel() {
        print("Cancelled")
    }

    func speechManager(didRequestUnavailableVoice voice: String) {
        print("Voice is unavailable:", voice)
    }

    func speechManager(didFailWith error: SpeechManagerError) {
        print("SpeechManager error:", error)
    }

    func speechManager(didFinishSpeakingRange range: NSRange, in text: String) {
        print("Finished range:", range)
    }
}

let controller = ReaderController()
SpeechManager.shared.delegate = controller
```

All delegate methods have default empty implementations, so you only need to implement the callbacks you use.

## Voices

SpeechManager exposes helpers around `AVSpeechSynthesisVoice`.

List installed voices:

```swift
let speech = SpeechManager.shared

for voice in speech.installedVoices {
    print(voice.longName)
}
```

List available languages:

```swift
let languages = SpeechManager.shared.availableLanguages
print(languages)
```

Find voices:

```swift
let speech = SpeechManager.shared

let voiceByIdentifier = speech.getVoiceBy(id: "com.apple.voice.compact.en-US.Samantha")
let voiceByLongName = speech.getVoiceBy(longName: "Samantha compact (en-US)")
let voicesNamedSamantha = speech.getVoicesBy("Samantha")
let englishVoices = speech.getVoicesFor(language: "en-US")
let matchingVoice = speech.findVoice(matching: "Samantha")
```

Use a specific voice:

```swift
if let voice = SpeechManager.shared.findVoice(matching: "Samantha") {
    SpeechManager.shared.speak(
        "Using a specific AVSpeechSynthesisVoice.",
        voice: voice
    )
}
```

Or store the identifier in a configuration:

```swift
var configuration = SpeechConfiguration(language: .English)
configuration.voiceId = "com.apple.voice.compact.en-US.Samantha"

SpeechManager.shared.speak("Using a voice identifier.", settings: configuration)
```

Voice grouping helpers:

```swift
let allByLanguage = SpeechManager.shared.allVoicesByLanguage
let availableByLanguage = SpeechManager.shared.availableVoicesByLanguage

print(allByLanguage["en-US"] ?? [])
print(availableByLanguage["es-ES"] ?? [])
```

Default voice information:

```swift
let speech = SpeechManager.shared

print(speech.defaultVoiceLanguage)
print(speech.defaultVoiceName)
print(speech.defaultVoiceLongName)
print(speech.defaultVoiceVolume)
print(speech.defaultVoiceRate)
print(speech.defaultVoicepitchMultiplier)
```

## AVSpeechSynthesisVoice Extensions

SpeechManager adds a few convenience properties and methods to `AVSpeechSynthesisVoice`.

```swift
import AVFoundation
import SpeechManager

let voices = AVSpeechSynthesisVoice.voices(forLanguage: "en-US")
let samantha = AVSpeechSynthesisVoice.voice(matchingName: "Samantha")

if let voice = samantha {
    print(voice.longName)
    print(voice.isInstalledForAVSpeech)

    switch voice.downloadStatus {
    case .available:
        print("Voice is available.")
    case .needsDownload:
        print("Voice needs to be downloaded.")
    }
}
```

## Languages

Use `SpeechLanguage` for common language and locale identifiers:

```swift
SpeechManager.shared.speak("Hello world.", language: .Spanish)
SpeechManager.shared.speak("Hello world.", language: .English)
SpeechManager.shared.speak("Bonjour.", language: .French)
SpeechManager.shared.speak("Ciao.", language: .Italian)
```

`SpeechLanguage.unknown` lets AVFoundation use its default voice selection. `SpeechLanguage.Custom` is available for compatibility, but direct custom language strings should use the lower-level voice lookup APIs.

## Recommended Patterns

For simple one-off speech, call `speak(_:)` directly:

```swift
SpeechManager.shared.speak("Saved successfully.")
```

For a reader interface that highlights completed text, use `onFinishedSpokenTextWithRange`:

```swift
final class ReaderHighlighter {
    init() {
        SpeechManager.shared.onFinishedSpokenTextWithRange = { [weak self] range, fullText, _ in
            self?.markRangeAsRead(range, in: fullText)
        }
    }

    private func markRangeAsRead(_ range: NSRange, in text: String) {
        // Update your attributed string, collection view, or text view here.
    }
}
```

For a queue-based reader:

```swift
let speech = SpeechManager.shared
speech.stopAndClearQueue()

for paragraph in paragraphs {
    speech.speakEnqueued(
        paragraph,
        configuration: SpeechConfiguration(language: .English)
    )
}
```

For SSML with graceful fallback:

```swift
let speech = SpeechManager.shared

speech.onSpeechManagerError = { error in
    print("SpeechManager used a fallback:", error)
}

speech.speakSSML("""
<speak>
    <prosody rate="slow">This may use native SSML.</prosody>
</speak>
""")
```
