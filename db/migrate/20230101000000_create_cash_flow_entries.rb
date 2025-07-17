# frozen_string_literal: true

class CreateCashFlowEntries < ActiveRecord::Migration[5.2] # Ajuste a versão do Rails se necessário para seu Redmine
  def change
    create_table :cash_flow_entries do |t|
      t.date :entry_date, null: false
      t.string :description, limit: 255, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :transaction_type, limit: 20, null: false # 'revenue' ou 'expense'
      t.string :category, limit: 100, null: false
      t.references :project, foreign_key: true, null: true # Pode ser nulo
      t.references :user, foreign_key: true, null: false # Não pode ser nulo

      t.timestamps # created_on e updated_on
    end

    add_index :cash_flow_entries, :entry_date
    add_index :cash_flow_entries, :transaction_type
    add_index :cash_flow_entries, :category
  end
end