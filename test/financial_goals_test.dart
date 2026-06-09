import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/data/models/goal_model.dart';

void main() {
  group('Financial Goals - Complete Test Suite', () {
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

    // ============ SUNNY DAY TESTS (POSITIVE SCENARIOS) ============
    group('Sunny Day Tests - Happy Path', () {
      group('✅ Progress Calculation - Valid Scenarios', () {
        test('✅ should calculate 50% progress for half-saved goal', () {
          final goal = testGoal.copyWith(
            savedAmount: 5000.0,
            targetAmount: 10000.0,
          );
          expect(goal.getProgress(), closeTo(50.0, 0.01));
        });

        test('✅ should calculate 100% progress when goal is fully saved', () {
          final goal = testGoal.copyWith(
            savedAmount: 10000.0,
            targetAmount: 10000.0,
          );
          expect(goal.getProgress(), 100.0);
        });

        test('✅ should calculate 0% progress for new goal', () {
          final goal = testGoal.copyWith(
            savedAmount: 0.0,
            targetAmount: 5000.0,
          );
          expect(goal.getProgress(), 0.0);
        });

        test('✅ should handle decimal progress values correctly', () {
          final goal = testGoal.copyWith(
            savedAmount: 33.33,
            targetAmount: 100.0,
          );
          final progress = goal.getProgress();
          expect(progress, closeTo(33.33, 0.01));
        });

        test('✅ should handle large monetary amounts', () {
          final goal = testGoal.copyWith(
            savedAmount: 500000000.0,
            targetAmount: 1000000000.0,
          );
          expect(goal.getProgress(), closeTo(50.0, 0.01));
        });

        test('✅ should handle small decimal values', () {
          final goal = testGoal.copyWith(
            savedAmount: 1.5,
            targetAmount: 10000.0,
          );
          final progress = goal.getProgress();
          expect(progress, closeTo(0.015, 0.0001));
        });
      });

      group('✅ Days Remaining - Valid Scenarios', () {
        test('✅ should return correct days for 10-day deadline', () {
          final futureDate = DateTime.now().add(const Duration(days: 10));
          final goal = testGoal.copyWith(deadline: futureDate);
          final daysRemaining = goal.getDaysRemaining();
          expect(daysRemaining, greaterThanOrEqualTo(9));
          expect(daysRemaining, lessThanOrEqualTo(10));
        });

        test('✅ should return 0 for today deadline', () {
          final today = DateTime.now();
          final goal = testGoal.copyWith(deadline: today);
          expect(goal.getDaysRemaining(), 0);
        });

        test('✅ should return positive value for tomorrow', () {
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          final goal = testGoal.copyWith(deadline: tomorrow);
          final daysRemaining = goal.getDaysRemaining();
          expect(daysRemaining, greaterThanOrEqualTo(0));
          expect(daysRemaining, lessThanOrEqualTo(1));
        });

        test('✅ should ignore time and use date only', () {
          final tomorrow = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 1,
            23,
            59,
            59,
          );
          final goal = testGoal.copyWith(deadline: tomorrow);
          expect(goal.getDaysRemaining(), greaterThanOrEqualTo(0));
        });

        test('✅ should handle 365-day deadline', () {
          final farFuture = DateTime.now().add(const Duration(days: 365));
          final goal = testGoal.copyWith(deadline: farFuture);
          expect(goal.getDaysRemaining(), greaterThan(360));
        });
      });

      group('✅ Status Management - Valid Scenarios', () {
        test('✅ should NOT be overdue when deadline is future', () {
          final futureDate = DateTime.now().add(const Duration(days: 5));
          final goal = testGoal.copyWith(
            deadline: futureDate,
            status: 'Active',
          );
          expect(goal.isOverdue(), false);
        });

        test('✅ should be completed when saved >= target', () {
          final goal = testGoal.copyWith(
            savedAmount: 10000.0,
            targetAmount: 10000.0,
          );
          expect(goal.isCompleted(), true);
        });

        test('✅ should be completed when saved > target', () {
          final goal = testGoal.copyWith(
            savedAmount: 15000.0,
            targetAmount: 10000.0,
          );
          expect(goal.isCompleted(), true);
        });

        test('✅ should NOT be completed when saved < target', () {
          final goal = testGoal.copyWith(
            savedAmount: 5000.0,
            targetAmount: 10000.0,
          );
          expect(goal.isCompleted(), false);
        });
      });

      group('✅ CopyWith Method - Valid Operations', () {
        test('✅ should create copy with modified name', () {
          final newGoal = testGoal.copyWith(name: 'New Vacation');
          expect(newGoal.name, 'New Vacation');
          expect(newGoal.id, testGoal.id);
          expect(newGoal.savedAmount, testGoal.savedAmount);
        });

        test('✅ should create copy with modified saved amount', () {
          final newGoal = testGoal.copyWith(savedAmount: 7000.0);
          expect(newGoal.savedAmount, 7000.0);
          expect(newGoal.targetAmount, testGoal.targetAmount);
        });

        test('✅ should create copy with multiple modifications', () {
          final newDeadline = DateTime.now().add(const Duration(days: 60));
          final newGoal = testGoal.copyWith(
            name: 'Updated Goal',
            savedAmount: 8000.0,
            deadline: newDeadline,
            status: 'Active',
          );
          expect(newGoal.name, 'Updated Goal');
          expect(newGoal.savedAmount, 8000.0);
          expect(newGoal.status, 'Active');
          expect(newGoal.id, testGoal.id); // Unchanged
        });
      });

      group('✅ JSON Serialization - Valid Operations', () {
        test('✅ should convert Goal to JSON correctly', () {
          final json = testGoal.toJson();
          expect(json['id'], testGoal.id);
          expect(json['user_id'], testGoal.userId);
          expect(json['name'], testGoal.name);
          expect(json['target_amount'], testGoal.targetAmount);
          expect(json['saved_amount'], testGoal.savedAmount);
          expect(json['icon'], testGoal.icon);
          expect(json['status'], testGoal.status);
        });

        test('✅ should create Goal from complete JSON', () {
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

        test('✅ should handle UUID user_id in fromJson', () {
          final uuid = '550e8400-e29b-41d4-a716-446655440000';
          final json = {
            'id': 1,
            'user_id': uuid,
            'name': 'Test Goal',
            'target_amount': 5000.0,
            'deadline': DateTime.now().toIso8601String(),
            'icon': 'savings',
            'created_at': DateTime.now().toIso8601String(),
          };

          final goal = Goal.fromJson(json);
          expect(goal.userId, uuid);
        });
      });
    });

    // ============ RAINY DAY TESTS (NEGATIVE SCENARIOS) ============
    group('Rainy Day Tests - Edge Cases & Error Handling', () {
      group('❌ Progress Calculation - Invalid Scenarios', () {
        test('❌ should return 0 when target amount is 0', () {
          final goal = testGoal.copyWith(targetAmount: 0);
          expect(goal.getProgress(), 0.0);
        });

        test('❌ should return 0 when target amount is negative', () {
          final goal = testGoal.copyWith(targetAmount: -1000);
          expect(goal.getProgress(), 0.0);
        });

        test('❌ should cap progress at 100 when exceeding target', () {
          final goal = testGoal.copyWith(
            savedAmount: 20000.0,
            targetAmount: 10000.0,
          );
          expect(goal.getProgress(), 100.0);
        });

        test('❌ should handle negative saved amount', () {
          final goal = testGoal.copyWith(
            savedAmount: -1000.0,
            targetAmount: 10000.0,
          );
          final progress = goal.getProgress();
          expect(progress, closeTo(-10.0, 0.01));
        });

        test('❌ should handle both negative amounts', () {
          final goal = testGoal.copyWith(
            savedAmount: -5000.0,
            targetAmount: -10000.0,
          );
          expect(goal.getProgress(), 0.0); // Both invalid
        });

        test('❌ should maintain precision with very small saved amount', () {
          final goal = testGoal.copyWith(
            savedAmount: 0.01,
            targetAmount: 10000.0,
          );
          final progress = goal.getProgress();
          expect(progress, greaterThan(0.0));
          expect(progress, lessThan(1.0));
        });
      });

      group('❌ Days Remaining - Invalid Scenarios', () {
        test('❌ should return 0 when deadline has passed', () {
          final pastDate = DateTime.now().subtract(const Duration(days: 5));
          final goal = testGoal.copyWith(deadline: pastDate);
          expect(goal.getDaysRemaining(), 0);
        });

        test('❌ should return 0 for far past deadline', () {
          final farPast = DateTime.now().subtract(const Duration(days: 365));
          final goal = testGoal.copyWith(deadline: farPast);
          expect(goal.getDaysRemaining(), 0);
        });

        test('❌ should return 0 when deadline is yesterday', () {
          final yesterday = DateTime.now().subtract(const Duration(days: 1));
          final goal = testGoal.copyWith(deadline: yesterday);
          expect(goal.getDaysRemaining(), 0);
        });

        test('❌ should not return negative values', () {
          final pastDate = DateTime.now().subtract(const Duration(days: 100));
          final goal = testGoal.copyWith(deadline: pastDate);
          expect(goal.getDaysRemaining(), greaterThanOrEqualTo(0));
        });
      });

      group('❌ Status Management - Invalid Scenarios', () {
        test('❌ should be overdue when past deadline and active', () {
          final pastDate = DateTime.now().subtract(const Duration(days: 1));
          final goal = testGoal.copyWith(
            deadline: pastDate,
            status: 'Active',
          );
          expect(goal.isOverdue(), true);
        });

        test('❌ should NOT be overdue when already completed despite past deadline', () {
          final pastDate = DateTime.now().subtract(const Duration(days: 1));
          final goal = testGoal.copyWith(
            deadline: pastDate,
            status: 'Completed',
          );
          expect(goal.isOverdue(), false);
        });

        test('❌ should NOT be completed when no progress made', () {
          final goal = testGoal.copyWith(
            savedAmount: 0.0,
            targetAmount: 10000.0,
          );
          expect(goal.isCompleted(), false);
        });

        test('❌ should NOT be completed when almost at target', () {
          final goal = testGoal.copyWith(
            savedAmount: 9999.99,
            targetAmount: 10000.0,
          );
          expect(goal.isCompleted(), false);
        });
      });

      group('❌ Input Validation - Constraint Testing', () {
        test('❌ should handle zero target and zero saved', () {
          final goal = testGoal.copyWith(
            savedAmount: 0.0,
            targetAmount: 0.0,
          );
          expect(goal.getProgress(), 0.0);
        });

        test('❌ should handle very large numbers', () {
          final goal = testGoal.copyWith(
            savedAmount: 999999999999.99,
            targetAmount: 999999999999.99,
          );
          expect(goal.isCompleted(), true);
        });

        test('❌ should handle precision loss gracefully', () {
          final goal = testGoal.copyWith(
            savedAmount: 0.1 + 0.2, // Classic floating point issue
            targetAmount: 0.3,
          );
          // Should still be close to completed
          expect(goal.getProgress(), greaterThan(99.0));
        });

        test('❌ should handle empty/null-like strings for userId', () {
          final goal = testGoal.copyWith(userId: '');
          expect(goal.userId, '');
        });
      });

      group('❌ JSON Serialization - Missing Data', () {
        test('❌ should handle missing optional saved_amount field', () {
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
          expect(goal.savedAmount, 0.0); // Default value
        });

        test('❌ should handle missing status field', () {
          final json = {
            'id': 1,
            'user_id': 'user_123',
            'name': 'Test Goal',
            'target_amount': 5000.0,
            'saved_amount': 0.0,
            'deadline': DateTime.now().toIso8601String(),
            'icon': 'vacation',
            'created_at': DateTime.now().toIso8601String(),
          };

          final goal = Goal.fromJson(json);
          expect(goal.status, 'Active'); // Default value
        });

        test('❌ should handle null id (new goal)', () {
          final goal = Goal(
            id: null,
            userId: 'user_123',
            name: 'New Goal',
            targetAmount: 5000.0,
            deadline: DateTime.now().add(const Duration(days: 30)),
            icon: 'savings',
            createdAt: DateTime.now(),
          );

          expect(goal.id, isNull);
          final json = goal.toJson();
          expect(json.containsKey('id'), false); // Not included when null
        });
      });

      group('❌ Boundary Conditions', () {
        test('❌ should handle minimum valid amount (0.01)', () {
          final goal = testGoal.copyWith(
            savedAmount: 0.01,
            targetAmount: 0.01,
          );
          expect(goal.isCompleted(), true);
        });

        test('❌ should handle maximum typical amounts', () {
          final goal = testGoal.copyWith(
            savedAmount: 1000000.0,
            targetAmount: 1000000.0,
          );
          expect(goal.getProgress(), 100.0);
        });

        test('❌ should handle 1-day deadline', () {
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          final goal = testGoal.copyWith(deadline: tomorrow);
          final daysRemaining = goal.getDaysRemaining();
          // Flaky test - depends on time of execution
          // Should be 0 or 1 depending on exact time
          expect(daysRemaining, isIn([0, 1]));
        });

        test('❌ should handle exact same datetime for deadline check', () {
          final now = DateTime.now();
          final goal = testGoal.copyWith(deadline: now);
          expect(goal.getDaysRemaining(), 0);
        });
      });

      group('❌ State Inconsistencies', () {
        test('❌ should handle completed goal with deadline passed', () {
          final pastDate = DateTime.now().subtract(const Duration(days: 30));
          final goal = testGoal.copyWith(
            deadline: pastDate,
            status: 'Completed',
            savedAmount: 10000.0,
            targetAmount: 10000.0,
          );

          expect(goal.isCompleted(), true);
          expect(goal.isOverdue(), false); // Completed takes precedence
          expect(goal.getDaysRemaining(), 0);
        });

        test('❌ should handle overdue goal that is not yet completed', () {
          final pastDate = DateTime.now().subtract(const Duration(days: 1));
          final goal = testGoal.copyWith(
            deadline: pastDate,
            status: 'Active',
            savedAmount: 5000.0,
            targetAmount: 10000.0,
          );

          expect(goal.isCompleted(), false);
          expect(goal.isOverdue(), true);
          expect(goal.getDaysRemaining(), 0);
        });

        test('❌ should handle goal near completion', () {
          final goal = testGoal.copyWith(
            savedAmount: 9999.0,
            targetAmount: 10000.0,
          );

          expect(goal.isCompleted(), false);
          expect(goal.getProgress(), closeTo(99.99, 0.01));
        });
      });
    });
  });
}
