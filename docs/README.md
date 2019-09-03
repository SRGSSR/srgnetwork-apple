[![SRG Network logo](README-images/logo.png)](https://github.com/SRGSSR/srgnetwork-ios)

[![GitHub releases](https://img.shields.io/github/v/release/SRGSSR/srgnetwork-ios)](https://github.com/SRGSSR/srgnetwork-ios/releases) [![platform](https://img.shields.io/badge/platfom-ios%20%7C%20tvos%20%7C%20watchos-blue)](https://github.com/SRGSSR/srgnetwork-ios) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![GitHub license](https://img.shields.io/github/license/SRGSSR/srgnetwork-ios)](https://github.com/SRGSSR/srgnetwork-ios/blob/master/LICENSE) 

## About

Built on top of `NSURLSession`, this library provides a concise, consistent formalism to create and manage network requests.

Unlike most network libraries, SRG Network focuses on common issues surrounding the use of network connections:

* Convenient and simple management of multiple requests, whether they are performed in parallel or in cascade.
* Simple formalism to be notified when a request or group of requests is active or inactive.
* Proper cancellation of requests.

## Compatibility

The library is suitable for applications running on iOS 9, tvOS 9, watchOS 3 and above. The project is meant to be opened with the latest Xcode version (currently Xcode 10).

## Contributing

If you want to contribute to the project, have a look at our [contributing guide](CONTRIBUTING.md).

## Installation

The library can be added to a project using [Carthage](https://github.com/Carthage/Carthage) by adding the following dependency to your `Cartfile`:
    
```
github "SRGSSR/srgnetwork-ios"
```

For more information about Carthage and its use, refer to the [official documentation](https://github.com/Carthage/Carthage).

### Dependencies

The library requires the following frameworks to be added to any target requiring it:

* `libextobjc`: A utility framework.
* `MAKVONotificationCenter`: A safe KVO framework.
* `SRGLogger`: The framework used for internal logging.
* `SRGNetwork`: The main library framework.

### Dynamic framework integration

1. Run `carthage update` to update the dependencies (which is equivalent to `carthage update --configuration Release`). 
2. Add the frameworks listed above and generated in the `Carthage/Build/(iOS|tvOS|watchOS)` folder to your target _Embedded binaries_.

If your target is building an application, a few more steps are required:

1. Add a _Run script_ build phase to your target, with `/usr/local/bin/carthage copy-frameworks` as command.
2. Add each of the required frameworks above as input file `$(SRCROOT)/Carthage/Build/(iOS|tvOS|watchOS)/FrameworkName.framework`.

### Static framework integration

1. Run `carthage update --configuration Release-static` to update the dependencies. 
2. Add the frameworks listed above and generated in the `Carthage/Build/(iOS|tvOS|watchOS)/Static` folder to the _Linked frameworks and libraries_ list of your target.
3. Also add any resource bundle `.bundle` found within the `.framework` folders to your target directly.
4. Add the `-all_load` flag to your target _Other linker flags_.

## Usage

When you want to use classes or functions provided by the library in your code, you must import it from your source files first.

### Usage from Objective-C source files

Import the global header file using:

```objective-c
#import <SRGNetwork/SRGNetwork.h>
```

or directly import the module itself:

```objective-c
@import SRGNetwork;
```

### Usage from Swift source files

Import the module where needed:

```swift
import SRGNetwork
```

### Working with the library

To learn about how the library can be used, have a look at the [getting started guide](GETTING_STARTED.md).

## Building the project

A [Makefile](../Makefile) provides several targets to build and package the library. The available targets can be listed by running the following command from the project root folder:

```
make help
```

Alternatively, you can of course open the project with Xcode and use the available schemes.

## License

See the [LICENSE](../LICENSE) file for more information.
