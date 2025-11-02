import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'user_detail_screen.dart';

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({super.key});

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await adminProvider.loadAllUsers(authProvider.currentUser!.location);
    }
  }

  Future<void> _filterUsers(String filter) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    setState(() {
      _selectedFilter = filter;
      _searchController.clear();
    });

    if (authProvider.currentUser != null) {
      if (filter == 'all') {
        await adminProvider.loadAllUsers(authProvider.currentUser!.location);
      } else {
        await adminProvider.filterByStatus(
          authProvider.currentUser!.location,
          filter,
        );
      }
    }
  }

  void _searchUsers(String query) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      adminProvider.searchUsers(authProvider.currentUser!.location, query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final users = adminProvider.users;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Users',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalBlack,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.charcoalBlack),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: GoogleFonts.dmSans(
                  color: AppColors.charcoalBlack.withValues(alpha: 0.4),
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.brightBlue),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.coralRed),
                  onPressed: () {
                    _searchController.clear();
                    _loadUsers();
                  },
                )
                    : null,
                filled: true,
                fillColor: AppColors.lightBlue,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.brightBlue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', 'pending_review'),
                const SizedBox(width: 8),
                _buildFilterChip('Approved', 'approved'),
                const SizedBox(width: 8),
                _buildFilterChip('Rejected', 'rejected'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // User List
          Expanded(
            child: adminProvider.isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: AppColors.brightBlue,
              ),
            )
                : users.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 80,
                    color: AppColors.charcoalBlack.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      color: AppColors.charcoalBlack.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadUsers,
              color: AppColors.brightBlue,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _buildUserCard(user);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    Color chipColor;

    switch (value) {
      case 'pending_review':
        chipColor = AppColors.goldenYellow;
        break;
      case 'approved':
        chipColor = AppColors.brightBlue;
        break;
      case 'rejected':
        chipColor = AppColors.coralRed;
        break;
      default:
        chipColor = AppColors.charcoalBlack;
    }

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _filterUsers(value),
      labelStyle: GoogleFonts.dmSans(
        fontWeight: FontWeight.w600,
        color: isSelected ? AppColors.white : AppColors.charcoalBlack,
      ),
      backgroundColor: AppColors.lightBlue,
      selectedColor: chipColor,
      checkmarkColor: AppColors.white,
      side: BorderSide(
        color: isSelected ? chipColor : AppColors.charcoalBlack.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    Color statusColor;
    String statusLabel;

    switch (user.status) {
      case 'approved':
        statusColor = AppColors.brightBlue;
        statusLabel = 'APPROVED';
        break;
      case 'rejected':
        statusColor = AppColors.coralRed;
        statusLabel = 'REJECTED';
        break;
      case 'pending_review':
        statusColor = AppColors.goldenYellow;
        statusLabel = 'PENDING';
        break;
      default:
        statusColor = AppColors.charcoalBlack;
        statusLabel = 'PARTIAL';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserDetailScreen(user: user),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: statusColor.withValues(alpha: 0.15),
                child: Text(
                  user.fullName[0].toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoalBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.charcoalBlack.withValues(alpha: 0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 12,
                          color: AppColors.charcoalBlack.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.phone,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppColors.charcoalBlack.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: statusColor.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}