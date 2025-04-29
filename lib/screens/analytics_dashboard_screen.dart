import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/design_system.dart';
import '../widgets/platform_aware_widgets.dart';
import '../models/personnel_model.dart';
import '../providers/personnel_provider.dart';
import 'package:provider/provider.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = 'Month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Personnel'),
            Tab(text: 'Verification'),
          ],
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedTimeRange,
            items: ['Day', 'Week', 'Month', 'Year']
                .map((String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
                .toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedTimeRange = newValue;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportAnalytics(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPersonnelTab(),
          _buildVerificationTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildActivityChart(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildSummaryCard(
          'Total Personnel',
          '12,458',
          Icons.people,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Verifications Today',
          '234',
          Icons.verified_user,
          Colors.green,
        ),
        _buildSummaryCard(
          'Active Devices',
          '45',
          Icons.devices,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Pending Actions',
          '12',
          Icons.pending_actions,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 3),
                FlSpot(2.6, 2),
                FlSpot(4.9, 5),
                FlSpot(6.8, 3.1),
                FlSpot(8, 4),
                FlSpot(9.5, 3),
                FlSpot(11, 4),
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text('Activity ${index + 1}'),
              subtitle: Text('Description of activity ${index + 1}'),
              trailing: Text('${index + 1}h ago'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPersonnelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildPersonnelDistributionChart(),
          const SizedBox(height: 24),
          _buildPersonnelStatusTable(),
        ],
      ),
    );
  }

  Widget _buildPersonnelDistributionChart() {
    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: 40,
              title: 'Officers',
              color: Colors.blue,
            ),
            PieChartSectionData(
              value: 60,
              title: 'Soldiers',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonnelStatusTable() {
    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Count')),
          DataColumn(label: Text('Percentage')),
        ],
        rows: [
          DataRow(cells: [
            const DataCell(Text('Active')),
            const DataCell(Text('10,234')),
            const DataCell(Text('82%')),
          ]),
          DataRow(cells: [
            const DataCell(Text('On Leave')),
            const DataCell(Text('1,123')),
            const DataCell(Text('9%')),
          ]),
          DataRow(cells: [
            const DataCell(Text('Retired')),
            const DataCell(Text('1,101')),
            const DataCell(Text('9%')),
          ]),
        ],
      ),
    );
  }

  Widget _buildVerificationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildVerificationMetrics(),
          const SizedBox(height: 24),
          _buildVerificationTrends(),
        ],
      ),
    );
  }

  Widget _buildVerificationMetrics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verification Metrics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem('Success Rate', '98.5%', Colors.green),
                _buildMetricItem('Avg. Time', '2.3s', Colors.blue),
                _buildMetricItem('Failed', '1.5%', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildVerificationTrends() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verification Trends',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 20,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: 8, color: Colors.blue),
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: 12, color: Colors.blue),
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(toY: 15, color: Colors.blue),
                    ]),
                    BarChartGroupData(x: 3, barRods: [
                      BarChartRodData(toY: 10, color: Colors.blue),
                    ]),
                    BarChartGroupData(x: 4, barRods: [
                      BarChartRodData(toY: 18, color: Colors.blue),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportAnalytics() {
    // Implement analytics export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting analytics data...'),
      ),
    );
  }
}