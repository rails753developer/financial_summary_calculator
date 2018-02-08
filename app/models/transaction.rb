class Transaction < ApplicationRecord

  monetize :amount_cents

  validate :action_category_match
  validate :must_be_greater_than_zero

  belongs_to :user

  after_save :make_immutable
  after_find :make_immutable

  class << self

    # last one day transactions
    def one_day
      @transactions = where("created_at >= ?", (Time.now - 1.day))
    end

    # last seven days transactions
    def seven_days
      @transactions = where("created_at >= ?", (Time.now - 7.days))
    end

    # all transactions
    def lifetime
      @transactions = where('')
    end

    # to get count of transactions by category
    def count_of(category)
      @transactions.select {|transaction| transaction.category.to_sym == category}.size
    end

    def amount(category)
      sum = 0

      @transactions.each do |transaction|
        if transaction.category.to_sym == category
          sum += transaction.amount
        end
      end

      sum
    end

    # to get the summary
    def total_amount
      sum = 0
      @transactions.each do |transaction|
        if transaction.category.in? %w[deposit refund purchase]
          sum = sum + transaction.amount
        elsif transaction.category.in? %w[withdraw ante]
          sum = sum - transaction.amount
        end
      end

      sum
    end
  end

  private

  def action_category_match
    if action.to_sym == :credit
      if !%w[deposit refund purchase].include?(category)
        errors.add(:base, 'Credits must be in category deposit, refund or purchase.')
      end
    elsif action.to_sym == :debit
      if !%w[withdraw ante].include?(category)
        errors.add(:base, 'Debits must be in category withdraw or ante.')
      end
    end
  end

  def must_be_greater_than_zero
    errors.add(:amount, 'Must be greater than 0') if amount <= Money.from_amount(0, amount_currency)
  end

  def make_immutable
    self.readonly!
  end
end