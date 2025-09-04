import 'package:shopwise/utils/imports.dart';
import 'package:shopwise/widgets/sidebar.dart';
import 'package:shopwise/services/sales_service.dart';
import 'package:shopwise/models/sale_model.dart';
import 'package:intl/intl.dart';

class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  List<SaleModel> _sales = [];
  Map<String, dynamic> _analytics = {};
  bool _isLoading = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeSales();
  }

  void _initializeSales() {
    // Listen to real-time sales updates
    SalesService.getSalesStream().listen(
      (sales) {
        if (mounted) {
          setState(() {
            _sales = sales;
            _isLoading = false;
            _error = null;
          });
          _loadAnalytics();
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _error = error.toString();
            _isLoading = false;
          });
        }
      },
    );
  }

  Future<void> _loadAnalytics() async {
    try {
      final analytics = await SalesService.getSalesAnalytics();
      if (mounted) {
        setState(() {
          _analytics = analytics;
        });
      }
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Row(
          children: [
            Sidebar(),
            Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Row(
          children: [
            const Sidebar(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading sales data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                        });
                        _initializeSales();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02),
                    child: const Text(
                      "Sales Dashboard",
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Analytics Cards
                  _buildAnalyticsCards(),

                  const SizedBox(height: 20),

                  // Sales Chart
                  _buildSalesChart(),

                  const SizedBox(height: 20),

                  // Sales Table
                  Expanded(
                    child: _buildSalesTable(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCards() {
    final totalSales = _analytics['totalSales'] ?? 0.0;
    final totalOrders = _analytics['totalOrders'] ?? 0;
    final todaysSales = _analytics['todaysSales'] ?? 0.0;
    final thisWeekSales = _analytics['thisWeekSales'] ?? 0.0;

    return SizedBox(
      height: 120,
      child: Row(
        children: [
          Expanded(
            child: _buildAnalyticsCard(
              'Total Sales',
              '\$${totalSales.toStringAsFixed(2)}',
              Icons.attach_money,
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildAnalyticsCard(
              'Total Orders',
              totalOrders.toString(),
              Icons.shopping_cart,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildAnalyticsCard(
              'Today\'s Sales',
              '\$${todaysSales.toStringAsFixed(2)}',
              Icons.today,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildAnalyticsCard(
              'This Week',
              '\$${thisWeekSales.toStringAsFixed(2)}',
              Icons.date_range,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    final dailySales = _analytics['dailySales'] as Map<String, double>? ?? {};

    if (dailySales.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text(
              'No sales data available for chart',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final chartData = dailySales.entries.map((entry) {
      return {'domain': entry.key, 'measure': entry.value};
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Sales Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (var entry in chartData.take(5))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry['domain'].toString()),
                            Text(
                                '\$${(entry['measure'] as double).toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesTable() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Recent Sales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _sales.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No sales records found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Customer')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: Text('Sale ID')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _sales.map((sale) {
                        return DataRow(
                          cells: [
                            DataCell(Text(sale.customerPhone)),
                            DataCell(Text(
                              sale.saleDate != null
                                  ? DateFormat('dd/MM/yyyy')
                                      .format(sale.saleDate!)
                                  : 'N/A',
                            )),
                            DataCell(Text(
                                '\$${sale.saleAmount.toStringAsFixed(2)}')),
                            DataCell(Text(sale.saleId)),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.visibility),
                                onPressed: () => _showInvoiceDialog(sale),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showInvoiceDialog(SaleModel sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "INVOICE DETAILS",
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Date & Time: ${sale.saleDate != null ? DateFormat('dd/MM/yyyy HH:mm').format(sale.saleDate!) : 'N/A'}",
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
              const Divider(thickness: 2),
              Text(
                "Customer#: ${sale.customerPhone}",
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
              const Divider(thickness: 2),
              const Text(
                "Products:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: sale.saleProducts.length,
                  itemBuilder: (context, index) {
                    final productName = sale.saleProducts.keys.toList()[index];
                    final quantity = sale.saleProducts.values.toList()[index];
                    return ListTile(
                      title: Text(productName),
                      subtitle: Text("Quantity: $quantity"),
                      dense: true,
                    );
                  },
                ),
              ),
              const Divider(thickness: 2),
              ListTile(
                dense: true,
                title: const Text('Total discount'),
                trailing: const Text('0'),
              ),
              ListTile(
                dense: true,
                title: const Text('Sales Tax %'),
                trailing: const Text('0'),
              ),
              ListTile(
                dense: true,
                title: const Text(
                  'Total Amount',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '\$${sale.saleAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // Legacy method - kept for compatibility but not used
  Future invoiceDiagloge(String saleId, Map products, Map sel) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Padding(
            padding: EdgeInsets.only(left: 0),
            child: Text(
              "INVOICE PRODUCTS",
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          ),
          content: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 0),
                child: Text(
                    "Date & Time: ${sel['saleDate'].toString().split(" ")[0]}",
                    style: const TextStyle(fontSize: 14, color: Colors.black)),
              ),
              const Divider(
                thickness: 2,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 175),
                child: Text("Customer#: ${sel['customerPhone']}",
                    style: const TextStyle(fontSize: 14, color: Colors.black)),
              ),
              const Divider(
                thickness: 2,
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width * 0.3,
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      debugPrint(index.toString());
                      return ListTile(
                        title: Text(products.keys.toList()[index]),
                        subtitle: Text("x ${products.values.toList()[index]}"),
                      );
                    },
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 05),
                child: ListTile(
                  dense: true,
                  title: Text(
                    'Total discount',
                  ),
                  trailing: Text('0'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 05),
                child: ListTile(
                  dense: true,
                  title: Text(
                    'Sales Tax %',
                  ),
                  trailing: Text('0'),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 05),
                child: ListTile(
                  dense: true,
                  title: const Text(
                    'Total Amount',
                  ),
                  trailing: Text('Rs. ${sel['saleAmount']}'),
                ),
              ),
              const Divider(
                thickness: 2,
              ),

              // Add more Text widgets for additional lines of data
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: const Text("Ok"),
            ),
          ],
        ),
      );
}
