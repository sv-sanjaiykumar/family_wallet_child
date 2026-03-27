import 'package:flutter/material.dart';
import 'child_data.dart';

// ── Enums ──────────────────────────────────────────────────────
enum NotificationType { spent, choreCompleted, limitExceeded, moneyAdded }

enum ChoreApprovalStatus { pending, completed, approved, rejected }

// ── Extended Chore for Parent ──────────────────────────────────
class ParentChore {
  final String id;
  final String title;
  final String description;
  final double reward;
  ChoreApprovalStatus approvalStatus;
  final IconData icon;
  final Color iconColor;

  ParentChore({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.approvalStatus,
    required this.icon,
    required this.iconColor,
  });

  /// Build from a child-side Chore
  factory ParentChore.fromChore(Chore chore) {
    ChoreApprovalStatus status;
    if (chore.status == ChoreStatus.completed) {
      status = ChoreApprovalStatus.completed;
    } else {
      status = ChoreApprovalStatus.pending;
    }
    return ParentChore(
      id: chore.id,
      title: chore.title,
      description: chore.description,
      reward: chore.reward,
      approvalStatus: status,
      icon: chore.icon,
      iconColor: chore.iconColor,
    );
  }
}

// ── Models ─────────────────────────────────────────────────────

class ParentProfile {
  final String name;
  final String avatarEmoji;
  double totalMoneySent;

  ParentProfile({
    required this.name,
    required this.avatarEmoji,
    required this.totalMoneySent,
  });
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final NotificationType type;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.spent:
        return Icons.shopping_bag_rounded;
      case NotificationType.choreCompleted:
        return Icons.task_alt_rounded;
      case NotificationType.limitExceeded:
        return Icons.warning_amber_rounded;
      case NotificationType.moneyAdded:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.spent:
        return const Color(0xFF6C63FF);
      case NotificationType.choreCompleted:
        return const Color(0xFF00C9A7);
      case NotificationType.limitExceeded:
        return const Color(0xFFFF6B6B);
      case NotificationType.moneyAdded:
        return const Color(0xFF1A73E8);
    }
  }
}

class SpendingLimit {
  double dailyLimit;
  double dailyUsed;
  double weeklyLimit;
  double weeklyUsed;

  SpendingLimit({
    required this.dailyLimit,
    required this.dailyUsed,
    required this.weeklyLimit,
    required this.weeklyUsed,
  });

  double get dailyPercent => (dailyUsed / dailyLimit).clamp(0.0, 1.0);
  double get weeklyPercent => (weeklyUsed / weeklyLimit).clamp(0.0, 1.0);
  bool get isDailyExceeded => dailyUsed >= dailyLimit;
  bool get isWeeklyExceeded => weeklyUsed >= weeklyLimit;
  double get dailyRemaining => (dailyLimit - dailyUsed).clamp(0, double.infinity);
  double get weeklyRemaining => (weeklyLimit - weeklyUsed).clamp(0, double.infinity);
}

// ── Weekly Spending Data (for chart) ──────────────────────────
class WeeklySpend {
  final String day;
  final double amount;
  WeeklySpend({required this.day, required this.amount});
}

// ── Mock Data & Helpers ───────────────────────────────────────

class ParentData {
  static ParentProfile profile = ParentProfile(
    name: 'Ravi Kumar',
    avatarEmoji: '👨',
    totalMoneySent: 3500.00,
  );

  static SpendingLimit spendingLimit = SpendingLimit(
    dailyLimit: 300.0,
    dailyUsed: 85.0,
    weeklyLimit: 1500.0,
    weeklyUsed: 340.0,
  );

  static List<AppNotification> notifications = [
    AppNotification(
      id: 'n1',
      title: 'Chore Completed 🎉',
      body: 'Aarav completed "Make your bed" — approve to pay ₹20',
      time: DateTime.now().subtract(const Duration(minutes: 10)),
      type: NotificationType.choreCompleted,
    ),
    AppNotification(
      id: 'n2',
      title: 'Money Spent 💸',
      body: 'Aarav spent ₹85 on Snacks at school',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.spent,
    ),
    AppNotification(
      id: 'n3',
      title: 'Chore Completed ✅',
      body: 'Aarav completed "Study for 1 hour" — approve to pay ₹50',
      time: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotificationType.choreCompleted,
    ),
    AppNotification(
      id: 'n4',
      title: 'Money Added 💰',
      body: 'You sent ₹500 pocket money to Aarav',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.moneyAdded,
      isRead: true,
    ),
    AppNotification(
      id: 'n5',
      title: 'Spending Alert ⚠️',
      body: 'Aarav has used 80% of the weekly spending limit',
      time: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.limitExceeded,
      isRead: true,
    ),
    AppNotification(
      id: 'n6',
      title: 'Money Spent 💸',
      body: 'Aarav spent ₹120 on Stationery',
      time: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.spent,
      isRead: true,
    ),
  ];

