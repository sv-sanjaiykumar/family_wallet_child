# Family Vault – Child Module (Minimal Hackathon Build)

Build the complete Child Module with 5 screens + bottom navigation for the hackathon demo. Fresh Flutter project with only [main.dart](file:///d:/FlutterApps/family_wallet_children/lib/main.dart) as a starter.

## Proposed File Structure

```
lib/
├── main.dart                          [MODIFY] – wire up theme + ChildApp entry
├── theme/
│   └── app_theme.dart                 [NEW] – color palette, text styles, gradients
├── models/
│   └── child_data.dart                [NEW] – mock data models (chores, goals, txns)
├── screens/
│   └── child/
│       ├── child_home_shell.dart      [NEW] – BottomNavBar shell for child
│       ├── dashboard_screen.dart      [NEW] – Wallet balance, level, badges, streak
│       ├── chores_screen.dart         [NEW] – Chore cards with Mark Complete
│       ├── savings_screen.dart        [NEW] – Goal cards with progress bars
│       ├── transactions_screen.dart   [NEW] – Credit/debit history list
│       └── send_money_screen.dart     [NEW] – Send/spend with limit validation
└── widgets/
    ├── balance_card.dart              [NEW] – Animated wallet card
    ├── chore_card.dart                [NEW] – Single chore tile
    ├── goal_card.dart                 [NEW] – Savings goal with progress bar
    └── transaction_tile.dart          [NEW] – Single transaction row
```

---

## Proposed Changes

### Theme Layer
#### [NEW] `app_theme.dart`
- Define playful color palette: deep purple, teal, amber, green, pink
- Custom `ThemeData` with rounded shapes, Google Fonts (Nunito/Poppins)
- Gradient helpers for cards and AppBar

---

### Data Layer
#### [NEW] `child_data.dart`
- `ChildProfile` model: name, balance, level, badges, streak, spending limit, spent
- `Chore` model: title, reward, status (pending/completed), icon
- `SavingsGoal` model: title, target, saved, color, icon
- `Transaction` model: amount, date, label, type (credit/debit)
- Static mock data lists for demo

---

### Screens
#### [MODIFY] [main.dart](file:///d:/FlutterApps/family_wallet_children/lib/main.dart)
- Replace default counter app with `ChildApp` → `ChildHomeShell`
- Apply `AppTheme.theme`

#### [NEW] `child_home_shell.dart`
- `BottomNavigationBar` with 5 tabs: Dashboard, Chores, Goals, Transactions, Send

#### [NEW] `dashboard_screen.dart`
- Gradient header with avatar + greeting
- `BalanceCard` widget (animated shimmer)
- Level badge + XP bar
- Streak counter chip
- Badges row (horizontal scroll)
- Spending limit circular progress indicator

#### [NEW] `chores_screen.dart`
- SliverList of `ChoreCard` widgets
- Color-coded status (pending = amber, done = green)
- "Mark as Done" button triggers setState + balance update

#### [NEW] `savings_screen.dart`
- Grid of `GoalCard` widgets
- Each with linear progress bar, saved/target amounts
- "Add Money" bottom sheet with slider input

#### [NEW] `transactions_screen.dart`
- ListView of `TransactionTile`
- Green icon for credit, red for debit
- Date grouped header

#### [NEW] `send_money_screen.dart`
- Text input for amount
- Validation: exceeds limit → banner warning
- Confirm dialog → deducts from balance

---

### Widgets
#### [NEW] `balance_card.dart`, `chore_card.dart`, `goal_card.dart`, `transaction_tile.dart`
- Reusable, self-contained cards

---

## Verification Plan

### Manual Verification (Flutter Run)
```bash
cd d:\FlutterApps\family_wallet_children
flutter run
```
1. App opens on **Dashboard** – verify balance card, level, badges visible
2. Tap **Chores** tab – verify chore list loads, tap "Mark Done" → reward added to balance
3. Tap **Goals** tab – verify goal cards with progress bars
4. Tap **Transactions** tab – verify credit/debit list with color coding
5. Tap **Send** tab – enter amount exceeding limit → verify warning shows
