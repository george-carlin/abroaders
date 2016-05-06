class AddSourceToCardAccounts < ActiveRecord::Migration[5.0]
  def change
    CardAccount.transaction do
      add_column :card_accounts, :source, :integer
      add_index :card_accounts, :source

      reversible do |d|
        d.up do
          CardAccount.reset_column_information
          # update_all has to take the direct integer values of the enum,
          # not the pretty string defined in the class

          # Safety check:
          unless CardAccount.sources["from_survey"] == 0 &&
                  CardAccount.sources["recommendation"] == 1
            raise "something's grone wrong, cap'n!"
          end

          CardAccount.where(recommended_at: nil).update_all(source: 0) # from_survey
          CardAccount.where.not(recommended_at: nil).update_all(source: 1) # recommendation
          change_column :card_accounts, :source, :integer, null: false
        end
      end
    end
  end
end
