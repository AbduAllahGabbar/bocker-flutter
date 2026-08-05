import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/accounts_repository.dart';
import '../../data/models/create_account_models.dart';
import 'create_account_state.dart';

class CreateAccountCubit extends Cubit<CreateAccountState> {
  final AccountsRepository _repository;

  bool _isReal = true;
  AccountTypeModel? _selectedAccountType;
  LeverageModel? _selectedLeverage;
  OpeningBalanceModel? _selectedOpeningBalance;

  List<AccountTypeModel>? _cachedAccountTypes;
  List<LeverageModel>? _cachedLeverages;
  List<OpeningBalanceModel>? _cachedOpeningBalances;

  CreateAccountCubit({required AccountsRepository repository})
      : _repository = repository,
        super(CreateAccountInitial()) {
    _emitFormUpdated();
  }

  void toggleAccountMode(bool isReal) {
    _isReal = isReal;
    // Reset selections on mode change
    _selectedAccountType = null;
    _selectedLeverage = null;
    _selectedOpeningBalance = null;
    _emitFormUpdated();
  }

  void setAccountType(AccountTypeModel? type) {
    _selectedAccountType = type;
    _emitFormUpdated();
  }

  void setLeverage(LeverageModel? leverage) {
    _selectedLeverage = leverage;
    _emitFormUpdated();
  }

  void setOpeningBalance(OpeningBalanceModel? balance) {
    _selectedOpeningBalance = balance;
    _emitFormUpdated();
  }

  void _emitFormUpdated() {
    emit(CreateAccountFormUpdated(
      isReal: _isReal,
      selectedAccountType: _selectedAccountType,
      selectedLeverage: _selectedLeverage,
      selectedOpeningBalance: _selectedOpeningBalance,
    ));
  }

  Future<List<AccountTypeModel>> getAccountTypes() async {
    if (_cachedAccountTypes != null && _cachedAccountTypes!.isNotEmpty) {
      return _cachedAccountTypes!;
    }
    final result = await _repository.getAccountTypes();
    return result.fold(
      (l) => [],
      (r) {
        _cachedAccountTypes = r;
        return r;
      },
    );
  }

  Future<List<LeverageModel>> getLeverages() async {
    if (_cachedLeverages != null && _cachedLeverages!.isNotEmpty) {
      return _cachedLeverages!;
    }
    final result = await _repository.getLeverages();
    return result.fold(
      (l) => [],
      (r) {
        _cachedLeverages = r;
        return r;
      },
    );
  }

  Future<List<OpeningBalanceModel>> getOpeningBalances() async {
    if (_cachedOpeningBalances != null && _cachedOpeningBalances!.isNotEmpty) {
      return _cachedOpeningBalances!;
    }
    final result = await _repository.getOpeningBalances();
    return result.fold(
      (l) => [],
      (r) {
        _cachedOpeningBalances = r;
        return r;
      },
    );
  }

  Future<void> submit() async {
    if (_isReal && (_selectedAccountType == null || _selectedLeverage == null)) {
      emit(CreateAccountError('Please select account type and leverage'));
      _emitFormUpdated();
      return;
    }
    if (!_isReal && (_selectedLeverage == null || _selectedOpeningBalance == null)) {
      emit(CreateAccountError('Please select leverage and opening balance'));
      _emitFormUpdated();
      return;
    }

    emit(CreateAccountLoading());

    Map<String, dynamic> data = {
      "type": _isReal ? "real" : "demo",
      "leverage": {
        "code": _selectedLeverage!.code,
        "name": _selectedLeverage!.name,
      }
    };

    if (_isReal) {
      data["accountType"] = {
        "code": _selectedAccountType!.code,
        "min": _selectedAccountType!.min,
        "name": _selectedAccountType!.name,
      };
    } else {
      data["initialBalance"] = {
        "code": _selectedOpeningBalance!.code,
        "name": _selectedOpeningBalance!.name,
      };
    }

    final result = await _repository.createAccount(data);
    result.fold(
      (failure) {
        emit(CreateAccountError(failure.message));
        _emitFormUpdated();
      },
      (account) {
        emit(CreateAccountSuccess());
        _emitFormUpdated();
      },
    );
  }
}
