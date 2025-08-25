import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import './playsuipi_core.dart' as lib;

// ignore: constant_identifier_names
const HAND_SIZE = 8;
// ignore: constant_identifier_names
const FLOOR_SIZE = 13;
// ignore: constant_identifier_names
const SCORE_SIZE = 4;

typedef GameRef = ffi.Pointer<ffi.Pointer<lib.Game>>;

/// Play Suipi Core Library
class Core {
  static const String _pkgName = 'flutter_playsuipi';
  static const String _libName = 'playsuipi_core';
  static final lib.PlaysuipiCore _core = lib.PlaysuipiCore(Core._loadLibrary());

  static ffi.DynamicLibrary _loadLibrary() {
    if (Platform.isMacOS || Platform.isIOS) {
      return ffi.DynamicLibrary.open('$_pkgName.framework/$_pkgName');
    }
    if (Platform.isAndroid || Platform.isLinux) {
      return ffi.DynamicLibrary.open('lib$_libName.so');
    }
    if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('$_libName.dll');
    }
    throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
  }

  /// Initialize a new game from the given seed
  static GameRef newGame(List<int> seed) {
    ffi.Pointer<ffi.Uint8> seedData = ffi.nullptr;
    if (seed.isNotEmpty) {
      seedData = malloc.allocate(ffi.sizeOf<ffi.Uint8>() * seed.length + 1);
      for (final (i, n) in seed.indexed) {
        seedData[i] = n;
      }
      seedData[seed.length] = 0; // Null termination
    }
    GameRef g = malloc.allocate(ffi.sizeOf<GameRef>());
    g.value = _core.new_game(seedData);
    malloc.free(seedData);
    return g;
  }

  /// Deinitializes a game reference
  static void freeGame(GameRef g) {
    malloc.free(g);
  }

  /// Get the status signals for a game
  static Status status(GameRef g) {
    ffi.Pointer<lib.Status> data = _core.status(g);
    final status = Status.fromRef(data.ref);
    malloc.free(data);
    return status;
  }

  /// Read both player's hands, the current player's first
  static List<Card> readHands(GameRef g) {
    List<Card> hands = [];
    ffi.Pointer<ffi.Uint8> data = _core.read_hands(g);
    for (var i = 0; i < HAND_SIZE * 2; i++) {
      hands.add(Card.fromAddress(data.address + (i * ffi.sizeOf<ffi.Uint8>())));
    }
    malloc.free(data);
    return hands;
  }

  /// Read the current floor piles
  static List<Pile> readFloor(GameRef g) {
    List<Pile> floor = [];
    ffi.Pointer<lib.Pile> data = _core.read_floor(g);
    for (var i = 0; i < FLOOR_SIZE; i++) {
      floor.add(Pile.fromAddress(data.address + (i * ffi.sizeOf<lib.Pile>())));
    }
    malloc.free(data);
    return floor;
  }

  /// Attempt to apply a move to the game state
  static String applyMove(GameRef g, String annotation) {
    final a = annotation.toNativeUtf8() as ffi.Pointer<ffi.Char>;
    final errorData = _core.apply_move(g, a) as ffi.Pointer<Utf8>;
    final error = errorData.toDartString();
    malloc.free(a);
    malloc.free(errorData);
    return error;
  }

  /// End the current player's turn
  static void nextTurn(GameRef g) {
    return _core.next_turn(g);
  }

  /// Undo the most recent move
  static void undo(GameRef g) {
    return _core.undo(g);
  }

  /// Get the score cards for the completed games
  static List<Scorecard> getScores(GameRef g) {
    List<Scorecard> scores = [];
    ffi.Pointer<lib.Scorecard> data = _core.get_scores(g);
    for (var i = 0; i < SCORE_SIZE; i++) {
      scores.add(
        Scorecard.fromAddress(data.address + (i * ffi.sizeOf<lib.Scorecard>())),
      );
    }
    malloc.free(data);
    return scores;
  }
}

/// A playing card
class Card {
  final int value;
  final int suit;

  const Card({required this.value, required this.suit});

  factory Card.fromInt(int cardId) {
    if (cardId >= 52) {
      return const Card(value: 0, suit: 0);
    }
    return Card(value: cardId % 13 + 1, suit: (cardId / 13).floor());
  }

