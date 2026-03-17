import 'package:flutter/material.dart';

// ── Enums ──────────────────────────────────────────────────────
enum ChoreStatus { pending, completed }
enum TransactionType { credit, debit }

// ── Models ─────────────────────────────────────────────────────

class ChildProfile {
  final String name;
  final String avatarEmoji;
  double balance;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final int streakDays;
  final double spendingLimit;
  double spent;
  final List<String> badges;

  ChildProfile({
    required this.name,
    required this.avatarEmoji,
    required this.balance,
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
    required this.streakDays,
    required this.spendingLimit,
    required this.spent,
    required this.badges,
  });

  double get spendingUsagePercent => (spent / spendingLimit).clamp(0.0, 1.0);
  double get xpPercent => (xp / xpToNextLevel).clamp(0.0, 1.0);
  double get remainingLimit => spendingLimit - spent;
}

class Chore {
  final String id;
  final String title;
  final String description;
  final double reward;
  ChoreStatus status;
  final IconData icon;
  final Color iconColor;

  Chore({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.status,
    required this.icon,
    required this.iconColor,
  });
}

class SavingsGoal {
  final String id;
  final String title;
  final String emoji;
  final double target;
  double saved;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.emoji,
    required this.target,
    required this.saved,
  });

  double get progressPercent => (saved / target).clamp(0.0, 1.0);
  double get remaining => target - saved;
  bool get isCompleted => saved >= target;
}

class Transaction {
  final String id;
  final String label;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final IconData icon;

  Transaction({
    required this.id,
    required this.label,
    required this.amount,
    required this.date,
    required this.type,
    required this.icon,
  });
}

// ── Mock Data ──────────────────────────────────────────────────

class ChildData {
  // Singleton-style mutable state for demo
  static ChildProfile profile = ChildProfile(
    name: 'Aarav',
    avatarEmoji: '🧒',
    balance: 1250.00,
    level: 4,
    xp: 320,
    xpToNextLevel: 500,
    streakDays: 5,
    spendingLimit: 800.00,
    spent: 340.00,
    badges: ['🥇', '🎯', '💰', '⭐', '🔥'],
  );

  static List<Chore> chores = [
    Chore(
      id: 'c1',
      title: 'Wash the dishes',
      description: 'Clean all dishes after dinner',
      reward: 30,
      status: ChoreStatus.pending,
      icon: Icons.soup_kitchen_rounded,
      iconColor: const Color(0xFF6C63FF),
    ),
    Chore(
      id: 'c2',
      title: 'Make your bed',
      description: 'Neatly arrange your bed every morning',
      reward: 20,
      status: ChoreStatus.completed,
      icon: Icons.bed_rounded,
      iconColor: const Color(0xFF00C9A7),
    ),
    Chore(
      id: 'c3',
      title: 'Water the plants',
      description: 'Water all plants in the balcony',
      reward: 25,
      status: ChoreStatus.pending,
      icon: Icons.local_florist_rounded,
      iconColor: const Color(0xFF4CAF50),
    ),
    Chore(
      id: 'c4',
      title: 'Take out the trash',
      description: 'Empty the dustbins before 9 AM',
      reward: 15,
      status: ChoreStatus.pending,
      icon: Icons.delete_outline_rounded,
      iconColor: const Color(0xFFFF9A3C),
    ),
    Chore(
      id: 'c5',
      title: 'Study for 1 hour',
      description: 'Complete your homework or revision',
      reward: 50,
      status: ChoreStatus.completed,
      icon: Icons.menu_book_rounded,
      iconColor: const Color(0xFFFF85A1),
    ),
    Chore(
      id: 'c6',
      title: 'Clean your room',
      description: 'Organize your room and keep it tidy',
      reward: 40,
      status: ChoreStatus.pending,
      icon: Icons.cleaning_services_rounded,
      iconColor: const Color(0xFF4FC3F7),
    ),
  ];

