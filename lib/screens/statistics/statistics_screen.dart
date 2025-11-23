import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/items_provider.dart';
import '../../providers/lists_provider.dart';
import '../../models/enums.dart';
import '../../utils/constants/colors.dart';
import '../../utils/theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final itemsProvider = context.read<ItemsProvider>();
    await itemsProvider.loadAllItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics & Insights'),
      ),
      body: Consumer2<ItemsProvider, ListsProvider>(
        builder: (context, itemsProvider, listsProvider, child) {
          if (itemsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = itemsProvider.items;
          if (items.isEmpty) {
            return const Center(
              child: Text('No items to analyze yet'),
            );
          }

          // Calculate statistics
          final totalItems = items.length;
          final totalLists = listsProvider.lists.length;
          final boughtItems = items.where((item) => 
              item.acquisitionType == AcquisitionType.bought).length;
          final giftItems = items.where((item) => 
              item.acquisitionType == AcquisitionType.gift).length;
          final totalValue = items
              .where((item) => item.value != null)
              .fold<double>(0, (sum, item) => sum + item.value!);
          final avgValue = boughtItems > 0 ? totalValue / boughtItems : 0.0;

          // Group by type
          final Map<String, int> itemsByType = {};
          for (var item in items) {
            itemsByType[item.type] = (itemsByType[item.type] ?? 0) + 1;
          }
          final sortedTypes = itemsByType.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // Group by year
          final Map<int, int> itemsByYear = {};
          for (var item in items) {
            itemsByYear[item.year] = (itemsByYear[item.year] ?? 0) + 1;
          }
          final sortedYears = itemsByYear.entries.toList()
            ..sort((a, b) => b.key.compareTo(a.key));

          // Most expensive items
          final expensiveItems = items
              .where((item) => item.value != null)
              .toList()
            ..sort((a, b) => (b.value ?? 0).compareTo(a.value ?? 0));

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              children: [
                // Overview Cards
                _buildOverviewSection(
                  totalItems,
                  totalLists,
                  boughtItems,
                  giftItems,
                  totalValue,
                  avgValue,
                ),
                const SizedBox(height: AppTheme.spacingXl),

                // Items by Type
                _buildSectionHeader('Items by Type'),
                const SizedBox(height: AppTheme.spacingM),
                _buildTypeBreakdown(sortedTypes, totalItems),
                const SizedBox(height: AppTheme.spacingXl),

                // Items by Year
                _buildSectionHeader('Items by Year'),
                const SizedBox(height: AppTheme.spacingM),
                _buildYearBreakdown(sortedYears, totalItems),
                const SizedBox(height: AppTheme.spacingXl),

                // Most Expensive Items
                if (expensiveItems.isNotEmpty) ...[
                  _buildSectionHeader('Most Expensive Items'),
                  const SizedBox(height: AppTheme.spacingM),
                  _buildExpensiveItems(expensiveItems.take(5).toList()),
                  const SizedBox(height: AppTheme.spacingXl),
                ],

                // Acquisition Breakdown
                _buildSectionHeader('Acquisition Breakdown'),
                const SizedBox(height: AppTheme.spacingM),
                _buildAcquisitionChart(boughtItems, giftItems),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewSection(
    int totalItems,
    int totalLists,
    int boughtItems,
    int giftItems,
    double totalValue,
    double avgValue,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Items',
                totalItems.toString(),
                Icons.inventory_2_outlined,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                'Total Lists',
                totalLists.toString(),
                Icons.folder_outlined,
                AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Bought',
                boughtItems.toString(),
                Icons.shopping_cart,
                AppColors.bought,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                'Gifts',
                giftItems.toString(),
                Icons.card_giftcard,
                AppColors.gift,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Value',
                NumberFormat.currency(symbol: '\$').format(totalValue),
                Icons.attach_money,
                AppColors.success,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                'Avg Value',
                NumberFormat.currency(symbol: '\$').format(avgValue),
                Icons.analytics_outlined,
                AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: Color.fromRGBO(color.red, color.green, color.blue, 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: AppTheme.iconL),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildTypeBreakdown(List<MapEntry<String, int>> types, int total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: types.take(10).map((entry) {
            final percentage = (entry.value / total * 100).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '${entry.value} ($percentage%)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: entry.value / total,
                    backgroundColor: AppColors.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildYearBreakdown(List<MapEntry<int, int>> years, int total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: years.take(10).map((entry) {
            final percentage = (entry.value / total * 100).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key.toString(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '${entry.value} ($percentage%)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: entry.value / total,
                    backgroundColor: AppColors.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildExpensiveItems(List<dynamic> items) {
    return Card(
      child: Column(
        children: items.map((item) {
          return ListTile(
            leading: const Icon(Icons.stars, color: AppColors.warning),
            title: Text(item.name),
            subtitle: Text(item.type),
            trailing: Text(
              NumberFormat.currency(symbol: '\$').format(item.value),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAcquisitionChart(int bought, int gifts) {
    final total = bought + gifts;
    final boughtPercentage = (bought / total * 100).toStringAsFixed(1);
    final giftPercentage = (gifts / total * 100).toStringAsFixed(1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: bought,
                  child: Container(
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.bought,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppTheme.radiusS),
                        bottomLeft: Radius.circular(AppTheme.radiusS),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$boughtPercentage%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: gifts,
                  child: Container(
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.gift,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(AppTheme.radiusS),
                        bottomRight: Radius.circular(AppTheme.radiusS),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$giftPercentage%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Bought', bought, AppColors.bought),
                _buildLegendItem('Gifts', gifts, AppColors.gift),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: AppTheme.spacingS),
        Text(
          '$label: $count',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
