// Abstract base class for BankAccount
abstract class BankAccount {
  // Private fields for encapsulation
  String _accountNumber;
  String _accountHolderName;
  double _balance;

  // Constructor
  BankAccount(this._accountNumber, this._accountHolderName, this._balance);

  // Getters for encapsulation
  String get accountNumber => _accountNumber;
  String get accountHolderName => _accountHolderName;
  double get balance => _balance;

  // Setters with validation
  set accountHolderName(String name) {
    if (name.isNotEmpty) {
      _accountHolderName = name;
    }
  }

  // Abstract methods for polymorphism and abstraction
  void deposit(double amount);
  void withdraw(double amount);

  // Method to display account information
  void displayInfo() {
    print('Account Number: $_accountNumber');
    print('Account Holder: $_accountHolderName');
    print('Balance: \$${_balance.toStringAsFixed(2)}');
  }
}

// Interface for interest-bearing accounts (abstraction)
abstract class InterestBearing {
  double calculateInterest();
}

// SavingsAccount class inheriting from BankAccount and implementing InterestBearing
class SavingsAccount extends BankAccount implements InterestBearing {
  int _withdrawalCount = 0;
  static const double MIN_BALANCE = 500.0;
  static const double INTEREST_RATE = 0.02;

  SavingsAccount(String accountNumber, String accountHolderName, double balance)
      : super(accountNumber, accountHolderName, balance) {
    if (balance < MIN_BALANCE) {
      throw ArgumentError('Initial balance must be at least \$500 for SavingsAccount');
    }
  }

  @override
  void deposit(double amount) {
    if (amount > 0) {
      _balance += amount;
      addTransaction('deposit', amount); // Track transaction
      print('Deposited \$${amount.toStringAsFixed(2)} into SavingsAccount.');
    }
  }

  @override
  void withdraw(double amount) {
    if (_withdrawalCount >= 3) {
      print('Withdrawal limit of 3 per month reached for SavingsAccount.');
      return;
    }
    if (amount > 0 && _balance - amount >= MIN_BALANCE) {
      _balance -= amount;
      _withdrawalCount++;
      addTransaction('withdraw', amount); // Track transaction
      print('Withdrew \$${amount.toStringAsFixed(2)} from SavingsAccount.');
    } else {
      print('Insufficient funds or would violate minimum balance.');
    }
  }

  @override
  double calculateInterest() {
    return _balance * INTEREST_RATE;
  }
}

// CheckingAccount class inheriting from BankAccount
class CheckingAccount extends BankAccount {
  static const double OVERDRAFT_FEE = 35.0;

  CheckingAccount(String accountNumber, String accountHolderName, double balance)
      : super(accountNumber, accountHolderName, balance);

  @override
  void deposit(double amount) {
    if (amount > 0) {
      _balance += amount;
      addTransaction('deposit', amount); // Track transaction
      print('Deposited \$${amount.toStringAsFixed(2)} into CheckingAccount.');
    }
  }

  @override
  void withdraw(double amount) {
    if (amount > 0) {
      _balance -= amount;
      if (_balance < 0) {
        _balance -= OVERDRAFT_FEE;
        print('Overdraft fee of \$${OVERDRAFT_FEE.toStringAsFixed(2)} applied.');
      }
      addTransaction('withdraw', amount); // Track transaction
      print('Withdrew \$${amount.toStringAsFixed(2)} from CheckingAccount.');
    }
  }
}

// PremiumAccount class inheriting from BankAccount and implementing InterestBearing
class PremiumAccount extends BankAccount implements InterestBearing {
  static const double MIN_BALANCE = 10000.0;
  static const double INTEREST_RATE = 0.05;

  PremiumAccount(String accountNumber, String accountHolderName, double balance)
      : super(accountNumber, accountHolderName, balance) {
    if (balance < MIN_BALANCE) {
      throw ArgumentError('Initial balance must be at least \$10,000 for PremiumAccount');
    }
  }

  @override
  void deposit(double amount) {
    if (amount > 0) {
      _balance += amount;
      addTransaction('deposit', amount); // Track transaction
      print('Deposited \$${amount.toStringAsFixed(2)} into PremiumAccount.');
    }
  }

  @override
  void withdraw(double amount) {
    if (amount > 0 && _balance - amount >= MIN_BALANCE) {
      _balance -= amount;
      addTransaction('withdraw', amount); // Track transaction
      print('Withdrew \$${amount.toStringAsFixed(2)} from PremiumAccount.');
    } else {
      print('Insufficient funds or would violate minimum balance.');
    }
  }

  @override
  double calculateInterest() {
    return _balance * INTEREST_RATE;
  }
}

// Bank class to manage accounts
class Bank {
  List<BankAccount> _accounts = [];