  factory Card.fromAddress(int ptr) {
    ffi.Pointer<ffi.Uint8> data = ffi.Pointer.fromAddress(ptr);
    return Card.fromInt(data.value);
  }

  @override
  int get hashCode => value.hashCode ^ suit.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Card &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          suit == other.suit;
}

/// A pile type marker
enum Mark { empty, single, build, group, pair }

/// A pile of cards
class Pile {
  final List<Card> cards;
  final int value;
  final Mark mark;
  final bool owner;

  const Pile({
    required this.cards,
    required this.value,
    required this.mark,
    required this.owner,
  });

  factory Pile.fromAddress(int ptr, {bool pair = false}) {
    ffi.Pointer<lib.Pile> data = ffi.Pointer.fromAddress(ptr);
    final cards = data.ref.cards.elements
        .where((cid) => cid < 52)
        .map((cid) => Card.fromInt(cid))
        .toList();
    final value = data.ref.value;
    Mark mark = Mark.empty;
    if (cards.isNotEmpty) {
      if (cards.length == 1) {
        mark = Mark.single;
      } else if (data.ref.build) {
        mark = Mark.build;
      } else {
        mark = Mark.group;
      }
    }
    if (pair) {
      mark = Mark.pair;
    }
    return Pile(cards: cards, value: value, mark: mark, owner: data.ref.owner);
  }

  @override
  int get hashCode =>
      cards.hashCode ^ value.hashCode ^ mark.hashCode ^ owner.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pile &&
          runtimeType == other.runtimeType &&
          cards == other.cards &&
          value == other.value &&
          mark == other.mark &&
          owner == other.owner;
}

/// Game status and telemetry
class Status {
  final int game;
  final int round;
  final bool turn;
  final int hand;
  final int floor;
  final List<int> seed;

  const Status({
    required this.game,
    required this.round,
    required this.turn,
    required this.hand,
    required this.floor,
    required this.seed,
  });

  factory Status.fromRef(lib.Status data) {
    return Status(
      game: data.game,
      round: data.round,
      turn: data.turn,
      hand: data.hand,
      floor: data.floor,
      seed: data.seed.elements.toList(),
    );
  }

  @override
  int get hashCode =>
      game.hashCode ^
      round.hashCode ^
      turn.hashCode ^
      hand.hashCode ^
      floor.hashCode ^
      seed.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Status &&
          runtimeType == other.runtimeType &&
          game == other.game &&
          round == other.round &&
          turn == other.turn &&
          hand == other.hand &&
          floor == other.floor &&
          seed == other.seed;
}

/// Player scorecard
class Scorecard {
  final int aces;
  final int mostCards;
  final int mostSpades;
  final int suipiCount;
  final int tenOfDiamonds;
  final int twoOfSpades;
  final int total;

  const Scorecard({
    required this.aces,
    required this.mostCards,
    required this.mostSpades,
    required this.suipiCount,
    required this.tenOfDiamonds,
    required this.twoOfSpades,
    required this.total,
  });

  factory Scorecard.fromAddress(int ptr) {
    ffi.Pointer<lib.Scorecard> data = ffi.Pointer.fromAddress(ptr);
    return Scorecard(
      aces: data.ref.aces,
      mostCards: data.ref.most_cards,
      mostSpades: data.ref.most_spades,
      suipiCount: data.ref.suipi_count,
      tenOfDiamonds: data.ref.ten_of_diamonds,
      twoOfSpades: data.ref.two_of_spades,
      total: data.ref.total,
    );
  }

  @override
  int get hashCode =>
      aces.hashCode ^
      mostCards.hashCode ^
      mostSpades.hashCode ^
      suipiCount.hashCode ^
      tenOfDiamonds.hashCode ^
      twoOfSpades.hashCode ^
      total.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Scorecard &&
          runtimeType == other.runtimeType &&
          aces == other.aces &&
          mostCards == other.mostCards &&
          mostSpades == other.mostSpades &&
          suipiCount == other.suipiCount &&
          tenOfDiamonds == other.tenOfDiamonds &&
          twoOfSpades == other.twoOfSpades &&
          total == other.total;
}
