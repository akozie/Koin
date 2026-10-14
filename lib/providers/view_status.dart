/// Lifecycle of an asynchronous screen/section load.
enum ViewStatus {
  initial,
  loading,
  success,
  failure;

  bool get isLoading => this == ViewStatus.loading;
  bool get isFailure => this == ViewStatus.failure;
  bool get isSuccess => this == ViewStatus.success;
}

/// Lifecycle of a form submission.
enum SubmitStatus {
  idle,
  submitting,
  success,
  failure;

  bool get isSubmitting => this == SubmitStatus.submitting;
}
