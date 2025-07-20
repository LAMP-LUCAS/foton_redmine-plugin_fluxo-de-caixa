# frozen_string_literal: true

class AddIssueStatusAuthorToCashFlowEntries < ActiveRecord::Migration[5.2]
  def change
    # Adiciona referência para issues com chave estrangeira apropriada
    add_reference :cash_flow_entries, :issue, foreign_key: { to_table: :issues }, null: true
    
    # Adiciona campo de status com valor padrão
    add_column :cash_flow_entries, :status, :string, limit: 20, null: false, default: 'pending'
    add_index :cash_flow_entries, :status
    
    # Adiciona referência para o autor do lançamento
    add_reference :cash_flow_entries, :author, foreign_key: { to_table: :users }, null: false
    
    # Remove a coluna user_id antiga se ela existir
    remove_column :cash_flow_entries, :user_id if column_exists?(:cash_flow_entries, :user_id)
  end
end
