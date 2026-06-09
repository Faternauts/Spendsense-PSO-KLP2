import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/data/models/goal_model.dart';

void main() {
  group('Goal Model Tests', () {
    late Goal testGoal;

    setUp(() {
      testGoal = Goal(
        id: 1,
        userId: 'user_123',
        name: 'Vacation Fund',
        targetAmount: 10000.0,
        savedAmount: 5000.0,
        deadline: DateTime.now().add(const Duration(days: 30)),
        icon: 'vacation',
        status: 'Active',
        createdAt: DateTime.now(),
      );
    });

    // ============ PROGRESS CALCULATION TESTS ============
    group('Progress Calculation', () {
      test('should calculate progress correctly with decimal values', () {
        final progress = testGoal.getProgress();
        expect(progress, closeTo(50.0, 0.01));
      });

      test('should return 0 when target amount is 0', () {
        final goal = testGoal.copyWith(targetAmount: 0);
        expect(goal.getProgress(), 0.0);
      });

      test('should return 0 when target amount is negative', () {
        final goal = testGoal.copyWith(targetAmount: -1000);
        expect(goal.getProgress(), 0.0);
      });

      test('should return 100 when saved amount equals target amount', () {
        final goal = testGoal.copyWith(
          savedAmount: 10000.0,
          targetAmount: 10000.0,
        );
        expect(goal.getProgress(), 100.0);
      });

      test('should cap progress at 100 when saved exceeds target', () {
        final goal = testGoal.copyWith(
          savedAmount: 15000.0,
          targetAmount: 10000.0,
        );
        expect(goal.getProgress(), 100.0);
      });

      test('should handle small decimal values correctly', () {
        final goal = testGoal.copyWith(
          savedAmount: 1.5,
          targetAmount: 10000.0,
        );
        final progress = goal.getProgress();
        expect(progress, closeTo(0.015, 0.0001));
      });

      test('should handle very large amounts', () {
        final goal = testGoal.copyWith(
          savedAmount: 500000000.0,
          targetAmount: 1000000000.0,
        );
        expect(goal.getProgress(), closeTo(50.0, 0.01));
      });
    });

    // ============ DAYS REMAINING TESTS ============
    group('Days Remaining Calculation', () {
      test('should return correct days remaining for future deadline', () {
        final futureDate = DateTime.now().add(const Duration(days: 10));
        final goal = testGoal.copyWith(deadline: futureDate);
        final daysRemaining = goal.getDaysRemaining();
        // Account for time elapsed during test execution
        expect(daysRemaining, greaterThanOrEqualTo(9));
        expect(daysRemaining, lessThanOrEqualTo(10));
      });

      test('should return 0 when deadline has passed', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 5));
        final goal = testGoal.copyWith(deadline: pastDate);
        expect(goal.getDaysRemaining(), 0);
      });

      test('should return 0 for today deadline', () {
        final today = DateTime.now();
        final goal = testGoal.copyWith(deadline: today);
        expect(goal.getDaysRemaining(), 0);
      });

      test('should return positive value for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final goal = testGoal.copyWith(deadline: tomorrow);
        final daysRemaining = goal.getDaysRemaining();
        expect(daysRemaining, greaterThanOrEqualTo(0));
        expect(daysRemaining, lessThanOrEqualTo(1));
      });

      test('should ignore time component and use date only', () {
        final tomorrow = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day + 1,
          23,
          59,
          59,
        );
        final goal = testGoal.copyWith(deadline: tomorrow);
        final daysRemaining = goal.getDaysRemaining();
        expect(daysRemaining, greaterThanOrEqualTo(0));
        expect(daysRemaining, lessThanOrEqualTo(1));
      });
    });

    // ============ OVERDUE STATUS TESTS ============
    group('Overdue Status', () {
      test('should return true when deadline has passed and status is Active', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        final goal = testGoal.copyWith(deadline: pastDate, status: 'Active');
        expect(goal.isOverdue(), true);
      });

      test('should return false when goal is completed even if overdue', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        final goal = testGoal.copyWith(deadline: pastDate, status: 'Completed');
        expect(goal.isOverdue(), false);
      });

      test('should return false when deadline is in the future', () {
        final futureDate = DateTime.now().add(const Duration(days: 5));
        final goal = testGoal.copyWith(deadline: futureDate, status: 'Active');
        expect(goal.isOverdue(), false);
      });

      test('should return false when deadline is today', () {
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          23,
          59,
          59,
        );
        final goal = testGoal.copyWith(deadline: today, status: 'Active');
        expect(goal.isOverdue(), false);
      });
    });

    // ============ COMPLETION STATUS TESTS ============
    group('Completion Status', () {
      test('should return true when saved amount equals target', () {
        final goal = testGoal.copyWith(
          savedAmount: 10000.0,
          targetAmount: 10000.0,
        );
        expect(goal.isCompleted(), true);
      });

      test('should return true when saved amount exceeds target', () {
        final goal = testGoal.copyWith(
          savedAmount: 15000.0,
          targetAmount: 10000.0,
        );
        expect(goal.isCompleted(), true);
      });

      test('should return false when saved amount is less than target', () {
        final goal = testGoal.copyWith(
          savedAmount: 5000.0,
          targetAmount: 10000.0,
        );
        expect(goal.isCompleted(), false);
      });

      test('should return false when saved amount is 0', () {
        final goal = testGoal.copyWith(
          savedAmount: 0,
          targetAmount: 10000.0,
        );
        expect(goal.isCompleted(), false);
      });

      test('should handle decimal values correctly', () {
        final goal = testGoal.copyWith(
          savedAmount: 9999.99,
          targetAmount: 10000.0,
        );
        expect(goal.isCompleted(), false);

        final goal2 = testGoal.copyWith(
          savedAmount: 10000.01,
          targetAmount: 10000.0,
        );
        expect(goal2.isCompleted(), true);
      });
    });

    // ============ INPUT VALIDATION TESTS ============
    group('Input Validation', () {
      test('should handle negative target amount in progress calculation', () {
        final goal = testGoal.copyWith(targetAmount: -5000.0);
        expect(goal.getProgress(), 0.0);
      });

      test('should handle zero target amount in progress calculation', () {
        final goal = testGoal.copyWith(targetAmount: 0);
        expect(goal.getProgress(), 0.0);
      });

      test('should handle negative saved amount correctly', () {
        final goal = testGoal.copyWith(
          savedAmount: -1000.0,
          targetAmount: 10000.0,
        );
        final progress = goal.getProgress();
        expect(progress, closeTo(-10.0, 0.01));
      });

      test('should handle past deadline in days remaining', () {
        final farPastDate = DateTime.now().subtract(const Duration(days: 365));
        final goal = testGoal.copyWith(deadline: farPastDate);
        expect(goal.getDaysRemaining(), 0);
      });

      test('should handle very far future deadline', () {
        final farFutureDate = DateTime.now().add(const Duration(days: 36500));
        final goal = testGoal.copyWith(deadline: farFutureDate);
        final daysRemaining = goal.getDaysRemaining();
        expect(daysRemaining, greaterThan(36000));
      });
    });

    // ============ COPYWITH METHOD TESTS ============
    group('CopyWith Method', () {
      test('should create copy with modified name', () {
        final newGoal = testGoal.copyWith(name: 'New Vacation');
        expect(newGoal.name, 'New Vacation');
        expect(newGoal.savedAmount, testGoal.savedAmount);
      });

      test('should create copy with modified saved amount', () {
        final newGoal = testGoal.copyWith(savedAmount: 7000.0);
        expect(newGoal.savedAmount, 7000.0);
        expect(newGoal.name, testGoal.name);
      });

      test('should create copy with modified status', () {
        final newGoal = testGoal.copyWith(status: 'Completed');
        expect(newGoal.status, 'Completed');
        expect(newGoal.id, testGoal.id);
      });

      test('should preserve unmodified fields', () {
        final newGoal = testGoal.copyWith(name: 'Updated Name');
        expect(newGoal.id, testGoal.id);
        expect(newGoal.userId, testGoal.userId);
        expect(newGoal.targetAmount, testGoal.targetAmount);
        expect(newGoal.icon, testGoal.icon);
        expect(newGoal.createdAt, testGoal.createdAt);
      });
    });

    // ============ JSON SERIALIZATION TESTS ============
    group('JSON Serialization', () {
      test('should convert Goal to JSON correctly', () {
        final json = testGoal.toJson();
        expect(json['id'], testGoal.id);
        expect(json['user_id'], testGoal.userId);
        expect(json['name'], testGoal.name);
        expect(json['target_amount'], testGoal.targetAmount);
        expect(json['saved_amount'], testGoal.savedAmount);
        expect(json['icon'], testGoal.icon);
        expect(json['status'], testGoal.status);
      });

      test('should create Goal from JSON correctly', () {
        final json = {
          'id': 1,
          'user_id': 'user_123',
          'name': 'Test Goal',
          'target_amount': 5000.0,
          'saved_amount': 2000.0,
          'deadline': DateTime.now().toIso8601String(),
          'icon': 'vacation',
          'status': 'Active',
          'created_at': DateTime.now().toIso8601String(),
        };

        final goal = Goal.fromJson(json);
        expect(goal.name, 'Test Goal');
        expect(goal.targetAmount, 5000.0);
        expect(goal.savedAmount, 2000.0);
        expect(goal.icon, 'vacation');
      });

      test('should handle missing optional fields in JSON', () {
        final json = {
          'id': 1,
          'user_id': 'user_123',
          'name': 'Test Goal',
          'target_amount': 5000.0,
          'deadline': DateTime.now().toIso8601String(),
          'icon': 'vacation',
          'created_at': DateTime.now().toIso8601String(),
        };

        final goal = Goal.fromJson(json);
        expect(goal.savedAmount, 0.0);
        expect(goal.status, 'Active');
      });
    });

    // ============ EDGE CASES TESTS ============
    group('Edge Cases', () {
      test('should handle very large decimal progress values', () {
        final goal = testGoal.copyWith(
          savedAmount: 1.111111111,
          targetAmount: 100.0,
        );
        final progress = goal.getProgress();
        expect(progress, greaterThan(0.0));
        expect(progress, lessThan(100.0));
      });

      test('should handle zero saved amount', () {
        final goal = testGoal.copyWith(savedAmount: 0.0);
        expect(goal.getProgress(), 0.0);
        expect(goal.isCompleted(), false);
      });

      test('should maintain precision with financial calculations', () {
        final goal = testGoal.copyWith(
          savedAmount: 33.33,
          targetAmount: 100.0,
        );
        final progress = goal.getProgress();
        expect(progress, closeTo(33.33, 0.01));
      });

      test('should handle status with mixed case', () {
        final goal = testGoal.copyWith(status: 'ACTIVE');
        expect(goal.status, 'ACTIVE');
      });
    });
  });
}
