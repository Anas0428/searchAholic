import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shopwise/services/firebase_.dart';
import 'package:shopwise/widgets/sidebar.dart';
import 'package:url_launcher/url_launcher.dart';

class UploadData extends StatefulWidget {
  const UploadData({super.key});

  @override
  State<UploadData> createState() => _UploadDataState();
}

class _UploadDataState extends State<UploadData> {
  void successAlert() {
    QuickAlert.show(
      context: context,
      title: "File Uploaded",
      text: "Your file has been uploaded successfully",
      type: QuickAlertType.success,
    );
  }

  void errorAlert() {
    QuickAlert.show(
      context: context,
      title: "Error",
      text:
          "There was an error uploading your file. Please check the Sample Data — your fields may not match the format.",
      type: QuickAlertType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.01,
              ),
              child: Column(
                children: [
                  const Padding(padding: EdgeInsets.only(top: 20)),
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.057,
                    ),
                    child: Text(
                      "Upload Bulk Data",
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.of(context).size.width / 45,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.13,
                    ),
                    child: ElevatedButton(
                      child: const Text('Upload CSV File'),
                      onPressed: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['csv'],
                        );

                        if (result != null) {
                          final PlatformFile file = result.files.first;

                          if (!context.mounted) return;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("File Details"),
                                  content: Text(
                                    "File Name: ${file.name}\n"
                                    "File Size: ${file.size} bytes\n\n"
                                    "Are you sure you want to upload this file?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        final String? filePath = file.path;
                                        Navigator.of(context).pop();

                                        if (filePath == null) {
                                          QuickAlert.show(
                                            context: context,
                                            title: "Error",
                                            text:
                                                "Selected file path is not available on this platform.",
                                            type: QuickAlertType.error,
                                          );
                                          return;
                                        }

                                        FlutterApi().uploadFile(filePath).then(
                                          (success) {
                                            if (!mounted) return;
                                            if (success == true) {
                                              successAlert();
                                            } else {
                                              errorAlert();
                                            }
                                          },
                                        );
                                      },
                                      child: const Text("Upload"),
                                    ),
                                  ],
                                );
                              },
                            );
                        } else {
                          debugPrint("No file selected");
                        }
                      },
                    ),
                  ),

                  // Instructions Section
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.075,
                      right: MediaQuery.of(context).size.width * 0.45,
                    ),
                    child: Text(
                      "CSV Format Requirements:\n"
                      "1. Exactly 5 columns in this order: Name, Category, Type, Price, Quantity\n"
                      "2. No header row - data starts from first row\n"
                      "3. Example: Doxycycline,Drops,Anti-inflammatory,29.36,303\n"
                      "4. Price should be numeric (e.g., 29.36)\n"
                      "5. Quantity should be whole number (e.g., 303)",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w200,
                        fontSize: MediaQuery.of(context).size.width / 80,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.135,
                      left: MediaQuery.of(context).size.width * 0.01,
                    ),
                    child: ElevatedButton(
                      child: const Text('Download Sample Data'),
                      onPressed: () {
                        Uri uri = Uri.parse(
                          "https://cdn.discordapp.com/attachments/748221133819609108/1091224870320349194/MedicinceData.csv",
                        );
                        launchUrl(uri);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
