
# Controller responsável pelas configurações do plugin Cash Flow Pro.
# Permite ao admin definir colunas padrão, projetos com tabela própria e usuários com acesso permanente.
# O admin SEMPRE terá acesso total ao plugin, independentemente das configurações.
class CashFlowSettingsController < ApplicationController
  before_action :require_admin

  # Exibe o formulário de configurações
  def index
    @settings = Setting.plugin_redmine_cash_flow_pro || {}
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