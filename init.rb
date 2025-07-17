# frozen_string_literal: true

require 'redmine'

Redmine::Plugin.register :redmine_cash_flow_pro do
  name 'FOTON Fluxo de Caixa'
  author 'LAMP/foton'
  description 'Plugin de fluxo de caixa para Redmine desenvolvido pela comunidade FOTON'
  version '0.0.1'

  # Menu principal (só aparece se o usuário tiver permissão global ou for admin)
  menu :top_menu, 
       :cash_flow_pro,
       { controller: 'cash_flow_entries', action: 'index' },
       caption: :label_cash_flow,
       if: proc { User.current.admin? || User.current.allowed_to?(:view_cash_flow, nil, global: true) }

  # Menu de administração (só aparece para admins)
  menu :admin_menu,
       :cash_flow_settings,
       { controller: 'cash_flow_settings', action: 'index' },
       caption: :label_cash_flow_settings,
       html: { class: 'icon icon-settings' }
  
  # Menu de Projetos (só aparece se o usuário tiver permissão global ou for admin)
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
  #
  # default_columns: colunas padrão exibidas na tabela do fluxo de caixa
  # custom_projects: IDs dos projetos com tabela própria de fluxo de caixa
  # permanent_users: IDs dos usuários com acesso permanente ao fluxo de caixa
  # categories: categorias customizadas
  # show_in_top_menu: exibe ou não o menu principal
  # default_currency: moeda padrão
  settings default: {
    'default_columns' => %w[entry_date transaction_type amount category description notes],
    'custom_projects' => [],
    'permanent_users' => [],
    'categories' => [],
    'show_in_top_menu' => true,
    'default_currency' => 'BRL'
  },
  partial: 'settings/cash_flow_pro_settings'
end

# frozen_string_literal: true


RedmineApp::Application.routes.draw do
  resources :cash_flow_entries
  get 'cash_flow_settings', to: 'cash_flow_settings#index'
  post 'cash_flow_settings', to: 'cash_flow_settings#update'
end
