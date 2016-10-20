class AddReadyOnFieldToPerson < ActiveRecord::Migration[5.0]
  def change
    add_column :people, :ready_on, :date

    reversible do |d|
      d.up do
        Person.reset_column_information
        Person.where(ready: true).each do |person|
          person.update!(ready_on: person.updated_at)
        end
      end
    end
  end
end
