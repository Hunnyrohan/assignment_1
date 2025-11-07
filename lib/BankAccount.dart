abstract class BankAccount {
  String _accountNumber;
  String _accountHolderName;
  double _balance;

  BankAccount(this._accountNumber, this._accountHolderName, this._balance);

  String get accountNumber => _accountNumber;
  String get accountHolderName => _accountHolderName;
  double get balance => _balance;

  set accountHolderName(String name) {
    if (name.isNotEmpty) _accountHolderName = name;
  }

  void deposit(double amount);
  void withdraw(double amount);

  void displayInfo() {
    print('Account Number: $_accountNumber');
    print('Account Holder: $_accountHolderName');
    print('Balance: \$${_balance.toStringAsFixed(2)}');
  }
}

abstract class InterestBearing {
  double calculateInterest();
}

class SavingsAccount extends BankAccount implements InterestBearing {
  int _withdrawalCount = 0;
  static const double MIN_BALANCE = 500.0;
  static const double INTEREST_RATE = 0.02;

  SavingsAccount(String accountNumber, String accountHolderName, double balance)
      : super(accountNumber, accountHolderName, balance) {
    if (balance < MIN_BALANCE) throw ArgumentError('Minimum balance $MIN_BALANCE required');
  }

  @override
  void deposit(double amount) {
    if (amount > 0) _balance += amount;
  }

  @override
  void withdraw(double amount) {
    if (_withdrawalCount >= 3) return;
    if (amount > 0 && _balance - amount >= MIN_BALANCE) {
      _balance -= amount;
      _withdrawalCount++;
    }
  }

  @override
  double calculateInterest() => _balance * INTEREST_RATE;
}

class CheckingAccount extends BankAccount {
  static const double OVERDRAFT_FEE = 35.0;

  CheckingAccount(String accountNumber, String accountHolderName, double balance)
      : super(accountNumber, accountHolderName, balance);

  @override
  void deposit(double amount) {
    if (amount > 0) _balance += amount;
  }

  @override
  void withdraw(double amount) {
    if (amount > 0) {
      _balance -= amount;
      if (_balance < 0) _balance -= OVERDRAFT_FEE;
    }
  }
}

class PremiumAccount extends BankAccount implements InterestBearing {
  static const double MIN_BALANCE = 10000.0;
  static const double INTEREST_RATE = 0.05;

  PremiumAccount(String accountNumber, String accountHolderName, double balance)
      : super(accountNumber, accountHolderName, balance) {
    if (balance < MIN_BALANCE) throw ArgumentError('Minimum balance $MIN_BALANCE required');
  }

  @override
  void deposit(double amount) {
    if (amount > 0) _balance += amount;
  }

  @override
  void withdraw(double amount) {
    if (amount > 0 && _balance - amount >= MIN_BALANCE) _balance -= amount;
  }

  @override
  double calculateInterest() => _balance * INTEREST_RATE;
}

class Bank {
  List<BankAccount> _accounts = [];

  void createAccount(BankAccount account) {
    _accounts.add(account);
  }

  BankAccount? findAccount(String accountNumber) {
    try {
      return _accounts.firstWhere((acc) => acc.accountNumber == accountNumber);
    } catch (e) {
      return null;
    }
  }

  void transfer(String fromAccountNumber, String toAccountNumber, double amount) {
    var from = findAccount(fromAccountNumber);
    var to = findAccount(toAccountNumber);
    if (from != null && to != null && amount > 0) {
      from.withdraw(amount);
      to.deposit(amount);
    }
  }

  void generateReport() {
    for (var account in _accounts) {
      account.displayInfo();
      if (account is InterestBearing) {
        var interest = (account as InterestBearing).calculateInterest();
        print('Interest Earned: \$${interest.toStringAsFixed(2)}');
      }
    }
  }
}

void main() {
  var bank = Bank();

  var savings = SavingsAccount('SA001', 'Ravi', 600.0);
  var checking = CheckingAccount('CA001', 'Rahul', 1000.0);
  var premium = PremiumAccount('PA001', 'Raju', 15000.0);

  bank.createAccount(savings);
  bank.createAccount(checking);
  bank.createAccount(premium);

  savings.deposit(100.0);
  savings.withdraw(50.0);
  checking.withdraw(1100.0);
  premium.withdraw(2000.0);

  bank.transfer('SA001', 'CA001', 100.0);

  bank.generateReport();
}