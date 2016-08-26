class RemoveReadinessStatuses < ActiveRecord::Migration[5.0]
  class Person < ActiveRecord::Base
    has_one :readiness_status
    has_one :spending_info
  end

  class ReadinessStatus < ActiveRecord::Base
    belongs_to :person
  end

  class SpendingInfo < ActiveRecord::Base
    belongs_to :person
  end

  def change
    add_column :spending_infos, :ready, :boolean, null: false, default: true
    add_column :spending_infos, :unreadiness_reason, :string

    reversible do |d|
      d.up do
        remove_foreign_key :readiness_statuses, :people

        Person.includes(:readiness_status, :spending_info).find_each do |person|
          readiness_status = person.readiness_status
          if readiness_status.present?
            person.spending_info.update_attributes!(
              ready:              readiness_status.ready,
              unreadiness_reason: readiness_status.unreadiness_reason,
            )
          end
        end
      end

      d.down do
        # Note that rolling back this migration will lose all data related to
        # readiness.
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
