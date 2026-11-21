import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/upload_files_services/upload_files_services.dart';
import '../../../../features/accounts/data/models/account_model.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transactions_repository.dart';
import 'add_transaction_state.dart';

class AddTransactionCubit extends Cubit<AddTransactionState> {
  final TransactionsRepository repository;

  /// Payment method code of the gateway-backed deposit option, compared
  /// without case or separators (`my-fatoorah`, `MyFatoorah`, ...).
  static const String myFatoorahCode = 'myfatoorah';

  /// `true` when [method] is the MyFatoorah option offered by the backend.
  /// A method the broker disabled never reaches here: the data source drops
  /// inactive entries from the list.
  static bool isMyFatoorah(PaymentMethodModel? method) =>
      method != null && method.normalizedCode == myFatoorahCode;

  /// Methods that require the client to attach proof of payment.
  static const Set<String> methodsRequiringProof = {'bank'};

  /// Upload limits for the deposit proof.
  static const int maxAttachmentBytes = 10 * 1024 * 1024; // 10 MB
  static const Set<String> allowedAttachmentExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
    'pdf',
  };

  List<AccountModel> _accounts = [];
  final Map<String, List<PaymentMethodModel>> _paymentMethodsCache = {};

  Timer? _quoteDebounce;

  AddTransactionCubit({required this.repository})
    : super(const AddTransactionState());

  Future<List<AccountModel>> getAccounts() async {
    if (_accounts.isNotEmpty) return _accounts;
    final result = await repository.getAccounts();
    return result.fold((_) => <AccountModel>[], (accounts) {
      _accounts = accounts;
      return accounts;
    });
  }

  /// Deposit methods come from `paymentMethodList/admin` (`{type: 'deposit'}`),
  /// withdrawal methods from `paymentMethodList/user`.
  Future<List<PaymentMethodModel>> getPaymentMethods({
    required String type,
  }) async {
    final apiType = type.toLowerCase() == 'deposit' ? 'deposit' : 'withdrawal';

    final cached = _paymentMethodsCache[apiType];
    if (cached != null && cached.isNotEmpty) return cached;

    final result = await repository.getPaymentMethods(type: apiType);
    return result.fold((_) => <PaymentMethodModel>[], (methods) {
      _paymentMethodsCache[apiType] = methods;
      return methods;
    });
  }

  // --- MyFatoorah quote -----------------------------------------------------

  /// Requests the backend's payment quote for a MyFatoorah deposit.
  ///
  /// Fees are **never** computed in the app — whatever the backend returns is
  /// what the user is shown.
  void requestQuote({required AccountModel account, required num amount}) {
    _quoteDebounce?.cancel();

    if (amount <= 0) {
      emit(state.copyWith(clearQuote: true));
      return;
    }

    emit(
      state.copyWith(quoteStatus: QuoteStatus.loading, quoteErrorMessage: null),
    );

    _quoteDebounce = Timer(const Duration(milliseconds: 500), () async {
      final result = await repository.getMyFatoorahQuote(
        // The backend keys the quote on the account's own id.
        accountId: account.mongoId.isNotEmpty ? account.mongoId : account.id,
        amount: amount,
      );
      if (isClosed) return;
      result.fold(
        (failure) => emit(
          state.copyWith(
            quoteStatus: QuoteStatus.failure,
            quoteErrorMessage: failure.message,
          ),
        ),
        (quote) =>
            emit(state.copyWith(quoteStatus: QuoteStatus.loaded, quote: quote)),
      );
    });
  }

  void clearQuote() {
    _quoteDebounce?.cancel();
    emit(state.copyWith(clearQuote: true));
  }

  // --- Deposit proof --------------------------------------------------------

  /// Validates and uploads the chosen proof of payment.
  Future<void> attachProof(String filePath, {required bool isImage}) async {
    final file = File(filePath);
    final name = filePath.split(RegExp(r'[/\\]')).last;
    final extension = name.contains('.')
        ? name.split('.').last.toLowerCase()
        : '';

    if (!allowedAttachmentExtensions.contains(extension)) {
      emit(
        state.copyWith(
          attachmentStatus: AttachmentStatus.failure,
          attachmentName: name,
          attachmentErrorMessage:
              'Unsupported file type. Allowed: ${allowedAttachmentExtensions.join(', ')}.',
        ),
      );
      return;
    }

    int length;
    try {
      length = await file.length();
    } catch (_) {
      emit(
        state.copyWith(
          attachmentStatus: AttachmentStatus.failure,
          attachmentName: name,
          attachmentErrorMessage: 'The selected file could not be read.',
        ),
      );
      return;
    }

    if (length > maxAttachmentBytes) {
      emit(
        state.copyWith(
          attachmentStatus: AttachmentStatus.failure,
          attachmentName: name,
          attachmentErrorMessage:
              'File is too large. The maximum size is ${maxAttachmentBytes ~/ (1024 * 1024)} MB.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        attachmentStatus: AttachmentStatus.uploading,
        attachmentName: name,
        attachment: null,
        attachmentErrorMessage: null,
      ),
    );

    // Reuses the shared upload service (same endpoints the rest of the app
    // uses for identity documents and chat attachments).
    final result = isImage
        ? await UploadFilesServices.uploadImage(filePath)
        : await UploadFilesServices.uploadFile(filePath);

    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          attachmentStatus: AttachmentStatus.failure,
          attachmentErrorMessage: failure.message,
        ),
      ),
      (uploaded) => emit(
        state.copyWith(
          attachmentStatus: AttachmentStatus.ready,
          attachment: uploaded,
        ),
      ),
    );
  }

  void removeAttachment() => emit(state.copyWith(clearAttachment: true));

  // --- Submission -----------------------------------------------------------

  Future<void> submitTransaction({
    required String type, // 'deposit' | 'transfer' | 'withdrawal'
    required double amount,
    required AccountModel account,
    PaymentMethodModel? paymentMethod,
    AccountModel? accountTo,
  }) async {
    // A second tap while the first request is in flight would create a second
    // deposit for the same money.
    if (state.isSubmitting) return;

    emit(
      state.copyWith(
        status: AddTransactionStatus.submitting,
        clearError: true,
        clearResult: true,
      ),
    );

    // The backend's transaction type for a withdrawal is `withdrawal`.
    final apiType = type.toLowerCase() == 'withdrawal'
        ? 'withdrawal'
        : type.toLowerCase();

    final data = <String, dynamic>{
      "account": {
        "_id": account.mongoId,
        "id": num.tryParse(account.id) ?? account.id,
        "code": account.code,
      },
      // The deposit amount as the user entered it. Gateway fees are charged
      // on top by the provider and must never be added here, or the client
      // would be credited more than they deposited.
      "amount": amount,
      "type": apiType,
    };

    if (paymentMethod != null) {
      data["paymentMethod"] = {
        "code": paymentMethod.code,
        "name": paymentMethod.name,
      };
    }

    if (apiType == 'transfer' && accountTo != null) {
      data["accountTo"] = {
        "_id": accountTo.mongoId,
        "id": num.tryParse(accountTo.id) ?? accountTo.id,
        "code": accountTo.code,
      };
    }

    // Proof of payment, when one was uploaded.
    if (state.hasAttachment) {
      data["file"] = state.attachment;
    }

    final result = await repository.addTransaction(data);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AddTransactionStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (created) => emit(
        state.copyWith(
          status: AddTransactionStatus.success,
          transaction: created.transaction,
          paymentUrl: created.paymentUrl,
        ),
      ),
    );
  }

  /// Re-reads the created transaction from the backend.
  ///
  /// Used after returning from a hosted payment page: coming back from the
  /// gateway is never treated as proof that the payment succeeded — only the
  /// transaction's own status from the server is.
  Future<TransactionModel?> refreshCreatedTransaction() async {
    final created = state.transaction;
    if (created == null) return null;

    final result = await repository.getTransactions();
    return result.fold((_) => created, (transactions) {
      for (final transaction in transactions) {
        final sameId = created.id != null && transaction.id == created.id;
        final sameCode =
            created.code != null && transaction.code == created.code;
        if (sameId || sameCode) {
          if (!isClosed) emit(state.copyWith(transaction: transaction));
          return transaction;
        }
      }
      return created;
    });
  }

  @override
  Future<void> close() {
    _quoteDebounce?.cancel();
    return super.close();
  }
}