  static List<WeeklySpend> weeklySpending = [
    WeeklySpend(day: 'Mon', amount: 85),
    WeeklySpend(day: 'Tue', amount: 120),
    WeeklySpend(day: 'Wed', amount: 0),
    WeeklySpend(day: 'Thu', amount: 200),
    WeeklySpend(day: 'Fri', amount: 55),
    WeeklySpend(day: 'Sat', amount: 135),
    WeeklySpend(day: 'Sun', amount: 45),
  ];

  // Spending by category for pie chart
  static Map<String, double> spendingCategories = {
    'Chore Rewards': 70,
    'Food': 85,
    'Stationery': 120,
    'Savings': 200,
    'Others': 55,
  };

  // ── Parent Chore List (synced from child) ─────────────────────
  static List<ParentChore> get parentChores =>
      ChildData.chores.map((c) => ParentChore.fromChore(c)).toList();

  // ── Helpers ───────────────────────────────────────────────────

  /// Send money to the child's wallet
  static void addMoney(double amount) {
    ChildData.profile.balance += amount;
    profile.totalMoneySent += amount;
    spendingLimit.weeklyUsed = (spendingLimit.weeklyUsed).clamp(
      0,
      spendingLimit.weeklyLimit,
    );
    ChildData.transactions.insert(
      0,
      Transaction(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        label: 'Pocket Money from ${profile.name}',
        amount: amount,
        date: DateTime.now(),
        type: TransactionType.credit,
        icon: Icons.account_balance_wallet_rounded,
      ),
    );
    notifications.insert(
      0,
      AppNotification(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Money Sent 💰',
        body: '₹${amount.toStringAsFixed(0)} sent to Aarav\'s wallet',
        time: DateTime.now(),
        type: NotificationType.moneyAdded,
      ),
    );
  }

  /// Approve a completed chore — pays child
  static bool approveChore(String choreId) {
    final chores = ChildData.chores;
    final idx = chores.indexWhere((c) => c.id == choreId);
    if (idx == -1) return false;
    final chore = chores[idx];
    if (chore.status != ChoreStatus.completed) return false;

    ChildData.profile.balance += chore.reward;
    ChildData.transactions.insert(
      0,
      Transaction(
        id: 'p_chore_${DateTime.now().millisecondsSinceEpoch}',
        label: 'Chore Approved – ${chore.title}',
        amount: chore.reward,
        date: DateTime.now(),
        type: TransactionType.credit,
        icon: Icons.task_alt_rounded,
      ),
    );
    // Remove from list after approval
    ChildData.chores.removeAt(idx);
    return true;
  }

  /// Reject a completed chore — resets back to pending
  static bool rejectChore(String choreId) {
    final chore = ChildData.chores.firstWhere(
      (c) => c.id == choreId,
      orElse: () => throw Exception('Chore not found'),
    );
    if (chore.status != ChoreStatus.completed) return false;
    chore.status = ChoreStatus.pending;
    return true;
  }

  /// Create a new chore and add it to the shared list
  static void createChore({
    required String title,
    required String description,
    required double reward,
    required IconData icon,
    required Color iconColor,
  }) {
    final newChore = Chore(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      reward: reward,
      status: ChoreStatus.pending,
      icon: icon,
      iconColor: iconColor,
    );
    ChildData.chores.add(newChore);
  }

  /// Update daily spending limit
  static void setDailyLimit(double limit) {
    spendingLimit.dailyLimit = limit;
    ChildData.profile.spendingLimit = limit;
  }

  /// Update weekly spending limit
  static void setWeeklyLimit(double limit) {
    spendingLimit.weeklyLimit = limit;
  }

  /// Dismiss / mark notification as read
  static void markNotificationRead(String id) {
    final n = notifications.firstWhere((n) => n.id == id, orElse: () => throw Exception());
    n.isRead = true;
  }

  static void removeNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}
