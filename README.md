# flutter_playsuipi

Flutter plugin for embedding the native Play Suipi Core library.

|             | Android | iOS   | Linux | macOS  | Windows     |
|-------------|---------|-------|-------|--------|-------------|
| **Support** | SDK 21+ | 12.0+ | Any   | 10.14+ | Windows 10+ |

## Example

```dart
import 'package:flutter_playsuipi/core.dart';

const suits = ['♣', '♦', '♥', '♠'];

void showGame(GameRef game) {
    final floor = Core.readFloor(game);
    final floorString = floor
        .map((pile) => pile.value)
        .where((value) => value > 0)
        .join(', ');
    print('FLOOR: $floorString');
    final hands = Core.readHands(game);
    final handString = hands
        .map((card) => '${suits[card.suit]}${card.value}')
        .take(8)
        .join(', ');
    print('HAND: $floorString');
}

void main() {
    final seed = List<int>.generate(32, (i) => 0);
    final game = Core.newGame(seed);
    showGame(game);
    final move = '*C&3';
    print('\nApply Move: $move\n');
    Core.applyMove(game, move);
    Core.nextTurn(game);
    showGame(game);

    // Free game memory
    Core.freeGame(game);
}
```

## Getting Started

### Installing Rust

In order to compile this application, you will need access to a Rust compiler.

The easiest way to install Rust on Unix platforms is through
[rustup](https://www.rust-lang.org/tools/install).

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

You will need to install the Rust compiler targets for any platforms you wish
to use.

#### Install Android Targets:

```bash
rustup target add \
    aarch64-linux-android \
    x86_64-linux-android
```

#### Install iOS Targets:

```bash
rustup target add \
    aarch64-apple-ios \
    x86_64-apple-ios
```

#### Install Apple Build Tool:

To easily build all the binaries required by the `flutter_playsuipi` CocoaPod,
we use the [cargo-cocoapods](https://github.com/bbqsrc/cargo-cocoapods) tool.
This tool will build all the binaries used in our `flutter_playsiupi.pubspec`
configuration file.

```bash
cargo install cargo-cocoapods
```

#### Install for 32-bit Targets:

If you are trying to build for older 32-bit devices, you will need to install
some additional 32-bit targets.

```bash
rustup target add \
    armv7-linux-androideabi \
    i686-linux-android \
    armv7-apple-ios \
    i386-apple-ios
```
