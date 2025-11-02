import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';

class UserStatisticsScreen extends StatefulWidget {
  const UserStatisticsScreen({super.key});

  @override
  State<UserStatisticsScreen> createState() => _UserStatisticsScreenState();
}

class _UserStatisticsScreenState extends State<UserStatisticsScreen> {
  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await adminProvider.loadStatistics(authProvider.currentUser!.location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final stats = adminProvider.statistics;

    final total = stats['total'] ?? 0;
    final pending = stats['pending'] ?? 0;
    final approved = stats['approved'] ?? 0;
    final rejected = stats['rejected'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Statistics',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalBlack,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.charcoalBlack),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: 'Refresh',
          ),
        ],
      ),
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        onRefresh: _loadStatistics,
        color: AppColors.brightBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Users Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.coralRed,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brightBlue.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.people,
                        size: 60,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      total.toString(),
                      style: GoogleFonts.dmSans(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Total Users',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Status Breakdown
              Text(
                'Status Breakdown',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalBlack,
                ),
              ),
              const SizedBox(height: 16),

              _buildStatCard(
                'Pending Review',
                pending,
                total,
                Icons.pending_actions,
                AppColors.goldenYellow,
              ),
              const SizedBox(height: 12),

              _buildStatCard(
                'Approved',
                approved,
                total,
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(height: 12),

              _buildStatCard(
                'Rejected',
                rejected,
                total,
                Icons.cancel,
                AppColors.coralRed,
              ),

              const SizedBox(height: 32),

              // Visual Representation
              Text(
                'Distribution',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalBlack,
                ),
              ),
              const SizedBox(height: 16),

              if (total > 0) _buildProgressBars(pending, approved, rejected, total),

              const SizedBox(height: 32),

              // Insights
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.brightBlue.withValues(alpha: 0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brightBlue.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.lightYellow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.lightbulb,
                            color: AppColors.goldenYellow,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Insights',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.charcoalBlack,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (pending > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Text(
                                'You have $pending user${pending > 1 ? 's' : ''} waiting for approval',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: AppColors.charcoalBlack,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (approved > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Text(
                                '${_calculatePercentage(approved, total)}% of users are approved',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: AppColors.charcoalBlack,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (rejected > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Text(
                                '${_calculatePercentage(rejected, total)}% of users were rejected',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: AppColors.charcoalBlack,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (total == 0)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: Text(
                              'No users registered yet',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: AppColors.charcoalBlack,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title,
      int count,
      int total,
      IconData icon,
      Color color,
      ) {
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      count.toString(),
                      style: GoogleFonts.dmSans(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '($percentage%)',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBars(int pending, int approved, int rejected, int total) {
    return Column(
      children: [
        _buildProgressBar('Pending', pending, total, AppColors.goldenYellow),
        const SizedBox(height: 12),
        _buildProgressBar('Approved', approved, total, Colors.green),
        const SizedBox(height: 12),
        _buildProgressBar('Rejected', rejected, total, AppColors.coralRed),
      ],
    );
  }

  Widget _buildProgressBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? count / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoalBlack,
                ),
              ),
              Text(
                '$count / $total',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  int _calculatePercentage(int count, int total) {
    if (total == 0) return 0;
    return ((count / total) * 100).round();
  }
}