  static List<SavingsGoal> goals = [
    SavingsGoal(
      id: 'g1',
      title: 'Buy Headphones',
      emoji: '🎧',
      target: 2000,
      saved: 850,
    ),
    SavingsGoal(
      id: 'g2',
      title: 'New Cricket Bat',
      emoji: '🏏',
      target: 1500,
      saved: 1200,
    ),
    SavingsGoal(
      id: 'g3',
      title: 'Minecraft Premium',
      emoji: '🎮',
      target: 800,
      saved: 800,
    ),
    SavingsGoal(
      id: 'g4',
      title: 'Birthday Gift for Mom',
      emoji: '🎁',
      target: 500,
      saved: 120,
    ),
  ];

  static List<Transaction> transactions = [
    Transaction(
      id: 't1',
      label: 'Pocket Money from Dad',
      amount: 500,
      date: DateTime.now().subtract(const Duration(days: 0)),
      type: TransactionType.credit,
      icon: Icons.account_balance_wallet_rounded,
    ),
    Transaction(
      id: 't2',
      label: 'Snacks at school',
      amount: 85,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.debit,
      icon: Icons.fastfood_rounded,
    ),
    Transaction(
      id: 't3',
      label: 'Chore Reward – Study',
      amount: 50,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.credit,
      icon: Icons.star_rounded,
    ),
    Transaction(
      id: 't4',
      label: 'Stationery purchase',
      amount: 120,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: TransactionType.debit,
      icon: Icons.edit_rounded,
    ),
    Transaction(
      id: 't5',
      label: 'Chore Reward – Bed',
      amount: 20,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: TransactionType.credit,
      icon: Icons.star_rounded,
    ),
    Transaction(
      id: 't6',
      label: 'Saved to Headphones goal',
      amount: 200,
      date: DateTime.now().subtract(const Duration(days: 3)),
      type: TransactionType.debit,
      icon: Icons.savings_rounded,
    ),
    Transaction(
      id: 't7',
      label: 'Weekly allowance',
      amount: 300,
      date: DateTime.now().subtract(const Duration(days: 4)),
      type: TransactionType.credit,
      icon: Icons.account_balance_wallet_rounded,
    ),
    Transaction(
      id: 't8',
      label: 'Book purchase',
      amount: 135,
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: TransactionType.debit,
      icon: Icons.menu_book_rounded,
    ),
  ];

  // ── Helper Methods ───────────────────────────────────────────

  static void completeChore(String choreId) {
    final chore = chores.firstWhere((c) => c.id == choreId);
    if (chore.status == ChoreStatus.pending) {
      chore.status = ChoreStatus.completed;
      profile.balance += chore.reward;
      transactions.insert(
        0,
        Transaction(
          id: 't_${DateTime.now().millisecondsSinceEpoch}',
          label: 'Chore Reward – ${chore.title}',
          amount: chore.reward,
          date: DateTime.now(),
          type: TransactionType.credit,
          icon: Icons.star_rounded,
        ),
      );
    }
  }

  static bool spendMoney(double amount, String label) {
    if (profile.spent + amount > profile.spendingLimit) return false;
    if (amount > profile.balance) return false;
    profile.balance -= amount;
    profile.spent += amount;
    transactions.insert(
      0,
      Transaction(
        id: 't_${DateTime.now().millisecondsSinceEpoch}',
        label: label,
        amount: amount,
        date: DateTime.now(),
        type: TransactionType.debit,
        icon: Icons.send_rounded,
      ),
    );
    return true;
  }

  static bool addToGoal(String goalId, double amount) {
    final goal = goals.firstWhere((g) => g.id == goalId);
    if (amount > profile.balance) return false;
    if (goal.isCompleted) return false;
    final toAdd = (goal.remaining < amount) ? goal.remaining : amount;
    goal.saved += toAdd;
    profile.balance -= toAdd;
    transactions.insert(
      0,
      Transaction(
        id: 't_${DateTime.now().millisecondsSinceEpoch}',
        label: 'Saved to ${goal.title}',
        amount: toAdd,
        date: DateTime.now(),
        type: TransactionType.debit,
        icon: Icons.savings_rounded,
      ),
    );
    return true;
  }
}
