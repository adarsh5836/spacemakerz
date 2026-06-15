import 'package:equatable/equatable.dart';

class PhotoCaptureState extends Equatable {
  final List<String> uploadedUrls;
  final bool isUploading;
  final bool isSubmitting;
  final bool submitSuccess;
  final String? errorMessage;
  final String? successMessage;

  const PhotoCaptureState({
    this.uploadedUrls = const [],
    this.isUploading = false,
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.errorMessage,
    this.successMessage,
  });

  PhotoCaptureState copyWith({
    List<String>? uploadedUrls,
    bool? isUploading,
    bool? isSubmitting,
    bool? submitSuccess,
    String? errorMessage,
    String? successMessage,
  }) {
    return PhotoCaptureState(
      uploadedUrls: uploadedUrls ?? this.uploadedUrls,
      isUploading: isUploading ?? this.isUploading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        uploadedUrls,
        isUploading,
        isSubmitting,
        submitSuccess,
        errorMessage,
        successMessage,
      ];
}
