# frozen_string_literal: true

require 'redmine'

Redmine::Plugin.register :redmine_cash_flow_pro do
  name 'FOTON Fluxo de Caixa'
  author 'LAMP/foton'
  description 'Plugin de fluxo de caixa para Redmine desenvolvido pela comunidade FOTON'
  version '0.0.1'

  # Hooks do plugin
  require File.expand_path('../lib/redmine_cash_flow_pro/hooks', __FILE__)

  # Menu principal
  menu :top_menu, 
       :cash_flow_pro,
       { controller: 'cash_flow_entries', action: 'index' },
       caption: :label_cash_flow,
       if: proc { User.current.admin? || User.current.allowed_to?(:view_cash_flow, nil, global: true) }

  # Menu de administração
  menu :admin_menu,
       :cash_flow_settings,
       { controller: 'cash_flow_settings', action: 'index' },
       caption: :label_cash_flow_settings,
       html: { class: 'icon icon-settings' }
  
  # Menu de Projetos
  menu :project_menu, :cash_flow_pro, { controller: 'cash_flow_entries', action: 'index' }, 
     caption: :label_cash_flow, param: :project_id, 
     if: proc { |p| User.current.admin? || User.current.allowed_to?(:view_cash_flow, p) }

  # Permissões do plugin
  project_module :cash_flow_pro do
    permission :view_cash_flow, {
      cash_flow_entries: [:index, :show]
    }
    permission :manage_cash_flow_entries, {
      cash_flow_entries: [:new, :create, :edit, :update, :destroy]
    }
  end

  # Configurações do plugin
  settings default: {
    'default_columns' => %w[entry_date transaction_type amount category description notes],
    'custom_projects' => [],
    'permanent_users' => [],
    'categories' => [],
    'show_in_top_menu' => true,
    'default_currency' => 'BRL'
  },
  partial: 'settings/cash_flow_pro_settings'

  # Assets
  plugin_root = File.dirname(__FILE__)
  Rails.application.config.assets.paths << File.join(plugin_root, 'assets', 'stylesheets')
  Rails.application.config.assets.paths << File.join(plugin_root, 'assets', 'javascripts')
  
  Rails.application.config.assets.precompile += %w[
    cash_flow_pro.css
    cash_flow_filters.css
    cash_flow.js
    cash_flow_filters.js
  ]
end

RedmineApp::Application.routes.draw do
  resources :cash_flow_entries do
    collection do
      get 'export'
    end
  end
  
  get 'cash_flow_settings', to: 'cash_flow_settings#index'
  post 'cash_flow_settings', to: 'cash_flow_settings#update'
end