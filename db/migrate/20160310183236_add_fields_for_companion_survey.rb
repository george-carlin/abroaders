class AddFieldsForCompanionSurvey < ActiveRecord::Migration[5.0]
  def change
    add_column :passengers, :willing_to_apply, :boolean, default: true, null: false
    remove_column :passengers, :time_zone, :string, null: false
    add_column :accounts, :time_zone, :string
    add_column :accounts, :shares_expenses, :boolean, default: false, null: false

    remove_column :passengers, :credit_score,
                                      :integer,                 null: false
    remove_column :passengers, :will_apply_for_loan,
                                      :boolean, default: false, null: false
    remove_column :passengers, :personal_spending,
                                      :integer, default: 0,     null: false
    remove_column :passengers, :business_spending,
                                      :integer, default: 0
    remove_column :passengers, :has_business,
                                      :integer, default: 0,     null: false

    create_table :spending_infos do |t|
      t.integer :passenger_id,                        null: false
      t.integer :credit_score,                        null: false
      t.boolean :will_apply_for_loan, default: false, null: false
      t.integer :personal_spending,   default: 0,     null: false
      t.integer :business_spending,   default: 0
      t.integer :has_business,        default: 0,     null: false

      t.index :passenger_id, unique: true
    end

    add_foreign_key :spending_infos, :passengers, on_delete: :cascade
  end
end
