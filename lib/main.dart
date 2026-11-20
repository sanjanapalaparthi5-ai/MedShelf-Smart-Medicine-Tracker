
import 'package:flutter/material.dart';

void main() {
  runApp(const MedShelfApp());
}

class MedShelfApp extends StatelessWidget {
  const MedShelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MedShelf - Medicine Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MedShelfHomePage(),
    );
  }
}

class Medicine {
  String name;
  String purpose;
  int tabletsLeft;
  DateTime expiryDate;

  Medicine({
    required this.name,
    required this.purpose,
    required this.tabletsLeft,
    required this.expiryDate,
  });

  int get daysUntilExpiry =>
      expiryDate.difference(DateTime.now()).inDays;

  bool get isExpired => daysUntilExpiry < 0;
  bool get isExpiringSoon => !isExpired && daysUntilExpiry <= 30;
  bool get isLowStock => tabletsLeft <= 3;

  String get formattedExpiry =>
      '${expiryDate.day.toString().padLeft(2, '0')}/${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year}';
}

class MedShelfHomePage extends StatefulWidget {
  const MedShelfHomePage({super.key});

  @override
  State<MedShelfHomePage> createState() => _MedShelfHomePageState();
}

class _MedShelfHomePageState extends State<MedShelfHomePage> {
  String _selectedFilter = 'All';

  final List<Medicine> _medicines = [
    Medicine(
      name: 'Paracetamol 650mg',
      purpose: 'Fever & Body Ache',
      tabletsLeft: 10,
      expiryDate: DateTime.now().add(const Duration(days: 240)),
    ),
    Medicine(
      name: 'Cetirizine 10mg',
      purpose: 'Allergy & Cold',
      tabletsLeft: 6,
      expiryDate: DateTime.now().add(const Duration(days: 14)),
    ),
    Medicine(
      name: 'Vitamin D3 60K',
      purpose: 'Immunity Supplement',
      tabletsLeft: 2,
      expiryDate: DateTime.now().add(const Duration(days: 150)),
    ),
    Medicine(
      name: 'Antacid Gel Tabs',
      purpose: 'Acidity Relief',
      tabletsLeft: 8,
      expiryDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  List<Medicine> get _filteredMedicines {
    if (_selectedFilter == 'Alerts') {
      return _medicines
          .where((m) => m.isExpired || m.isExpiringSoon)
          .toList();
    } else if (_selectedFilter == 'Low Stock') {
      return _medicines.where((m) => m.isLowStock).toList();
    }
    return _medicines;
  }

  void _showAddMedicineDialog() {
    final nameController = TextEditingController();
    final purposeController = TextEditingController();
    final stockController = TextEditingController();

    DateTime selectedDate =
        DateTime.now().add(const Duration(days: 180));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Medicine'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name (e.g., Ibuprofen)',
                  ),
                ),
                TextField(
                  controller: purposeController,
                  decoration: const InputDecoration(
                    labelText: 'Usage / Purpose',
                  ),
                ),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of Tablets',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expiry: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(
                        Icons.calendar_today,
                        size: 18,
                      ),
                      label: const Text('Pick Date'),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2032),
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final purpose = purposeController.text.trim();
                final stock =
                    int.tryParse(stockController.text) ?? 0;

                if (name.isNotEmpty && stock > 0) {
                  setState(() {
                    _medicines.add(
                      Medicine(
                        name: name,
                        purpose: purpose.isEmpty
                            ? 'General Care'
                            : purpose,
                        tabletsLeft: stock,
                        expiryDate: selectedDate,
                      ),
                    );
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int alertCount = _medicines
        .where((m) => m.isExpired || m.isExpiringSoon)
        .length;

    final int lowStockCount =
        _medicines.where((m) => m.isLowStock).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MedShelf — First-Aid Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatCard(
                  'Total Meds',
                  '${_medicines.length}',
                  Colors.teal,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Expiry Alerts',
                  '$alertCount',
                  Colors.red,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Low Stock',
                  '$lowStockCount',
                  Colors.orange.shade800,
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: ['All', 'Alerts', 'Low Stock'].map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: _filteredMedicines.length,
                itemBuilder: (context, index) {
                  final med = _filteredMedicines[index];

                  Color statusColor = Colors.green.shade700;
                  String statusLabel =
                      'Safe (${med.daysUntilExpiry}d left)';

                  if (med.isExpired) {
                    statusColor = Colors.red.shade700;
                    statusLabel = 'EXPIRED';
                  } else if (med.isExpiringSoon) {
                    statusColor = Colors.orange.shade800;
                    statusLabel =
                        'Expiring in ${med.daysUntilExpiry}d';
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  med.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                    color: statusColor,
                                  ),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'Purpose: ${med.purpose} | Exp: ${med.formattedExpiry}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Text(
                                'Stock: ${med.tabletsLeft} tablets',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: med.isLowStock
                                      ? Colors.red
                                      : Colors.black87,
                                ),
                              ),
                              if (med.isLowStock)
                                const Text(
                                  ' (LOW STOCK!)',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: med.tabletsLeft > 0
                                    ? () {
                                        setState(() {
                                          med.tabletsLeft--;
                                        });

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            duration: const Duration(
                                              seconds: 1,
                                            ),
                                            content: Text(
                                              'Logged 1 dose of ${med.name}',
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                icon: const Icon(
                                  Icons.medication,
                                  size: 18,
                                ),
                                label: const Text('Log Dose (-1)'),
                              ),

                              const SizedBox(width: 8),

                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    med.tabletsLeft += 10;
                                  });
                                },
                                child: const Text('Restock (+10)'),
                              ),

                              const Spacer(),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _medicines.remove(med);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMedicineDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
