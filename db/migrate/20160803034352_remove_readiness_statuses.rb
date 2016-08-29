class RemoveReadinessStatuses < ActiveRecord::Migration[5.0]
  class Person < ActiveRecord::Base
    has_one :readiness_status
  end

  class ReadinessStatus < ActiveRecord::Base
    belongs_to :person
  end

  def change
    add_column :people, :ready, :boolean, null: false, default: false
    add_column :people, :unreadiness_reason, :string

    reversible do |d|
      d.up do
        remove_foreign_key :readiness_statuses, :people

        Person.includes(:readiness_status).find_each do |person|
          if person.readiness_status.present? && person.readiness_status.ready?
            person.update_attributes!(ready: true)
          end
        end
      end

      d.down do
        # WARNING: running then rolling back this migration will lose all readiness data
        add_foreign_key :readiness_statuses, :people, on_delete: :cascade
      end
    end

    drop_table :readiness_statuses do |t|
      t.integer  :person_id,  null: false
      t.boolean  :ready,      null: false
      t.string   :unreadiness_reason
      t.timestamps null: false
      t.index :person_id
    end
  end
end
