class Goal {
  final int? id;
  final String userId;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime deadline;
  final String icon;
  final String status; // 'Active', 'Completed', 'Overdue'
  final DateTime createdAt;

  Goal({
    this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0.0,
    required this.deadline,
    required this.icon,
    this.status = 'Active',
    required this.createdAt,
  });

  // Calculate progress percentage
  double getProgress() {
    if (targetAmount <= 0) return 0.0;
    final progress = (savedAmount / targetAmount) * 100;
    return progress > 100 ? 100.0 : progress;
  }

  // Calculate days remaining
  int getDaysRemaining() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);

    if (today.isAfter(deadlineDay)) {
      return 0;
    }

    final difference = deadlineDay.difference(today);
    return difference.inDays;
  }

  // Check if goal should be marked as overdue
  bool isOverdue() {
    final now = DateTime.now();
    return now.isAfter(deadline) && status != 'Completed';
  }

  // Check if goal should be marked as completed
  bool isCompleted() {
    return savedAmount >= targetAmount;
  }

  // Copy with method for creating modified copies
  Goal copyWith({
    int? id,
    String? userId,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? deadline,
    String? icon,
    String? status,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      deadline: deadline ?? this.deadline,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert Goal to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      'target_amount': targetAmount,
      'saved_amount': savedAmount,
      'deadline': deadline.toIso8601String(),
      'icon': icon,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create Goal from JSON (from Supabase)
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as int?,
      userId: (json['user_id'] as dynamic).toString(), // Handle UUID from Supabase
      name: json['name'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      savedAmount: (json['saved_amount'] as num?)?.toDouble() ?? 0.0,
      deadline: json['deadline'] is String 
          ? DateTime.parse(json['deadline'] as String)
          : json['deadline'] as DateTime,
      icon: json['icon'] as String,
      status: json['status'] as String? ?? 'Active',
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'] as String)
          : json['created_at'] as DateTime,
    );
  }
}
