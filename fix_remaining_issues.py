import os
import re

def fix_file_issues():
    """Fix remaining issues in Flutter files"""
    
    # Files to fix with their specific issues
    fixes = {
        # Fix private type usage
        "lib/screens/dashboard/dashboard.dart": [
            (r"(\s+)_DashboardState createState\(\) => _DashboardState\(\);", r"\1State<Dashboard> createState() => _DashboardState();")
        ],
        "lib/screens/dashboard/reports.dart": [
            (r"(\s+)_ReportsState createState\(\) => _ReportsState\(\);", r"\1State<Reports> createState() => _ReportsState();")
        ],
        "lib/screens/dashboard/upload_data.dart": [
            (r"(\s+)_UploadDataState createState\(\) => _UploadDataState\(\);", r"\1State<UploadData> createState() => _UploadDataState();"),
            (r"print\(", r"debugPrint(")
        ],
        "lib/screens/orders/new_order.dart": [
            (r"print\(", r"debugPrint("),
            (r"Navigator\.push\(\s*context,", r"if (context.mounted) { Navigator.push(context,"),
            (r"Container\(\s*\)\s*,", r"const SizedBox(),")  # Fix unnecessary containers
        ],
        "lib/screens/orders/sales.dart": [
            (r"print\(", r"debugPrint(")
        ],
        "lib/screens/products/add_product.dart": [
            (r"(\s+)_AddProductState createState\(\) => _AddProductState\(\);", r"\1State<AddProduct> createState() => _AddProductState();"),
            (r"print\(", r"debugPrint("),
            (r"var Details", r"var details")
        ],
        "lib/screens/products/edit_product.dart": [
            (r"(\s+)_EditProductState createState\(\) => _EditProductState\(\);", r"\1State<EditProduct> createState() => _EditProductState();"),
            (r"print\(", r"debugPrint("),
            (r"Navigator\.push\(\s*context,", r"if (context.mounted) { Navigator.push(context,")
        ],
        "lib/services/apicalls.dart": [
            (r"print\(", r"debugPrint("),
            (r"desiredAccuracy:", r"// desiredAccuracy: // DEPRECATED - use settings parameter")
        ],
        "lib/services/firebase_.dart": [
            (r"var Location", r"var location"),
            (r"var Data", r"var data"),
            (r"Directory folder = .*?;", r"// Directory folder variable removed - unused")
        ],
        "lib/widgets/product_card.dart": [
            (r"withOpacity\(([\d.]+)\)", r"withValues(alpha: \1)"),
            (r"Navigator\.push\(\s*context,", r"if (context.mounted) { Navigator.push(context,"),
            (r"print\(", r"debugPrint("),
            (r"var DATA", r"var data")
        ],
        "lib/widgets/sidebar.dart": [
            (r"(\s+)_SidebarState createState\(\) => _SidebarState\(\);", r"\1State<Sidebar> createState() => _SidebarState();")
        ],
        "lib/widgets/text_box.dart": [
            (r"import 'package:flutter/cupertino\.dart';\n", r"")
        ]
    }
    
    for file_path, file_fixes in fixes.items():
        if os.path.exists(file_path):
            print(f"Fixing {file_path}...")
            
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            for pattern, replacement in file_fixes:
                content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
            
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"  ✓ Fixed {file_path}")
            else:
                print(f"  - No changes needed in {file_path}")
        else:
            print(f"  ! File not found: {file_path}")

if __name__ == "__main__":
    fix_file_issues()
    print("\nDone! Run 'flutter analyze' to verify the fixes.")
