class CreateBanks < ActiveRecord::Migration[5.0]
  def change
    create_table :banks do |t|
      t.string  :name, null: false
      t.integer :personal_code, null: false
      t.string  :personal_phone
      t.string  :business_phone

      t.timestamps
    end

    reversible do |d|
      d.up do
        [
          # comments after each line contain additional data about the bank
          # that we're not doing anything with yet
          [1, 'Chase', '(888) 609-7805', '800 453-9719'],
          [3, 'Citibank', '(800) 695-5171', '800-763-9795'],
          [5, 'Barclays', '866-408-4064', '866-408-4064'],
          # hours: 8am-5pm EST M-F
          [7, 'American Express', '(877) 399-3083', '(877) 399-3083'],
          # when prompted, say 'Application Status'
          [9, 'Capital One', '(800) 625-7866', '(800) 625-7866'],
          # hours (M-F 8-8pm EST)
          [11, 'Bank of America', '(877) 721-9405', '800-481-8277'],
          # when prompted, dial option 3 for 'Application Status'
          [13, 'US Bank', '800 685-7680', '800 685-7680'],
          # hours: 8am-8pm EST (M-F)'
          [15, 'Discover'],
          [17, 'Diners Club'],
          [19, 'SunTrust'],
          [21, 'TD Bank'],
          [23, 'Wells Fargo'],
        ].each do |id, name, personal_phone, business_phone|
          Bank.create!(
            business_phone: business_phone,
            id:             id,
            name:           name,
            personal_code:  id,
            personal_phone: personal_phone,
          )
        end
      end
    end
  end
end
