class AddOnboardedReadinessToAccount < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :onboarded_readiness, :boolean, default: false, null: false

    reversible do |d|
      d.up do
        accounts_for_update = []
        Account.includes(people: :spending_info).find_each do |account|
          accounts_for_update << account if account.people.all?(&:onboarded_spending?)
        end
        Account.where(id: accounts_for_update.map(&:id)).update_all(onboarded_readiness: true)
      end
    end
  end
end
