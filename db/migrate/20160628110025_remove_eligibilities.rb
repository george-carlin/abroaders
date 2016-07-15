class RemoveEligibilities < ActiveRecord::Migration[5.0]
  class Person < ActiveRecord::Base
    has_one :eligibility
  end

  class Eligibility < ActiveRecord::Base
    belongs_to :person
  end

  def change
    add_column :people, :eligible, :boolean

    reversible do |d|
      d.up do
        remove_foreign_key :eligibilities, :people

        Person.includes(:eligibility).find_each do |person|
          if person.eligibility.present?
            person.update_attributes!(eligible: person.eligibility.eligible)
          end
        end
      end

      d.down do
        Person.where.not(eligible: nil).find_each do |person|
          person.create_eligibility!(eligible: person.eligible)
        end

        add_foreign_key :eligibilities, :people, on_delete: :cascade
      end
    end

    drop_table :eligibilities do |t|
      t.integer  :person_id,  null: false
      t.boolean  :eligible,   null: false
      t.timestamps null: false
      t.index :person_id
    end
  end
end
