class AddFieldsForCompanionSurvey < ActiveRecord::Migration[5.0]
  def change
    create_table :spending_infos do |t|
      t.integer :person_id,                           null: false
      t.integer :credit_score,                        null: false
      t.boolean :will_apply_for_loan, default: false, null: false
      t.integer :business_spending_usd, default: nil
      t.integer :has_business,        default: 0,     null: false

      t.index :person_id, unique: true
    end

    add_foreign_key :spending_infos, :people, on_delete: :cascade
  end
end
