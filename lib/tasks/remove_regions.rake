task update_region_codes: :environment do
  CODES = { 20145 => "US", 20149 => "CB", 20156 => "AU", 20146 => "HA", 20148 => "MX",
           20150 => "CA", 20155 => "AS", 20153 => "AF", 20151 => "SA", 20152 => "EU",
           20154 => "ME", 20147 => "AC", }.freeze

  Country.find_each do |country|
    country.update!(region_code: CODES[country.parent_id])
  end

  CODES.each do |(id, code)|
    ApplicationRecord.connection.execute(
      "UPDATE interest_regions SET region_code = '#{code}' WHERE region_id = #{id};",
    )
  end
end

task remove_region_id_data: :environment do
  ApplicationRecord.connection.execute(
    "DELETE FROM destinations WHERE type = 'Region';",
  )
  ApplicationRecord.connection.execute(
    "UPDATE destinations SET parent_id = NULL WHERE type = 'Country';",
  )
end
