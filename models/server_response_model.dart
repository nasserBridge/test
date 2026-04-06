class ServerResponseModel {
  final List<dynamic>? unhealthyLinkTokens;
  final bool? allUnhealthy;
  final int statusCode;

  ServerResponseModel({
    this.unhealthyLinkTokens,
    required this.allUnhealthy,
    required this.statusCode,
  });
}
