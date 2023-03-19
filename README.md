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

speech.speakWithScreenReader("Hello World!")
```

## Author

This package was developed by Jonathan Chacón .

Please, if you have any question or suggestion you can contact me at [Tyflos Accessible Software](https://.tyflosaccessiblesoftware.com) web site.

## Contributing

Pull requests are welcome. Feel free to create pull requests for any kind of improvements, bug fixes or enhancements. For major changes, please open an issue first to discuss what you would like to change.

## License

This software was published under the [MIT license](https://choosealicense.com/licenses/mit/)
