# frozen_string_literal: true

module RedmineCashFlowPro
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag('cash_flow_filters', plugin: 'redmine_cash_flow_pro') +
      javascript_include_tag('cash_flow_filters', plugin: 'redmine_cash_flow_pro')
    end
  end
end