  // Create a new account
  void createAccount(BankAccount account) {
    _accounts.add(account);
    print('Account created: ${account.accountNumber}');
  }

  // Find account by number
  BankAccount? findAccount(String accountNumber) {
    return _accounts.firstWhere(
      (acc) => acc.accountNumber == accountNumber,
      orElse: () => null as BankAccount,
    );
  }

  // Transfer money between accounts
  void transfer(String fromAccountNumber, String toAccountNumber, double amount) {
    BankAccount? fromAccount = findAccount(fromAccountNumber);
    BankAccount? toAccount = findAccount(toAccountNumber);
    if (fromAccount != null && toAccount != null && amount > 0) {
      fromAccount.withdraw(amount);
      toAccount.deposit(amount);
      print('Transferred \$${amount.toStringAsFixed(2)} from ${fromAccount.accountNumber} to ${toAccount.accountNumber}');
    } else {
      print('Transfer failed: Invalid accounts or amount.');
    }
  }

  // Generate reports of all accounts
  void generateReport() {
    print('\n--- Bank Report ---');
    for (var account in _accounts) {
      account.displayInfo();
      if (account is InterestBearing) {
        InterestBearing interestAccount = account as InterestBearing;
        print('Interest Earned: \$${interestAccount.calculateInterest().toStringAsFixed(2)}');
      }
      print('---');
    }
  }
}

// Extension: StudentAccount class (inherits from BankAccount, no fees, max balance $5,000)
class StudentAccount extends BankAccount {
  static const double MAX_BALANCE = 5000.0;

  StudentAccount(String accountNumber, String accountHolderName, double balance)
      : super(accountNumber, accountHolderName, balance) {
    if (balance > MAX_BALANCE) {
      throw ArgumentError('Initial balance cannot exceed \$5,000 for StudentAccount');
    }
  }

  @override
  void deposit(double amount) {
    if (amount > 0 && _balance + amount <= MAX_BALANCE) {
      _balance += amount;
      addTransaction('deposit', amount); // Track transaction
      print('Deposited \$${amount.toStringAsFixed(2)} into StudentAccount.');
    } else {
      print('Deposit would exceed maximum balance.');
    }
  }

  @override
  void withdraw(double amount) {
    if (amount > 0 && _balance - amount >= 0) {
      _balance -= amount;
      addTransaction('withdraw', amount); // Track transaction
      print('Withdrew \$${amount.toStringAsFixed(2)} from StudentAccount.');
    } else {
      print('Insufficient funds.');
    }
  }
}

// Extension: Transaction history tracking (added to BankAccount)
class Transaction {
  String type; // 'deposit' or 'withdraw'
  double amount;
  DateTime timestamp;

  Transaction(this.type, this.amount) : timestamp = DateTime.now();
}

extension TransactionHistory on BankAccount {
  static final Map<String, List<Transaction>> _histories = {};

  List<Transaction> get history => _histories[accountNumber] ??= [];

  void addTransaction(String type, double amount) {
    history.add(Transaction(type, amount));
  }

  void displayHistory() {
    print('Transaction History for $accountNumber:');
    for (var tx in history) {
      print('${tx.timestamp}: ${tx.type} \$${tx.amount.toStringAsFixed(2)}');
    }
  }
}

// Extension: Method to apply monthly interest to all interest-bearing accounts
extension MonthlyInterest on Bank {
  void applyMonthlyInterest() {
    for (var account in _accounts) {
      if (account is InterestBearing) {
        InterestBearing interestAccount = account as InterestBearing;
        double interest = interestAccount.calculateInterest();
        account.deposit(interest); // Assuming deposit adds to balance
        print('Applied monthly interest of \$${interest.toStringAsFixed(2)} to ${account.accountNumber}');
      }
    }
  }
}

// Example usage (for testing)
void main() {
  Bank bank = Bank();

  // Create accounts
  SavingsAccount savings = SavingsAccount('SA001', 'Alice', 600.0);
  CheckingAccount checking = CheckingAccount('CA001', 'Bob', 1000.0);
  PremiumAccount premium = PremiumAccount('PA001', 'Charlie', 15000.0);
  StudentAccount student = StudentAccount('ST001', 'Dave', 1000.0);

  bank.createAccount(savings);
  bank.createAccount(checking);
  bank.createAccount(premium);
  bank.createAccount(student);

  // Perform operations
  savings.deposit(100.0);
  savings.withdraw(50.0);
  checking.withdraw(1100.0); // Overdraft
  premium.withdraw(2000.0);
  student.deposit(4000.0); // Max balance check

  // Transfer
  bank.transfer('SA001', 'CA001', 100.0);

  // Apply monthly interest
  bank.applyMonthlyInterest();

  // Display history (example)
  savings.displayHistory();

  // Generate report
  bank.generateReport();
}