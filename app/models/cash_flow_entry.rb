# frozen_string_literal: true

class CashFlowEntry < ActiveRecord::Base
  #unloadable # Necessário para plugins que não estão no Rails Engines

  belongs_to :project, optional: true # Lançamento pode estar ou não associado a um projeto
  belongs_to :user # Lançamento sempre tem um usuário associado

  validates :entry_date, presence: true
  validates :description, presence: true, length: { maximum: 255 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_type, presence: true, inclusion: { in: %w[revenue expense] } # 'receita' ou 'despesa'
  validates :category, presence: true, length: { maximum: 100 }
  validates :user_id, presence: true

  # Escopos para facilitar a filtragem
  scope :between_dates, ->(start_date, end_date) { where(entry_date: start_date..end_date) if start_date.present? && end_date.present? }
  scope :by_transaction_type, ->(type) { where(transaction_type: type) if type.present? && %w[revenue expense].include?(type) }
  scope :by_category, ->(category) { where('LOWER(category) LIKE ?', "%#{category.downcase}%") if category.present? }
  scope :by_project, ->(project_id) { where(project_id: project_id) if project_id.present? }

  # Mapeamento para o campo transaction_type para exibição na UI
  def self.transaction_type_options
    [
      [I18n.t(:label_cash_flow_revenue), 'revenue'],
      [I18n.t(:label_cash_flow_expense), 'expense']
    ]
  end

  def self.available_categories
    order(:category).distinct.pluck(:category)
  end

  def transaction_type_label
    I18n.t("label_cash_flow_#{transaction_type}")
  end
end