# frozen_string_literal: true

class Admin::CashFlowSettingsController < ApplicationController
  layout 'admin'
  
  before_action :require_admin
  before_action :find_settings

  def index
    @settings = Setting.plugin_redmine_cash_flow_pro
  end

  def update
    settings = params[:settings] || {}
    
    # Filtra e valida os parâmetros
    settings = settings.permit(:default_currency, :show_in_top_menu, categories: [])
    
    # Atualiza as configurações
    Setting.plugin_redmine_cash_flow_pro = settings.to_h
    
    flash[:notice] = l(:notice_successful_update)
    redirect_to action: 'index'
  end

  private

  def find_settings
    @settings = Setting.plugin_redmine_cash_flow_pro
  end
end
