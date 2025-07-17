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
# frozen_string_literal: true


require 'csv'

require 'csv'

class CashFlowEntriesController < ApplicationController
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
  # View para upload do CSV
  def import_form
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
    @columns = (Setting.plugin_redmine_cash_flow_pro['default_columns'] || %w[entry_date transaction_type amount category description notes])
    custom_projects = (Setting.plugin_redmine_cash_flow_pro['custom_projects'] || []).map(&:to_s)
    @project_id = @query[:project_id].presence || nil

    if @project_id.present? && custom_projects.include?(@project_id)
      # Tabela exclusiva do projeto
  @cash_flow_entries = CashFlowEntry.where(project_id: @project_id).order(entry_date: :desc, created_at: :desc)
    else
      # Tabela global (sem projeto ou não marcado)
  @cash_flow_entries = CashFlowEntry.where(project_id: nil).order(entry_date: :desc, created_at: :desc)
    end

    @cash_flow_entries = @cash_flow_entries.between_dates(@query[:from_date], @query[:to_date])
    @cash_flow_entries = @cash_flow_entries.by_transaction_type(@query[:transaction_type])
    @cash_flow_entries = @cash_flow_entries.by_category(@query[:category])

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
    @cash_flow_entry = CashFlowEntry.new(entry_date: Date.current, user: User.current)
  end

  def create
    @cash_flow_entry = CashFlowEntry.new(cash_flow_entry_params)
    @cash_flow_entry.user = User.current # Garante que o usuário logado seja o criador

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
      :project_id
    )
  end

  def set_filters
    @projects = User.current.projects.active.order(:name)
    @available_categories = CashFlowEntry.available_categories
  end
end