# frozen_string_literal: true

module CashFlowEntriesHelper
  def format_amount(amount)
    # Usa o helper padrão do Rails/Redmine para moeda
    number_to_currency(amount, unit: Setting.plugin_redmine_cash_flow_pro['default_currency'] || 'R$ ', separator: ',', delimiter: '.')
  end

  def transaction_type_collection
    CashFlowEntry.transaction_type_options.map do |label, value|
      [label, value]
    end
  end

  def project_collection_for_select(projects)
    projects.map { |p| [p.name, p.id] }
  end
end