import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class DownloadHelper {
  static Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        return true;
      }
      
      // For Android 13 and above
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        if (await Permission.photos.request().isGranted &&
            await Permission.videos.request().isGranted &&
            await Permission.audio.request().isGranted) {
          return true;
        }
      }
      
      return false;
    }
    return true; // iOS doesn't need runtime permission
  }

  static Future<void> downloadFile(String url, BuildContext context) async {
    try {
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to download files'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show download progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Downloading file...'),
            ],
          ),
        ),
      );

      // Get file name from URL
      final fileName = url.split('/').last.split('?').first;
      
      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        // Create directory if it doesn't exist
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      final filePath = '${directory.path}/$fileName';

      // Download file using Dio
      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint('Download Progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      // Close progress dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File downloaded successfully to: $filePath'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      // Close progress dialog if open
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}