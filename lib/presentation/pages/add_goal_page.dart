import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/goal_model.dart';
import '../../data/services/supabase_service.dart';
import '../../utils/constants.dart';

class AddGoalPage extends StatefulWidget {
  final Goal? goal; // null for add, non-null for edit

  const AddGoalPage({super.key, this.goal});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _savedAmountController = TextEditingController();
  final SupabaseService _supabase = SupabaseService.instance;

  late DateTime _selectedDeadline;
  String _selectedIcon = 'savings';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _iconOptions = [
    {'label': 'Home', 'value': 'home', 'icon': Icons.home},
    {'label': 'Car', 'value': 'car', 'icon': Icons.directions_car},
    {'label': 'Vacation', 'value': 'vacation', 'icon': Icons.flight},
    {'label': 'Education', 'value': 'education', 'icon': Icons.school},
    {'label': 'Health', 'value': 'health', 'icon': Icons.health_and_safety},
    {'label': 'Wedding', 'value': 'wedding', 'icon': Icons.favorite},
    {'label': 'Electronics', 'value': 'electronics', 'icon': Icons.devices},
    {'label': 'Savings', 'value': 'savings', 'icon': Icons.savings},
    {'label': 'Other', 'value': 'other', 'icon': Icons.monetization_on},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDeadline = DateTime.now().add(const Duration(days: 30));

    if (widget.goal != null) {
      _nameController.text = widget.goal!.name;
      _amountController.text = widget.goal!.targetAmount.toString();
      _savedAmountController.text = widget.goal!.savedAmount.toString();
      _selectedDeadline = widget.goal!.deadline;
      _selectedIcon = widget.goal!.icon;
    } else {
      _savedAmountController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _savedAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDeadline = pickedDate;
      });
    }
  }

  Future<void> _saveGoal() async {
    // Validation
    if (_nameController.text.isEmpty) {
      _showErrorSnackBar('Please enter goal name');
      return;
    }

    if (_amountController.text.isEmpty || _amountController.text == '0') {
      _showErrorSnackBar('Target amount must be greater than 0');
      return;
    }

    try {
      final targetAmount = double.parse(_amountController.text);
      final savedAmount = double.parse(_savedAmountController.text);

      if (targetAmount <= 0) {
        _showErrorSnackBar('Target amount must be greater than 0');
        return;
      }

      if (savedAmount < 0) {
        _showErrorSnackBar('Saved amount cannot be negative');
        return;
      }

      final now = DateTime.now();
      final deadline = DateTime(_selectedDeadline.year, _selectedDeadline.month, _selectedDeadline.day);
      if (deadline.isBefore(now)) {
        _showErrorSnackBar('Deadline cannot be in the past');
        return;
      }

      setState(() => _isLoading = true);

      if (widget.goal == null) {
        // Add new goal
        final newGoal = Goal(
          userId: _supabase.user?.id ?? '',
          name: _nameController.text,
          targetAmount: targetAmount,
          savedAmount: savedAmount,
          deadline: _selectedDeadline,
          icon: _selectedIcon,
          status: 'Active',
          createdAt: DateTime.now(),
        );

        await _supabase.saveGoal(newGoal);
      } else {
        // Edit existing goal
        final updatedGoal = widget.goal!.copyWith(
          name: _nameController.text,
          targetAmount: targetAmount,
          savedAmount: savedAmount,
          deadline: _selectedDeadline,
          icon: _selectedIcon,
        );

        await _supabase.updateGoal(updatedGoal);
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.text;
    final secondaryTextColor = isDarkMode ? Colors.white70 : AppColors.textSecondary;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : AppColors.surfaceVariant;

    final isEditMode = widget.goal != null;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          isEditMode ? 'Edit Goal' : 'Add Goal',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Selection
            Text(
              'Goal Icon',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _iconOptions.length,
                itemBuilder: (context, index) {
                  final option = _iconOptions[index];
                  final isSelected = _selectedIcon == option['value'];

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedIcon = option['value']);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : secondaryTextColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        option['icon'],
                        color: isSelected ? Colors.white : secondaryTextColor,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Goal Name
            _buildFormField(
              label: 'Goal Name',
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Save for vacation',
                  hintStyle: TextStyle(color: secondaryTextColor, fontSize: 16),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
              ),
            ),

            // Target Amount
            _buildFormField(
              label: 'Target Amount',
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Rp 0',
                  hintStyle: TextStyle(color: secondaryTextColor, fontSize: 16),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
              ),
            ),

            // Saved Amount
            _buildFormField(
              label: 'Already Saved',
              child: TextField(
                controller: _savedAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Rp 0',
                  hintStyle: TextStyle(color: secondaryTextColor, fontSize: 16),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
              ),
            ),

            // Deadline
            _buildFormField(
              label: 'Deadline',
              child: GestureDetector(
                onTap: _selectDate,
                child: Text(
                  _getFormattedDate(_selectedDeadline),
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(
                        isEditMode ? 'Update Goal' : 'Create Goal',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required Widget child,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : AppColors.text;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : AppColors.surfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
