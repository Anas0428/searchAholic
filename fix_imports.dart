import 'dart:io';

void main() {
  // Map of old file names to new paths
  final Map<String, String> fileMapping = {
    'login.dart': 'screens/auth/login.dart',
    'registration.dart': 'screens/auth/registration.dart',
    'forgetPassword.dart': 'screens/auth/forgetPassword.dart',
    'change_password.dart': 'screens/auth/change_password.dart',
    'dashboard.dart': 'screens/dashboard/dashboard.dart',
    'biCharts.dart': 'screens/dashboard/biCharts.dart',
    'reports.dart': 'screens/dashboard/reports.dart',
    'profile.dart': 'screens/dashboard/profile.dart',
    'uploadData.dart': 'screens/dashboard/uploadData.dart',
    'addProduct.dart': 'screens/products/addProduct.dart',
    'editProduct.dart': 'screens/products/editProduct.dart',
    'newOrder.dart': 'screens/orders/newOrder.dart',
    'sales.dart': 'screens/orders/sales.dart',
    'invoice.dart': 'screens/orders/invoice.dart',
    'splash.dart': 'screens/splash.dart',
    'sidebar.dart': 'widgets/sidebar.dart',
    'orderCard.dart': 'widgets/orderCard.dart',
    'productCard.dart': 'widgets/productCard.dart',
    'textBox.dart': 'widgets/textBox.dart',
    'textbox2.dart': 'widgets/textbox2.dart',
    'apicalls.dart': 'services/apicalls.dart',
    'firebase_.dart': 'services/firebase_.dart',
    'system.dart': 'services/system.dart',
    'product.dart': 'models/product.dart',
    'imports.dart': 'utils/imports.dart',
  };

  // Get all Dart files in lib directory
  final libDir = Directory('lib');
  final dartFiles = libDir
      .listSync(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();

  // Found ${dartFiles.length} Dart files to process...

  for (final file in dartFiles) {
    // Processing: ${file.path}
    
    String content = file.readAsStringSync();
    bool modified = false;

    // Fix package imports
    for (final entry in fileMapping.entries) {
      final oldImport = "import 'package:searchaholic/${entry.key}';";
      final newImport = "import 'package:searchaholic/${entry.value}';";
      
      if (content.contains(oldImport)) {
        content = content.replaceAll(oldImport, newImport);
        modified = true;
        // Fixed: ${entry.key} -> ${entry.value}
      }
    }

    // Fix relative imports that might be incorrect
    final lines = content.split('\n');
    final updatedLines = <String>[];
    
    for (String line in lines) {
      if (line.trim().startsWith("import '") && !line.contains('package:') && !line.contains('dart:')) {
        // This is a relative import, let's check if it needs fixing
        String updatedLine = line;
        
        for (final entry in fileMapping.entries) {
          if (line.contains("'${entry.key}'") || line.contains("/${entry.key}'")) {
            // Calculate relative path from current file to target file
            final currentFilePath = file.path.replaceAll('\\', '/').replaceAll('lib/', '');
            final targetFilePath = entry.value;
            final relativePath = _calculateRelativePath(currentFilePath, targetFilePath);
            
            if (line.contains("'${entry.key}'")) {
              updatedLine = line.replaceAll("'${entry.key}'", "'$relativePath'");
            } else if (line.contains("/${entry.key}'")) {
              updatedLine = line.replaceAll("/${entry.key}'", "/$relativePath'");
            }
            
            if (updatedLine != line) {
              modified = true;
              // Fixed relative import: ${entry.key} -> $relativePath
            }
            break;
          }
        }
        updatedLines.add(updatedLine);
      } else {
        updatedLines.add(line);
      }
    }

    if (modified) {
      content = updatedLines.join('\n');
      file.writeAsStringSync(content);
      // ✓ Updated ${file.path}
    }
  }

  // Import fixing completed!
  // Run "flutter analyze" to check for any remaining issues.
}

String _calculateRelativePath(String fromPath, String toPath) {
  final fromParts = fromPath.split('/');
  final toParts = toPath.split('/');
  
  // Remove the filename from fromPath
  fromParts.removeLast();
  
  // Calculate how many directories to go up
  int commonPrefix = 0;
  for (int i = 0; i < fromParts.length && i < toParts.length; i++) {
    if (fromParts[i] == toParts[i]) {
      commonPrefix++;
    } else {
      break;
    }
  }
  
  final upLevels = fromParts.length - commonPrefix;
  final downPath = toParts.skip(commonPrefix).join('/');
  
  if (upLevels == 0) {
    return downPath;
  } else {
    return '../' * upLevels + downPath;
  }
}
