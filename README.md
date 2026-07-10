# SpeechManager

A package to manage TextToSpeech services.

This package is compatible with iOS, MacOS, TvOS and WatchOS.

## Supported platforms

This framework is compatible with iOS, ipadOS, TvOS, WatchOS and MacOS..

## Usage

This framework includes various functions to manage *TextToSpeech* functionality for the system and for accessibility services.

### Basic system speech 

* Import the module in your source file
* Call the function **speak()** from the singleton **speech**

#### Sample code

This sample code makes the system speaks the message *Hello world!* using the default voice of the system using the language by default.

```
import SpeechManager

speech.speak("Hello World!")
```

### Basic accessibility speech 

* Import the module in your source file
* Call the function **speakWithScreenReader()** from the singleton **speech**

#### Sample code

This sample code makes the Accessibility API speaks the message *Hello world!* using the voice of the screenReader.

```
import SpeechManager

let speech = SpeechManager.shared
speech.speakWithScreenReader("Hello World!")
```

### Punctuation verbosity

SpeechManager can explicitly verbalize punctuation while keeping the default behavior compatible with previous versions.

```
let speech = SpeechManager.shared

speech.speak(
    "Email: user@example.com!",
    language: .Spanish,
    punctuationVerbosity: .some
)

speech.speak(
    "Hello, world!",
    language: .English,
    punctuationVerbosity: .all
)
```

Available levels:

* `.none`: keeps the original text unchanged. This is the default and matches previous behavior.
* `.some`: verbalizes useful symbols, such as `@`, `#`, `/`, `+` or `%`, while keeping natural sentence punctuation.
* `.all`: verbalizes all supported punctuation marks.

### Completed spoken range

Use `onSpokenTextWithRange` to know the range that is about to be spoken, and `onFinishedSpokenTextWithRange` to know the range that has just finished. The finished callback is emitted when AVFoundation reports the next range, and again at the end for the last pending range.

```
speech.onFinishedSpokenTextWithRange = { range, fullText, utterance in
    // Update highlighted text using the completed range.
}
```

### SSML

SSML is supported on iOS 16, macOS 13, watchOS 9 and tvOS 16 or newer through AVFoundation. On older systems, or when the SSML is invalid, SpeechManager reports an error and falls back to readable plain text.

```
speech.speakSSML("""
<speak>
    Hello <break time="300ms"/> world.
</speak>
""")

var configuration = SpeechConfiguration(language: .English)
configuration.textFormat = .ssml
speech.speak("<speak>Hello world.</speak>", settings: configuration)
```

## Author

This package was developed by Jonathan Chacón .

Please, if you have any question or suggestion you can contact me at [Tyflos Accessible Software](https://.tyflosaccessiblesoftware.com) web site.

## Contributing

Pull requests are welcome. Feel free to create pull requests for any kind of improvements, bug fixes or enhancements. For major changes, please open an issue first to discuss what you would like to change.

## License

This software was published under the [MIT license](https://choosealicense.com/licenses/mit/)
