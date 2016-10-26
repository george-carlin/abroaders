class RemoveBalanceFksUniquenessValidation < ActiveRecord::Migration[5.0]
  def change
    # remove the existing index and add it back without the uniqueness constraint:
    remove_index :balances, name: :index_balances_on_person_id_and_currency_id
    add_index :balances, [:person_id, :currency_id]
  end
end
