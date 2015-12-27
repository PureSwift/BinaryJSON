# BinaryJSON
[![Swift](https://img.shields.io/badge/swift-2.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms](https://img.shields.io/badge/platform-osx%20%7C%20linux-lightgrey.svg)](https://www.swift.org)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license)
[![Release](https://img.shields.io/github/release/pureswift/BinaryJSON.svg)](https://github.com/PureSwift/BinaryJSON/releases)
[![Build Status](https://travis-ci.org/PureSwift/BinaryJSON.svg?branch=master)](https://travis-ci.org/PureSwift/BinaryJSON)

[![SPM compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)

Pure Swift library for BSON

## Ubuntu Dependencies

1. Build ```libbson``` [from source](https://github.com/mongodb/libbson).

2. Add hard links to shared libraries
```
cp -lf /usr/local/lib/libbson* /usr/lib
```
3. Fix header
```
sudo sed -i 's/<bson.h>/"bson.h"/g' /usr/local/include/libbson-1.0/bcon.h
```

## OS X Dependencies

Install with Homebrew

```brew install libbson```