
# Controller responsável pelas configurações do plugin Cash Flow Pro.
# Permite ao admin definir colunas padrão, projetos com tabela própria e usuários com acesso permanente.
# O admin SEMPRE terá acesso total ao plugin, independentemente das configurações.

require 'csv'

class CashFlowSettingsController < ApplicationController
  before_action :find_cash_flow_entry, only: [:show, :edit, :update, :destroy]
  before_action :authorize_cash_flow
  before_action :set_filters, only: [:index]

  # Garante acesso apropriado
  def authorize_cash_flow
    return true if User.current.admin?
    permanent_users = (Setting.plugin_redmine_cash_flow_pro['permanent_users'] || []).map(&:to_i)
    return true if permanent_users.include?(User.current.id)
    authorize(:view_cash_flow, :global)
  end

  def index
    @query = params[:query] || {}
    @cash_flow_entries = CashFlowEntry.all.order(entry_date: :desc, created_at: :desc)
    
    # Aplica filtros usando scopes
    @query.each do |filter, value|
      next if value.blank?
      scope = "by_#{filter}".to_sym
      
      if @cash_flow_entries.respond_to?(scope)
        @cash_flow_entries = @cash_flow_entries.send(scope, value)
      elsif filter == 'from_date' || filter == 'to_date'
        # Tratado separadamente abaixo
      end
    end
    
    # Filtro de data especial
    if @query[:from_date].present? && @query[:to_date].present?
      @cash_flow_entries = @cash_flow_entries.between_dates(@query[:from_date], @query[:to_date])
    end

    # Calcula totais ANTES da paginação
    @total_revenue = @cash_flow_entries.where(transaction_type: 'revenue').sum(:amount)
    @total_expense = @cash_flow_entries.where(transaction_type: 'expense').sum(:amount)
    @balance = @total_revenue - @total_expense

    # Paginação
    @limit = per_page_option
    @entry_count = @cash_flow_entries.count
    @entry_pages = Paginator.new @entry_count, @limit, params['page']
    @offset = @entry_pages.offset
    @cash_flow_entries = @cash_flow_entries.limit(@limit).offset(@offset)
  end

  # Exportação corrigida com todos os filtros
  def export
    @query = params[:query] || {}
    @columns = (Setting.plugin_redmine_cash_flow_pro['default_columns'] || %w[entry_date transaction_type amount category description status])
    
    # Aplica os mesmos filtros do index
    entries = CashFlowEntry.all
    @query.each do |filter, value|
      next if value.blank?
      scope = "by_#{filter}".to_sym
      entries = entries.send(scope, value) if entries.respond_to?(scope)
    end
    
    # Filtro de data
    if @query[:from_date].present? && @query[:to_date].present?
      entries = entries.between_dates(@query[:from_date], @query[:to_date])
    end

    csv_data = CSV.generate(headers: true, col_sep: ';') do |csv|
      csv << @columns.map { |c| l("field_#{c}") }
      
      entries.find_each do |entry|
        csv << @columns.map { |col|
          case col
          when 'entry_date' then I18n.l(entry.entry_date)
          when 'transaction_type' then l("transaction_type_#{entry.transaction_type}")
          when 'status' then l("label_status_#{entry.status}")
          else entry.send(col)
          end
        }
      end
    end
    
    send_data csv_data, 
              filename: "fluxo_caixa_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv", 
              type: 'text/csv; charset=utf-8'
  end

  # Importação simplificada e única
  def import
    if request.post? && params[:csv_file].present?
      imported = 0
      errors = []
      
      CSV.foreach(params[:csv_file].path, headers: true, col_sep: ';') do |row|
        entry = CashFlowEntry.new(
          entry_date: row[l(:field_entry_date)] || Date.current,
          description: row[l(:field_description)] || '',
          amount: row[l(:field_amount)].to_f,
          transaction_type: row[l(:field_transaction_type)] == l(:transaction_type_revenue) ? 'revenue' : 'expense',
          category: row[l(:label_cash_flow_category)] || '',
          status: row[l(:field_status)] || 'pending',
          project_id: Project.where(name: row[l(:field_project)]).pick(:id),
          author: User.current
        )
        
        if entry.save
          imported += 1
        else
          errors << "Linha #{$.}: #{entry.errors.full_messages.join(', ')}"
        end
      end
      
      if errors.empty?
        flash[:notice] = I18n.t('notice_successful_create', count: imported)
      else
        flash[:error] = "Erros na importação:<br>#{errors.join('<br>')}".html_safe
      end
      
      redirect_to cash_flow_entries_path
    else
      render :import_form
    end
  end
  
  # Salva as configurações do plugin
  def update
    # Permite todos os parâmetros recebidos
    new_settings = params[:settings].to_unsafe_h rescue (params[:settings] || {})
    new_settings[:default_columns] ||= []
    new_settings[:custom_projects] ||= []
    new_settings[:permanent_users] ||= []
    new_settings[:categories] ||= []

    # Garante que arrays estejam no formato correto (array de strings)
    new_settings[:default_columns] = Array(new_settings[:default_columns]).map(&:to_s)
    new_settings[:custom_projects] = Array(new_settings[:custom_projects]).reject(&:blank?).map(&:to_s)
    new_settings[:permanent_users] = Array(new_settings[:permanent_users]).reject(&:blank?).map(&:to_s)
    new_settings[:categories] = Array(new_settings[:categories]).reject(&:blank?)

    # Salva as configurações
    Setting.plugin_redmine_cash_flow_pro = Setting.plugin_redmine_cash_flow_pro.merge(new_settings)

    flash[:notice] = l(:notice_successful_update)
    redirect_to cash_flow_settings_path
  end

  private

  # O admin sempre tem acesso total ao plugin
  def require_admin
    unless User.current.admin?
      render_403
      return false
    end
  end
end