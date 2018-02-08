class FinancialSummary

  # initializing with the dependencies
  def initialize(required_input)
    @user_id = required_input[:user_id]
    @currency = required_input[:currency].to_s.upcase
  end

  # method to fetch transactions of last one day made by a particular user
  def one_day
    fetch_transactions.one_day
  end

  # method to fetch transactions of last seven days made by a particular user
  def seven_days
    fetch_transactions.seven_days
  end

  # method to fetch all transactions made by a particular user
  def lifetime
    fetch_transactions.lifetime
  end

  private

  # method to fetch all transactions of a user
  def fetch_transactions
    Transaction.where(:user_id => @user_id, :amount_currency => @currency)
                  .select(:amount_cents, :amount_currency, :category)
  end
end