class BrokerSettings {
  String host;
  int port;
  String client;
  String user;
  String password;
  String notificationChannel;

  BrokerSettings(
      {required this.host,
      required this.port,
      required this.client,
      required this.user,
      required this.password,
      required this.notificationChannel});
}
