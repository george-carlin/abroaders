class RemoveReadinessStatuses < ActiveRecord::Migration[5.0]
  class Person < ActiveRecord::Base
    has_one :readiness_status
  end

  class ReadinessStatus < ActiveRecord::Base
    belongs_to :person
  end

  def change
    add_column :people, :ready, :boolean
    add_column :people, :unreadiness_reason, :string

    reversible do |d|
      d.up do
        remove_foreign_key :readiness_statuses, :people

        Person.includes(:readiness_status).find_each do |person|
          if person.readiness_status.present?
            person.update_attributes!(ready: person.readiness_status.ready)
          end
          if person.readiness_status.unreadiness_reason.present?
            person.update_attributes!(unreadiness_reason: person.readiness_status.unreadiness_reason)
          end
        end
      end

      d.down do
        Person.where.not(ready: nil).find_each do |person|
          person.create_readiness_status!(ready: person.eligible, unreadiness_reason: person.unreadiness_reason)
        end

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
