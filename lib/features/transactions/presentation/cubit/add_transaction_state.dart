import 'package:equatable/equatable.dart';

import '../../data/models/myfatoorah_quote_model.dart';
import '../../data/models/transaction_model.dart';

enum AddTransactionStatus { initial, submitting, success, failure }

enum QuoteStatus { idle, loading, loaded, failure }

enum AttachmentStatus { none, uploading, ready, failure }

class AddTransactionState extends Equatable {
  final AddTransactionStatus status;

  /// The transaction the backend created, on success.
  final TransactionModel? transaction;

  /// Hosted payment page returned for a gateway deposit, on success.
  final String? paymentUrl;

  final String? errorMessage;

  // --- MyFatoorah quote -----------------------------------------------------
  final QuoteStatus quoteStatus;
  final MyFatoorahQuoteModel? quote;
  final String? quoteErrorMessage;

  // --- Deposit proof attachment --------------------------------------------
  final AttachmentStatus attachmentStatus;

  /// Name of the picked file, for display.
  final String? attachmentName;

  /// The uploaded file object returned by the upload service. This is what is
  /// sent in the transaction's `file` field.
  final Map<String, dynamic>? attachment;

  final String? attachmentErrorMessage;

  const AddTransactionState({
    this.status = AddTransactionStatus.initial,
    this.transaction,
    this.paymentUrl,
    this.errorMessage,
    this.quoteStatus = QuoteStatus.idle,
    this.quote,
    this.quoteErrorMessage,
    this.attachmentStatus = AttachmentStatus.none,
    this.attachmentName,
    this.attachment,
    this.attachmentErrorMessage,
  });

  bool get isSubmitting => status == AddTransactionStatus.submitting;

  bool get isUploadingAttachment =>
      attachmentStatus == AttachmentStatus.uploading;

  bool get hasAttachment =>
      attachmentStatus == AttachmentStatus.ready && attachment != null;

  AddTransactionState copyWith({
    AddTransactionStatus? status,
    TransactionModel? transaction,
    String? paymentUrl,
    String? errorMessage,
    QuoteStatus? quoteStatus,
    MyFatoorahQuoteModel? quote,
    String? quoteErrorMessage,
    AttachmentStatus? attachmentStatus,
    String? attachmentName,
    Map<String, dynamic>? attachment,
    String? attachmentErrorMessage,
    bool clearError = false,
    bool clearQuote = false,
    bool clearAttachment = false,
    bool clearResult = false,
  }) {
    return AddTransactionState(
      status: status ?? this.status,
      transaction: clearResult ? null : (transaction ?? this.transaction),
      paymentUrl: clearResult ? null : (paymentUrl ?? this.paymentUrl),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      quoteStatus: clearQuote
          ? QuoteStatus.idle
          : (quoteStatus ?? this.quoteStatus),
      quote: clearQuote ? null : (quote ?? this.quote),
      quoteErrorMessage: clearQuote
          ? null
          : (quoteErrorMessage ?? this.quoteErrorMessage),
      attachmentStatus: clearAttachment
          ? AttachmentStatus.none
          : (attachmentStatus ?? this.attachmentStatus),
      attachmentName: clearAttachment
          ? null
          : (attachmentName ?? this.attachmentName),
      attachment: clearAttachment ? null : (attachment ?? this.attachment),
      attachmentErrorMessage: clearAttachment
          ? null
          : (attachmentErrorMessage ?? this.attachmentErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    transaction,
    paymentUrl,
    errorMessage,
    quoteStatus,
    quote,
    quoteErrorMessage,
    attachmentStatus,
    attachmentName,
    attachment,
    attachmentErrorMessage,
  ];
}
