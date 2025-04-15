import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart' show BuildContext, ScaffoldMessenger, SnackBar, Text, Color;

class PdfHelper {
  static Future<void> generateAndDownloadPdf(
    Map<String, dynamic> application,
    String imageUrl,
    BuildContext context,
  ) async {
    try {
      // Create PDF document
      final pdf = pw.Document();

      // Download image
      final response = await http.get(Uri.parse(imageUrl));
      final imageBytes = response.bodyBytes;

      // Add page to PDF
      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text('Application Details', 
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)
              ),
            ),
            pw.SizedBox(height: 20),

            // Application Information
            pw.Header(level: 1, text: 'Application Information'),
            _buildInfoSection([
              {'Category': application['category'] ?? 'Not specified'},
              {'Status': application['status'] ?? 'Unknown'},
              {'Created On': DateTime.parse(application['createdAt'])
                  .toLocal().toString().split('.')[0]},
            ]),
            pw.SizedBox(height: 20),

            // Personal Information
            pw.Header(level: 1, text: 'Personal Information'),
            _buildInfoSection([
              {'Full Name': application['fullName'] ?? 'Not specified'},
              {'Age': '${application['age'] ?? 'Not specified'} years'},
              {'Gender': application['gender'] ?? 'Not specified'},
              {'Phone Number': application['contactNumber'] ?? 'Not specified'},
            ]),
            pw.SizedBox(height: 20),

            // Location Details
            pw.Header(level: 1, text: 'Location Details'),
            _buildInfoSection([
              {'District': application['district'] ?? 'Not specified'},
              {'Revenue Circle': application['revenueCircle'] ?? 'Not specified'},
              {'Village/Ward': application['villageWard'] ?? 'Not specified'},
            ]),
            pw.SizedBox(height: 20),

            // Remarks if available
            if (application['remarks'] != null && 
                application['remarks'].toString().isNotEmpty) ...[
              pw.Header(level: 1, text: 'Remarks'),
              pw.Text(application['remarks']),
              pw.SizedBox(height: 20),
            ],

            // Attached Document
            pw.Header(level: 1, text: 'Attached Document'),
            pw.Image(
              pw.MemoryImage(imageBytes),
              height: 400,
              fit: pw.BoxFit.contain,
            ),
          ],
        ),
      );

      // Get download directory
      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          downloadDir = await getExternalStorageDirectory();
        }
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (downloadDir == null) {
        throw Exception('Could not access storage directory');
      }

      // Generate filename
      final String timestamp = DateTime.now()
          .toString()
          .replaceAll(' ', '_')
          .replaceAll(':', '-')
          .split('.')[0];
      final String filePath = 
          '${downloadDir.path}/${application['fullName']?.replaceAll(' ', '_') ?? 'unknown'}_details_$timestamp.pdf';

      // Save PDF
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to: $filePath'),
            backgroundColor: const Color(0xFF009688),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  static pw.Widget _buildInfoSection(List<Map<String, String>> details) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: details.map((detail) {
        final entry = detail.entries.first;
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '${entry.key}: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.TextSpan(text: entry.value),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}