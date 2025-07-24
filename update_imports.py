#!/usr/bin/env python3
import os
import re

# Define the mapping of old imports to new imports
import_mappings = {
    # Old package-style imports to new relative imports
    "package:searchaholic/imports.dart": "package:searchaholic/utils/imports.dart",
    "package:searchaholic/sidebar.dart": "package:searchaholic/widgets/sidebar.dart",
    "package:searchaholic/textBox.dart": "package:searchaholic/widgets/textBox.dart",
    "package:searchaholic/textbox2.dart": "package:searchaholic/widgets/textbox2.dart",
    "package:searchaholic/orderCard.dart": "package:searchaholic/widgets/orderCard.dart",
    "package:searchaholic/productCard.dart": "package:searchaholic/widgets/productCard.dart",
    "package:searchaholic/apicalls.dart": "package:searchaholic/services/apicalls.dart",
    "package:searchaholic/firebase_.dart": "package:searchaholic/services/firebase_.dart",
    "package:searchaholic/system.dart": "package:searchaholic/services/system.dart",
    "package:searchaholic/product.dart": "package:searchaholic/models/product.dart",
    
    # Auth screens
    "package:searchaholic/login.dart": "package:searchaholic/screens/auth/login.dart",
    "package:searchaholic/registration.dart": "package:searchaholic/screens/auth/registration.dart",
    "package:searchaholic/forgetPassword.dart": "package:searchaholic/screens/auth/forgetPassword.dart",
    "package:searchaholic/change_password.dart": "package:searchaholic/screens/auth/change_password.dart",
    
    # Dashboard screens
    "package:searchaholic/dashboard.dart": "package:searchaholic/screens/dashboard/dashboard.dart",
    "package:searchaholic/biCharts.dart": "package:searchaholic/screens/dashboard/biCharts.dart",
    "package:searchaholic/reports.dart": "package:searchaholic/screens/dashboard/reports.dart",
    "package:searchaholic/profile.dart": "package:searchaholic/screens/dashboard/profile.dart",
    "package:searchaholic/uploadData.dart": "package:searchaholic/screens/dashboard/uploadData.dart",
    
    # Product screens
    "package:searchaholic/addProduct.dart": "package:searchaholic/screens/products/addProduct.dart",
    "package:searchaholic/editProduct.dart": "package:searchaholic/screens/products/editProduct.dart",
    
    # Order screens
    "package:searchaholic/newOrder.dart": "package:searchaholic/screens/orders/newOrder.dart",
    "package:searchaholic/sales.dart": "package:searchaholic/screens/orders/sales.dart",
    "package:searchaholic/invoice.dart": "package:searchaholic/screens/orders/invoice.dart",
    
    # Splash screen
    "package:searchaholic/splash.dart": "package:searchaholic/screens/splash.dart",
    
    # Simple filename imports that need to be converted to full paths
    "imports.dart": "package:searchaholic/utils/imports.dart",
    "sidebar.dart": "package:searchaholic/widgets/sidebar.dart",
    "textBox.dart": "package:searchaholic/widgets/textBox.dart",
    "textbox2.dart": "package:searchaholic/widgets/textbox2.dart",
    "orderCard.dart": "package:searchaholic/widgets/orderCard.dart",
    "productCard.dart": "package:searchaholic/widgets/productCard.dart",
    "apicalls.dart": "package:searchaholic/services/apicalls.dart",
    "firebase_.dart": "package:searchaholic/services/firebase_.dart",
    "system.dart": "package:searchaholic/services/system.dart",
    "product.dart": "package:searchaholic/models/product.dart",
    "login.dart": "package:searchaholic/screens/auth/login.dart",
    "registration.dart": "package:searchaholic/screens/auth/registration.dart",
    "forgetPassword.dart": "package:searchaholic/screens/auth/forgetPassword.dart",
    "change_password.dart": "package:searchaholic/screens/auth/change_password.dart",
    "dashboard.dart": "package:searchaholic/screens/dashboard/dashboard.dart",
    "biCharts.dart": "package:searchaholic/screens/dashboard/biCharts.dart",
    "reports.dart": "package:searchaholic/screens/dashboard/reports.dart",
    "profile.dart": "package:searchaholic/screens/dashboard/profile.dart",
    "uploadData.dart": "package:searchaholic/screens/dashboard/uploadData.dart",
    "addProduct.dart": "package:searchaholic/screens/products/addProduct.dart",
    "editProduct.dart": "package:searchaholic/screens/products/editProduct.dart",
    "newOrder.dart": "package:searchaholic/screens/orders/newOrder.dart",
    "sales.dart": "package:searchaholic/screens/orders/sales.dart",
    "invoice.dart": "package:searchaholic/screens/orders/invoice.dart",
    "splash.dart": "package:searchaholic/screens/splash.dart",
}

def update_imports_in_file(file_path):
    """Update imports in a single Dart file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Update imports
        for old_import, new_import in import_mappings.items():
            # Pattern for import statements
            import_pattern = rf"import\s+['\"]({re.escape(old_import)})['\"]"
            replacement = f"import '{new_import}'"
            content = re.sub(import_pattern, replacement, content)
            
            # Also handle export statements
            export_pattern = rf"export\s+['\"]({re.escape(old_import)})['\"]"
            export_replacement = f"export '{new_import}'"
            content = re.sub(export_pattern, export_replacement, content)
        
        # Only write if content changed
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated imports in: {file_path}")
            return True
        return False
    except Exception as e:
        print(f"Error updating {file_path}: {e}")
        return False

def find_dart_files(lib_path):
    """Find all Dart files in the lib directory"""
    dart_files = []
    for root, dirs, files in os.walk(lib_path):
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    return dart_files

def main():
    lib_path = 'lib'
    if not os.path.exists(lib_path):
        print(f"Error: {lib_path} directory not found")
        return
    
    dart_files = find_dart_files(lib_path)
    updated_count = 0
    
    print(f"Found {len(dart_files)} Dart files")
    print("Updating import statements...")
    
    for file_path in dart_files:
        if update_imports_in_file(file_path):
            updated_count += 1
    
    print(f"\nCompleted! Updated imports in {updated_count} files")

if __name__ == "__main__":
    main()
