class SplitCardsTable < ActiveRecord::Migration[5.0]
  def change
    create_table :card_applications do |t|
      t.integer  :person_id, null: false, index: true
      t.integer  :offer_id, null: false, index: true
      t.integer  :card_id, index: true
      t.date     :applied_on, null: false
      t.datetime :denied_at
      t.datetime :nudged_at
      t.datetime :called_at
      t.datetime :redenied_at

      t.timestamps null: false

      t.foreign_key :cards, on_delete: :restrict
      t.foreign_key :offers, on_delete: :restrict
      t.foreign_key :people, on_delete: :restrict
    end

    create_table :card_recommendations do |t|
      t.integer  :person_id, null: false, index: true
      t.integer  :card_application_id, index: true
      t.integer  :offer_id, null: false, index: true

      t.datetime :declined_at
      t.datetime :seen_at
      t.datetime :clicked_at
      t.datetime :expired_at
      t.datetime :pulled_at

      t.timestamps null: false

      t.string :decline_reason

      t.foreign_key :people, on_delete: :restrict
      t.foreign_key :card_applications, on_delete: :restrict
      t.foreign_key :offers, on_delete: :restrict
    end

    reversible do |d|
      # TODO migrate the data
    end

    remove_foreign_key :cards, :offers

    remove_column :cards, :offer_id, :integer
    remove_column :cards, :recommended_at, :date
    remove_column :cards, :declined_at, :date
    remove_column :cards, :seen_at, :datetime
    remove_column :cards, :clicked_at, :date
    remove_column :cards, :expired_at, :datetime
    remove_column :cards, :pulled_at, :datetime

    remove_column :cards, :decline_reason, :string

    remove_column :cards, :applied_at, :date
    remove_column :cards, :denied_at, :date
    remove_column :cards, :nudged_at, :date
    remove_column :cards, :called_at, :date
    remove_column :cards, :redenied_at, :date

    rename_column :cards, :opened_at, :opened_on
    change_column_null :cards, :opened_on, false
    rename_column :cards, :closed_at, :closed_on
  end
end
