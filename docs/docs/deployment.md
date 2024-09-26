# Deployment

This page contains the steps that should be completed when building and
deploying a new version of Hyperion.

## Prerequisites

1. Ensure a keystore has been created

```
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

_Note:_ This can also be done via [Android Studio](https://developer.android.com/studio/publish/app-signing#generate-key)

2. Add a key.properties file (hidden via .gitignore)

```
# hyperion/android/key.properties

storePassword=<password-from-previous-step>
keyPassword=<password-from-previous-step>
keyAlias=upload
storeFile=<keystore-file-location>
```

## Build & Deploy

1. Update the build version in `hyperion/pubspec.yaml`
2. Navigate to the hyperion directory via terminal
3. Run the build command

```
flutter build apk --split-per-abi
```

4. Create a release on [GitHub](https://github.com/Demetrioz/Hyperion/releases)
   and upload the APKs
