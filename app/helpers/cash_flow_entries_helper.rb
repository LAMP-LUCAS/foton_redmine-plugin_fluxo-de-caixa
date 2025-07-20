# frozen_string_literal: true

module CashFlowEntriesHelper
  # =====================================================
  #  FORMATAÇÃO DE DADOS
  # =====================================================
  
  # Formata o tipo de transação com estilo apropriado
  # @param transaction_type [String] Tipo de transação ('revenue' ou 'expense')
  # @return [String] HTML seguro com o tipo formatado

  def format_transaction_type(transaction_type)
  return ''.html_safe if transaction_type.blank?
  
    content_tag :span, 
                l("transaction_type_#{transaction_type.downcase}"),
                class: "transaction-type-badge #{transaction_type.downcase}",
                style: "border: 1px solid transparent"
  end


  # Formata o status com badge colorido
  # @param status [String] Status do lançamento
  # @return [String] HTML seguro com o status formatado
  def format_status(status)
    return ''.html_safe if status.blank?
    
    content_tag :span, 
                status_label(status),
                class: "status-badge status-#{status}",
                'aria-label': l("label_status_#{status}"),
                style: "border: 1px solid transparent"
  end

  # Formata valores monetários com configurações locais
  # @param amount [Numeric] Valor a ser formatado
  # @param options [Hash] Opções adicionais para formatação
  # @return [String] Valor formatado como moeda
  def format_amount(amount, transaction_type = nil, options = {})
    default_options = {
      unit: Setting.plugin_redmine_cash_flow_pro['default_currency'] || 'R$ ',
      separator: ',',
      delimiter: '.',
      precision: 2
    }
    
    number_to_currency(amount, default_options.merge(options))
  end


  # =====================================================
  #  FILTRO DE DEMANDA
  # =====================================================
  
  # Gera opções para o filtro de demandas
  def issue_filter_options(selected_issues = [])
    issues = Issue.joins(:cash_flow_entries)
                  .where(id: CashFlowEntry.distinct.pluck(:issue_id))
                  .distinct
                  .order(:subject)
    
    options = issues.map do |issue|
      content_tag :div, class: 'issue-select-item' do
        check_box_tag('query[issue_ids][]', issue.id, selected_issues.include?(issue.id.to_s), 
                      id: "issue_#{issue.id}") +
        label_tag("issue_#{issue.id}", "#{issue.tracker.name} ##{issue.id}: #{issue.subject}", 
                  class: 'issue-label')
      end
    end
    
    safe_join(options)
  end

  # =====================================================
  #  MÉTODOS PRIVADOS
  # =====================================================
  private

  def status_label(status)
    l("label_status_#{status}")
  end

  # =====================================================
  #  COLEÇÕES PARA FORMULÁRIOS
  # =====================================================
  
  # Opções de tipos de transação para selects
  # @return [Array<Array>] Array de opções [label, value]
  def transaction_type_collection
    CashFlowEntry.transaction_type_options
  end

  # Coleção de projetos para selects
  # @param projects [Array<Project>] Lista de projetos
  # @return [Array<Array>] Array de opções [name, id] ordenadas
  def project_collection_for_select(projects)
    projects.map { |p| [p.name, p.id] }.sort_by(&:first)
  end

  # Coleção de status para selects
  # @return [Array<Array>] Array de opções [label, value]
  def cash_flow_status_collection
    CashFlowEntry::STATUSES.map do |status|
      [status_label(status), status]
    end
  end

  # =====================================================
  #  MÉTODOS PRIVADOS
  # =====================================================
  private

  # Rótulo traduzido para um status
  # @param status [String] Status do lançamento
  # @return [String] Rótulo traduzido
  def status_label(status)
    l("label_status_#{status}")
  end

  # Rótulo traduzido para um tipo de transação
  # @param transaction_type [String] Tipo de transação
  # @return [String] Rótulo traduzido
  
  def transaction_type_label(transaction_type)
    l("transaction_type_#{transaction_type.downcase}")
  end
end