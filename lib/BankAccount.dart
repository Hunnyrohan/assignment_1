// Abstract base class for BankAccount
abstract class BankAccount {
  // Private fields for encapsulation (library-private in Dart)
  String _accountNumber;
  String _accountHolderName;
  double _balance;

  // Constructor
  BankAccount(this._accountNumber, this._accountHolderName, this._balance);

  // Getters for encapsulation
  String get accountNumber => _accountNumber;
  String get accountHolderName => _accountHolderName;
  double get balance => _balance;

  // Setter with validation
  set accountHolderName(String name) {
    if (name.isNotEmpty) {
      _accountHolderName = name;
    }
  }

  // Methods that subclasses must implement
  void deposit(double amount);
  void withdraw(double amount);

  // Method to display account information
  void displayInfo() {
    print('Account Number: $_accountNumber');
    print('Account Holder: $_accountHolderName');
    print('Balance: \$${_balance.toStringAsFixed(2)}');
  }
}

// Interface for interest-bearing accounts
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
      print('Deposited \$${amount.toStringAsFixed(2)} into PremiumAccount.');
    }
  }

  @override
  void withdraw(double amount) {
    if (amount > 0 && _balance - amount >= MIN_BALANCE) {
      _balance -= amount;
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
    try {
      return _accounts.firstWhere((acc) => acc.accountNumber == accountNumber);
    } catch (e) {
      return null;
    }
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

      // Only call calculateInterest if the account supports InterestBearing
      if (account is InterestBearing) {
        // cast to InterestBearing and call calculateInterest
        double interest = (account as InterestBearing).calculateInterest();
        print('Interest Earned: \$${interest.toStringAsFixed(2)}');
      }

      print('---');
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

  bank.createAccount(savings);
  bank.createAccount(checking);
  bank.createAccount(premium);

  // Perform operations
  savings.deposit(100.0);
  savings.withdraw(50.0);
  checking.withdraw(1100.0); // Overdraft
  premium.withdraw(2000.0);

  // Transfer
  bank.transfer('SA001', 'CA001', 100.0);

  // Generate report
  bank.generateReport();
}
