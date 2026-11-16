enum ServiceStatusEnum {
  notStarted,
  loading,
  success,
  error;

  bool get isSuccess => this == ServiceStatusEnum.success;
  bool get isLoading => this == ServiceStatusEnum.loading;
  bool get isError => this == ServiceStatusEnum.error;
}

class ServiceResponse<T> {
  final ServiceStatusEnum status;
  final T? data;
  final String? message;

  const ServiceResponse({
    required this.status,
    this.data,
    this.message,
  });

  factory ServiceResponse.success({T? data, String? message}) {
    return ServiceResponse<T>(
      status: ServiceStatusEnum.success,
      data: data,
      message: message,
    );
  }

  factory ServiceResponse.error({String? message, T? data}) {
    return ServiceResponse<T>(
      status: ServiceStatusEnum.error,
      data: data,
      message: message,
    );
  }
}

mixin ServiceStateMixin<T> {
  ServiceStatusEnum _serviceStatus = ServiceStatusEnum.notStarted;
  T? _serviceData;
  String? _errorMessage;

  ServiceStatusEnum get serviceStatus => _serviceStatus;
  T? get serviceData => _serviceData;
  String? get errorMessage => _errorMessage;

  Future<ServiceResponse<R>> serviceObserver<R>(
    Future<ServiceResponse<R>> Function() operation,
  ) async {
    _serviceStatus = ServiceStatusEnum.loading;
    _errorMessage = null;
    try {
      final response = await operation();
      _serviceStatus = response.status;
      _errorMessage = response.message;
      return response;
    } catch (error) {
      _serviceStatus = ServiceStatusEnum.error;
      _errorMessage = error.toString();
      return ServiceResponse<R>.error(message: _errorMessage);
    }
  }
}
