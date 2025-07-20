# frozen_string_literal: true

class CashFlowEntry < ActiveRecord::Base
  # Associations
  belongs_to :project, optional: true
  belongs_to :issue, optional: true
  belongs_to :author, class_name: 'User'

  # Constants
  STATUSES = %w[pending paid blocked rejected].freeze
  TRANSACTION_TYPES = %w[revenue expense].freeze
  CATEGORY_MAX_LENGTH = 100
  DESCRIPTION_MAX_LENGTH = 255

  # Validations
  validates :entry_date, presence: true
  validates :description, presence: true, length: { maximum: DESCRIPTION_MAX_LENGTH }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_type, presence: true, inclusion: { in: TRANSACTION_TYPES }
  validates :category, presence: true, length: { maximum: CATEGORY_MAX_LENGTH }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :author_id, presence: true

  # Scopes corrigidos
  scope :between_dates, ->(start_date, end_date) { 
    start_date.present? && end_date.present? ? where(entry_date: start_date..end_date) : all
  }
  
  scope :by_transaction_type, ->(type) { 
    type.present? && TRANSACTION_TYPES.include?(type) ? where(transaction_type: type) : all 
  }
  
  scope :by_category, ->(category) { 
    category.present? ? where('LOWER(category) LIKE ?', "%#{category.downcase}%") : all 
  }
  
  scope :by_description, ->(desc) { 
    desc.present? ? where('LOWER(description) LIKE ?', "%#{desc.downcase}%") : all 
  }
  
  scope :by_amount_min, ->(min) { 
    min.present? ? where('amount >= ?', min) : all 
  }
  
  scope :by_amount_max, ->(max) { 
    max.present? ? where('amount <= ?', max) : all 
  }
  
  scope :by_project, ->(project_id) { 
    project_id.present? ? where(project_id: project_id) : all 
  }
  
  scope :by_status, ->(status) { 
    status.present? && STATUSES.include?(status) ? where(status: status) : all 
  }
  
  scope :by_issue, ->(issue_id) { 
    issue_id.present? ? where(issue_id: issue_id) : all 
  }
  
  scope :by_author, ->(author_id) { 
    author_id.present? ? where(author_id: author_id) : all 
  }

  # Class methods
  class << self
    def transaction_type_options
      [
        [I18n.t(:label_cash_flow_revenue), 'revenue'],
        [I18n.t(:label_cash_flow_expense), 'expense']
      ]
    end

    def status_options
      STATUSES.map { |s| [I18n.t("label_cash_flow_status_#{s}"), s] }
    end

    def available_categories
      order(:category).distinct.pluck(:category)
    end
  end

  # Instance methods
  def transaction_type_label
    I18n.t("label_cash_flow_#{transaction_type}")
  end

  def status_label
    I18n.t("label_cash_flow_status_#{status}")
  end
end