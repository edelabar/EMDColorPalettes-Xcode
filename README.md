EMDColorPalettes
=============

An Xcode plugin that works with the UIColor+EMDColorPalettes category to allow code-completion of colors from OSX color palettes.

## How do I use it?

Build the EMDColorPalettes target in the Xcode project and the plug-in will automatically be installed in `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins`. Relaunch Xcode and `colorNamed:` will magically start autocompleting your colors.

## What does this work with?

Developed and tested against Xcode 6.1 and 6.2 beta.  It will probably work with others, but you will need to add the UUIDs to the DVTPlugInCompatibilityUUIDs key in Info.plist.  Please test and send a pull request with any additional versions that work.

### How do I get my Xcode UUID?

Execute the following from your OSX Terminal:

```bash
$ defaults read /Applications/Xcode.app/Contents/Info DVTPlugInCompatibilityUUID
```

Add the returned UUID to the DVTPlugInCompatibilityUUIDs key in Info.plist.

## Credits

This project is *HEAVILY* borrowed/copied/inspired by the excellent [KSImageNamed-Xcode](https://github.com/ksuther/KSImageNamed-Xcode) plug-in by [Kent Sutherland](https://github.com/ksuther).  It would not have been possible without his source code.  The entire concept is based on some great info about OSX Color Palettes in the article [XCode Tip: Color Palette](http://natashatherobot.com/xcode-color-palette/) by [Natasha Murashev](https://github.com/NatashaTheRobot) ([@natashatherobot](https://twitter.com/NatashaTheRobot)).

This plug-in was started using [kattrali/Xcode-Plugin-Template](https://github.com/kattrali/Xcode-Plugin-Template) and everything I learned about Xcode plug-in development I got from the excellent series of articles on the topic by [Black Dog Foundry](http://www.blackdogfoundry.com/) starting with [this one](http://www.blackdogfoundry.com/blog/creating-an-xcode4-plugin/).