require "json"
require "csv"

require "active_support/core_ext/hash"

cards = JSON.parse(
  File.read(File.expand_path("../../data/wallaby_cards.json", __FILE__))
)

banks_we_want = [
  "American Express",
  "Bank of America",
  "Barclays",
  "Capital One",
  "Chase",
  "Citibank",
  "Diners Club",
  "Discover",
  "SunTrust",
  "TD Bank",
  "US Bank",
  "Wells Fargo",
]

table = []
# headers:
table << [ "Wallaby ID", "Bank", "Name", "Network", "Currencies", "Annual Fee" ]

CSV.open(
  File.expand_path("../../data/selected_wallaby_cards.csv", __FILE__),
  "w"
) do |csv|
  cards.select do |c|
    c["bank"] &&  banks_we_want.include?(c["bank"]["name"])
  end.sort do |c1, c2|
    if (result = (c1[1] <=> c2[1])) == 0   # bank
      if (result = (c1[2] <=> c2[2])) == 0 # name
        result = c1[3] <=> c2[3]  # network
      end
    end
    result
  end.each do |c|
    csv << [
      c["id"],
      c["bank"]["name"],
      c["name"],
      c["network"]["name"],
      c["reward_units"].map { |ru| ru["name"] }.join(", "),
      ("$%.2f" % (c["fee_annual"] || 0)),
    ]
  end
end
