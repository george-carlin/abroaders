class CreateUserInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :user_infos do |t|
      t.integer :user_id, null: false, index: :unique
      t.string :first_name, null: false
      t.string :middle_names
      t.string :last_name, null: false
      t.string :phone_number, null: false
      t.boolean :text_message, null: false, default: false
      t.boolean :whatsapp, null: false, default: false
      t.boolean :imessage, null: false, default: false
      t.string :time_zone, null: false
      t.integer  :citizenship,                   default: 0,     null: false
      t.integer  :credit_score,                                  null: false
      t.boolean  :will_apply_for_loan,           default: false, null: false
      t.integer  :personal_spending,             default: 0,     null: false
      t.integer  :business_spending,             default: 0
      t.integer  :has_business,                  default: 0,     null: false
      t.boolean  :has_completed_card_survey,     default: false, null: false
      t.boolean  :has_completed_balances_survey, default: false, null: false

      t.foreign_key :users, on_delete: :cascade

      t.timestamps
    end

  end
end
