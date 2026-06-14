import 'package:flutter/material.dart';
import '../../data/models/goal_model.dart';
import '../../data/services/supabase_service.dart';
import '../../utils/constants.dart';
import '../widgets/goal_card.dart';
import 'add_goal_page.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final SupabaseService _supabase = SupabaseService.instance;
  List<Goal> _goals = [];
  bool _isLoading = true;
  String _filterStatus = 'All'; // All, Active, Completed, Overdue

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      setState(() => _isLoading = true);
      final goals = await _supabase.getGoals();
      setState(() {
        _goals = goals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading goals: $e')),
        );
      }
    }
  }

  Future<void> _deleteGoal(Goal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (goal.id != null) {
        await _supabase.deleteGoal(goal.id!);
        await _loadGoals();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Goal deleted successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting goal: $e')),
        );
      }
    }
  }

  Future<void> _addOrEditGoal({Goal? goal}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddGoalPage(goal: goal),
      ),
    );

    if (result == true) {
      await _loadGoals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              goal == null ? 'Goal created successfully' : 'Goal updated successfully',
            ),
          ),
        );
      }
    }
  }

  List<Goal> _getFilteredGoals() {
    if (_filterStatus == 'All') {
      return _goals;
    }
    return _goals.where((goal) => goal.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.text;
    final filteredGoals = _getFilteredGoals();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Farrel cinta mati ama auliya malika idi',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset('img/logo.png', height: 32),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterButton('All'),
                        const SizedBox(width: 8),
                        _buildFilterButton('Active'),
                        const SizedBox(width: 8),
                        _buildFilterButton('Completed'),
                        const SizedBox(width: 8),
                        _buildFilterButton('Overdue'),
                      ],
                    ),
                  ),
                ),

                // Goals List or Empty State
                Expanded(
                  child: filteredGoals.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredGoals.length,
                          itemBuilder: (context, index) {
                            final goal = filteredGoals[index];
                            return GoalCard(
                              goal: goal,
                              onTap: () {
                                // Could add goal detail page here
                              },
                              onEdit: () => _addOrEditGoal(goal: goal),
                              onDelete: () => _deleteGoal(goal),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditGoal(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterButton(String status) {
    final isSelected = _filterStatus == status;

    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : AppColors.text;
    final secondaryTextColor = isDarkMode ? Colors.white70 : AppColors.textSecondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: secondaryTextColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No goals yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first goal to start saving!',
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
