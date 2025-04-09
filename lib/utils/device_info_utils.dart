import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfoUtils {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Get the device name and type
  static Future<String> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        WebBrowserInfo webInfo = await _deviceInfoPlugin.webBrowserInfo;
        return '${webInfo.browserName.name} on ${webInfo.platform ?? 'Web'}';
      } else if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        return '${androidInfo.model} (Android ${androidInfo.version.release})';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
        return '${iosInfo.name} (iOS ${iosInfo.systemVersion})';
      } else if (Platform.isWindows) {
        WindowsDeviceInfo windowsInfo = await _deviceInfoPlugin.windowsInfo;
        return 'Windows ${windowsInfo.productName} (${windowsInfo.computerName})';
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo macOsInfo = await _deviceInfoPlugin.macOsInfo;
        return 'macOS ${macOsInfo.osRelease} (${macOsInfo.hostName})';
      } else if (Platform.isLinux) {
        LinuxDeviceInfo linuxInfo = await _deviceInfoPlugin.linuxInfo;
        return 'Linux ${linuxInfo.prettyName} (${linuxInfo.name})';
      }
      return 'Unknown Device';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  /// Get the app version
  static Future<String> getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return 'v${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      return 'Unknown Version';
    }
  }

  /// Get the full version string with device info
  static Future<String> getFullVersionInfo() async {
    final deviceInfo = await getDeviceInfo();
    final appVersion = await getAppVersion();
    return 'NAFacial $appVersion | Powered by NAS | $deviceInfo';
  }
}
