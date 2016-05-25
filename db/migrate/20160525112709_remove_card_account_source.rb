class RemoveCardAccountSource < ActiveRecord::Migration[5.0]
  def change
    # "source" is a redundant column because the source can be determined
    # deterministically from the other columns. (If recommended_at is nil,
    # soruce is 'from_survey'. Else it's 'recommendation')
    remove_index :card_accounts, column: :source
    remove_column :card_accounts, :source, :integer, null: false
    add_index :card_accounts, :recommended_at
  end
end
