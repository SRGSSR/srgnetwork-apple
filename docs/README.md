[![SRG Network logo](README-images/logo.png)](https://github.com/SRGSSR/srgnetwork-apple)

[![GitHub releases](https://img.shields.io/github/v/release/SRGSSR/srgnetwork-apple)](https://github.com/SRGSSR/srgnetwork-apple/releases) [![platform](https://img.shields.io/badge/platfom-ios%20%7C%20tvos%20%7C%20watchos-blue)](https://github.com/SRGSSR/srgnetwork-apple) [![SPM compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager) [![GitHub license](https://img.shields.io/github/license/SRGSSR/srgnetwork-apple)](https://github.com/SRGSSR/srgnetwork-apple/blob/master/LICENSE)

## About

Built on top of `NSURLSession`, this library provides a concise, consistent formalism to create and manage network requests.

Unlike most network libraries, SRG Network focuses on common issues surrounding the use of network connections:

* Convenient and simple management of multiple requests, whether they are performed in parallel or in cascade.
* Simple formalism to be notified when a request or group of requests is active or inactive.
* Proper cancellation of requests.

## Compatibility

The library is suitable for applications running on iOS 9, tvOS 12, watchOS 5 and above. The project is meant to be compiled with the latest Xcode version.

## Contributing

If you want to contribute to the project, have a look at our [contributing guide](CONTRIBUTING.md).

## Integration

The library must be integrated using [Swift Package Manager](https://swift.org/package-manager) directly [within Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app). You can also declare the library as a dependency of another one directly in the associated `Package.swift` manifest.

## Usage

When you want to use classes or functions provided by the library in your code, you must import it from your source files first. In Objective-C:

```objective-c
@import SRGNetwork;
```

or in Swift:

```
swift SRGNetwork
```

### Working with the library

To learn about how the library can be used, have a look at the [getting started guide](GETTING_STARTED.md).

## License

See the [LICENSE](../LICENSE) file for more information.
