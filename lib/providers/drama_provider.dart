import 'package:flutter/foundation.dart';
import '../models/drama_item.dart';

class DramaProvider extends ChangeNotifier {
  final List<DramaItem> _watchlist = [];

  List<DramaItem> get watchlist =>
      List.unmodifiable(_watchlist);

  bool isInWatchlist(DramaItem drama) {
    return _watchlist.any(
      (item) => item.title == drama.title,
    );
  }

  void addToWatchlist(DramaItem drama) {
    if (isInWatchlist(drama)) {
      return;
    }

    _watchlist.add(drama);
    notifyListeners();
  }

  void removeFromWatchlist(DramaItem drama) {
    _watchlist.removeWhere(
      (item) => item.title == drama.title,
    );

    notifyListeners();
  }

  void toggleWatchlist(DramaItem drama) {
    if (isInWatchlist(drama)) {
      removeFromWatchlist(drama);
    } else {
      addToWatchlist(drama);
    }
  }

  void clearWatchlist() {
    if (_watchlist.isEmpty) {
      return;
    }

    _watchlist.clear();
    notifyListeners();
  }
}