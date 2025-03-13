// lib/features/history/state/wallet_history_state.dart
import 'package:flutter/foundation.dart';

import '../../wallet/model/get_wallet_transactions.dart';

class WalletHistoryState {
  final List<WalletTransactionModel> transactions;
  final bool isLoading;
  final String? errorMessage;

  WalletHistoryState({
    this.transactions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  bool get hasError => errorMessage != null;
  bool get hasTransactions => transactions.isNotEmpty;

  WalletHistoryState copyWith({
    List<WalletTransactionModel>? transactions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WalletHistoryState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class WalletHistoryStateNotifier extends ChangeNotifier {
  WalletHistoryState _state = WalletHistoryState();
  WalletHistoryState get state => _state;

  void setLoading(bool loading) {
    _state = _state.copyWith(isLoading: loading);
    notifyListeners();
  }

  void setTransactions(List<WalletTransactionModel> transactions) {
    _state = _state.copyWith(
      transactions: transactions,
      errorMessage: null,
    );
    notifyListeners();
  }

  void setError(String message) {
    _state = _state.copyWith(
      errorMessage: message,
      isLoading: false,
    );
    notifyListeners();
  }
}
