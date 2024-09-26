# Introduction

Hyperion is a mobile application that can receive notifications via MQTT. The
initial idea came from wanting a way to receive push notifications from various
IoT devices without having to rely on third party infrastructure and services.

The main concept is that the application will connect to an MQTT broker through
a background service that runs regardless of whether the app is in the
foreground.

## Technical Details

Hyperion is built using Flutter and has the capability to run on multiple
platforms. That being said, my main focus and consideration is for Android and
Linux. If you would like to verify functionality on any of the other platforms
(Windows, iOS, web), feel free to clone the repo localy and make any nescessary
PRs through [GitHub](https://github.com/Demetrioz/Hyperion).

### Dependencies

- [Flutter](https://flutter.dev/) - App framework
- [mqtt_client](https://pub.dev/packages/mqtt_client) - MQTT Client
- [flutter_backgroound_service](https://pub.dev/packages/flutter_background_service) - Background Service
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) - App Notifications
- [sqflite](https://pub.dev/packages/sqflite) - Data Persistence

### Versioning

Hyperion utilizes [semantic versioning](https://semver.org/) and follows the
\{MAJOR\}.\{MINOR\}.\{PATCH\} format. Release information can be found via the
[Releases](releases/0.1.0) page.

## Contact Information

Hyperion is developed and maintained by Kevin Williams. For assistance, please
reach out via [email](mailto:kevin@ktech.industries).

Have you encountered a bug?
[Let me know!](https://github.com/Demetrioz/Hyperion/issues)
