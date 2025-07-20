require 'csv'

class CashFlowEntriesController < ApplicationController

  # View para upload do CSV
  def import_form
  end

    # Exportação de lançamentos para CSV
  def export
    @query = params[:query] || {}
    @columns = (Setting.plugin_redmine_cash_flow_pro['default_columns'] || %w[entry_date transaction_type amount category description notes])
    custom_projects = (Setting.plugin_redmine_cash_flow_pro['custom_projects'] || []).map(&:to_s)
    @project_id = @query[:project_id].presence || nil
    if @project_id.present? && custom_projects.include?(@project_id)
      entries = CashFlowEntry.where(project_id: @project_id)
    else
      entries = CashFlowEntry.where(project_id: nil)
    end
    entries = entries.between_dates(@query[:from_date], @query[:to_date])
    entries = entries.by_transaction_type(@query[:transaction_type])
    entries = entries.by_category(@query[:category])
    headers = @columns
    csv_data = CSV.generate(headers: true, col_sep: ',') do |csv|
      csv << headers
      entries.find_each do |entry|
        csv << headers.map { |col|
          case col
          when 'entry_date' then entry.entry_date
          when 'description' then entry.description
          when 'amount' then entry.amount
          when 'transaction_type' then entry.transaction_type
          when 'category' then entry.category
          when 'notes' then ''
          when 'project_id' then entry.project_id
          when 'user_id' then entry.user_id
          when 'created_at' then entry.created_at
          else entry.send(col) rescue ''
          end
        }
      end
    end
    send_data csv_data, filename: "cash_flow_entries_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv", type: 'text/csv'
  end

  # Importação de lançamentos via CSV
  def import
    if request.post? && params[:csv_file].present?
      imported = 0
      errors = []
      CSV.foreach(params[:csv_file].path, headers: true, col_sep: ',') do |row|
        entry = CashFlowEntry.new(
          entry_date: row['entry_date'],
          description: row['description'],
          amount: row['amount'],
          transaction_type: row['transaction_type'],
          category: row['category'],
          project_id: row['project_id'],
          user: User.current
        )
        if entry.save
          imported += 1
        else
          errors << "Linha #{imported + errors.size + 2}: #{entry.errors.full_messages.join(', ')}"
        end
      end
      if errors.empty?
        flash[:notice] = "#{imported} lançamentos importados com sucesso."
      else
        flash[:error] = "Alguns lançamentos não foram importados:\n" + errors.join("\n")
      end
      redirect_to cash_flow_entries_path
    end
  end
  
  before_action :find_cash_flow_entry, only: [:show, :edit, :update, :destroy]
  before_action :authorize_cash_flow
  before_action :set_filters, only: [:index]

  # Garante que admin sempre tem acesso, e usuários permanentes também
  # Garante que admin e usuários permanentes sempre tenham acesso ao fluxo de caixa
  def authorize_cash_flow
    return true if User.current.admin?
    permanent_users = (Setting.plugin_redmine_cash_flow_pro['permanent_users'] || []).map(&:to_i)
    return true if permanent_users.include?(User.current.id)
    begin
      authorize
    rescue ::Unauthorized
      render_403
    end
  end

  def index
    @query = params[:query] || {}
    
    # Inicia com todos os registros ordenados
    @cash_flow_entries = CashFlowEntry.all.order(entry_date: :desc, created_at: :desc)
    
    # Aplica filtros APENAS se os parâmetros estiverem presentes
    if @query[:project_id].present?
      @cash_flow_entries = @cash_flow_entries.where(project_id: @query[:project_id])
    end
    
    if @query[:from_date].present? && @query[:to_date].present?
      @cash_flow_entries = @cash_flow_entries.between_dates(@query[:from_date], @query[:to_date])
    end
    
    if @query[:transaction_type].present?
      @cash_flow_entries = @cash_flow_entries.by_transaction_type(@query[:transaction_type])
    end
    
    if @query[:category].present?
      @cash_flow_entries = @cash_flow_entries.by_category(@query[:category])
    end
    
    if @query[:status].present?
      @cash_flow_entries = @cash_flow_entries.by_status(@query[:status])
    end
    
    if @query[:issue_id].present?
      @cash_flow_entries = @cash_flow_entries.by_issue(@query[:issue_id])
    end
    
    if @query[:author_id].present?
      @cash_flow_entries = @cash_flow_entries.by_author(@query[:author_id])
    end
    
    if @query[:description].present?
      @cash_flow_entries = @cash_flow_entries.by_description(@query[:description])
    end
    
    if @query[:amount_min].present?
      @cash_flow_entries = @cash_flow_entries.by_amount_min(@query[:amount_min])
    end
    
    if @query[:amount_max].present?
      @cash_flow_entries = @cash_flow_entries.by_amount_max(@query[:amount_max])
    end

    # Calcula totais
    @total_entries = @cash_flow_entries.count
    @total_revenue = @cash_flow_entries.where(transaction_type: 'revenue').sum(:amount)
    @total_expense = @cash_flow_entries.where(transaction_type: 'expense').sum(:amount)
    @balance = @total_revenue - @total_expense

    @limit = per_page_option
    @entry_count = @cash_flow_entries.count
    @entry_pages = Paginator.new(@entry_count, @limit, params[:page])
    @offset = @entry_pages.offset
    @cash_flow_entries = @cash_flow_entries.limit(@limit).offset(@offset)
  end

  def new
    @cash_flow_entry = CashFlowEntry.new(entry_date: Date.current, status: 'pending', author: User.current)
  end


  def create
    @cash_flow_entry = CashFlowEntry.new(cash_flow_entry_params)
    @cash_flow_entry.author = User.current

    if @cash_flow_entry.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to cash_flow_entries_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @cash_flow_entry.update(cash_flow_entry_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_to cash_flow_entries_path
    else
      render :edit
    end
  end

  def destroy
    if @cash_flow_entry.destroy
      flash[:notice] = l(:notice_successful_delete)
    else
      flash[:error] = l(:error_unable_to_delete_cash_flow_entry)
    end
    redirect_to cash_flow_entries_path
  end


  # View para upload do CSV
  def import_form
  end

  private

  def find_cash_flow_entry
    @cash_flow_entry = CashFlowEntry.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end


  def cash_flow_entry_params
    params.require(:cash_flow_entry).permit(
      :entry_date,
      :description,
      :amount,
      :transaction_type,
      :category,
      :project_id,
      :status,
      :issue_id
    )
  end


  def set_filters
    @projects = User.current.projects.active.order(:name)
    @available_categories = CashFlowEntry.available_categories
    @available_statuses = CashFlowEntry::STATUSES
    @available_issues = Issue.where(project_id: @projects.map(&:id))
    @available_authors = User.active.order(:login)
  end

  before_action :load_plugin_assets, only: [:index, :import_form]

  private

  def load_plugin_assets
    @plugin_assets_loaded = true
  end
end
