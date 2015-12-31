namespace :ab do
  task add_cards: :environment do
    Card.transaction do

      [# identifier, bank,   name,                 #bp, #brand, #type, #af,   #currency
        ["01-CSPV", "Chase", "Sapphire Preferred", "P", "V", "Credit", 95_00, "Chase",                            ],
        ["01-BAV",  "Chase", "British Airways",    "P", "V", "Credit", 95_00, "British Airways (Executive Club)"  ],
        ["01-SWPV", "Chase", "Southwest Premier",  "P", "V", "Credit", 99_00, "Southwest Airlines (Rapid Rewards)"],
        ["01-FRV",  "Chase", "Freedom Rewards",    "P", "V", "Credit",     0, "Chase"],
        ["01-UEM",  "Chase", "United Explorer",    "P", "M", "Credit", 95_00, "United Airlines (Mileage Plus)" ],
        ["01-SW+V", "Chase", "Southwest Plus",     "P", "V", "Credit", 69_00, "Southwest Airlines (Rapid Rewards)"],
        ["02-CIPM", "Chase", "Ink Plus",           "B", "M", "Credit", 95_00, "Chase"]
      ].each do |attrs|
        Card.create!(
          identifier: attrs[0],
          # bank:       attrs[1] # this attr doesn't exist in the DB yet
          name: attrs[2],
          bp: { "B" => :business, "P" => :personal }.fetch(attrs[3]),
          brand: { "V" => :visa, "M" => :mastercard, "A" => :amex }.fetch(attrs[4]),
          type: attrs[5].downcase.to_sym,
          annual_fee_cents: attrs[6]
          # currency: attrs[7] # doesn't exist yet
        )
      end
    end
  end
end
# Can't bring myself to prettify all these just yet. Get a VA to do it?
# "03-CPSV,Citibank,Platinum Select,P,V,Credit,95_00,American Airlines (AAdvantage),,,03A
# "07-DGA,American Express,Delta Gold,P,A,Credit,95_00,Delta Air Lines (SkyMiles),,,07A
# "08-DGA,American Express,Delta Gold,B,A,Credit,95_00,Delta Air Lines (SkyMiles),,,08C
# "05-ARM,Barclays,Aviator Red,P,M,Credit,89_00,American Airlines (AAdvantage),,,05C
# "02-UEM,Chase,United Explorer,B,V,Credit,95_00,United Airlines (Mileage Plus),,Y,02A,02A-UEM-50/2/90-AB
# "07-DPA,American Express,Delta Platinum,P,A,Credit,195_00,Delta Air Lines (SkyMiles),,,07B,07B-DPA-35/1/90-AB
# "08-ABP,American Express,Business Platinum,B,A,Credit,450_00,08-ABP-40/5/90,Amex (Membership Rewards),Card Apps & Acct 430,,08B,08B-ABP-40/5/90-AB
# "04-CABM,Citibank,AAdvantage,B,M,Credit,95_00,American Airlines (AAdvantage),,,04A
# "07-SPG,American Express,Starwood Preferred Guest,P,A,Credit,95_00,Starwood Hotels,,,07F
# "03-TYPV,Citibank,ThankYou Premier,P,V,Credit,95_00,03-TYPV-50/3/90,Citibank (Thank You Rewards),,,03C,03C-TYPV-50/3/90-AB
# "05-LMM,Barclays,Lufthansa Miles & More,P,M,Credit,89_00,05-LMM-20/FP/90,Lufthansa (Miles and More),,,05B
# "05-AWM,Barclays,Arrival Plus,P,M,Credit,89_00,05-AWM-40/3/90,Barclaycard,,,05A,05A-AWM-40/3/90-AB
# "08-SPG,American Express,Starwood Preferred Guest,B,A,Credit,95_00,Starwood Hotels,,,08D
# "02-SW+V,Chase,Southwest Plus,B,V,Credit,69_00,02-SW+V-50/2/90,Southwest Airlines (Rapid Rewards),,Y
# "09-VCV,Capital One,Venture,P,V,Credit,59_00,Capital One (No Hassle),,,,09-VCV-40/3/90-AB
# "03-EEW,Citibank,Executive Elite World Mastercard,P,M,Credit,450_00,American Airlines (AAdvantage),,,03B,03B-EEW-75/7.5/90-AB
# "01-HVS,Chase,Hyatt Visa Signature,P,V,Credit,75_00,Hyatt Gold Passport,,Y,,01E-HVS-2FN/1/90-AB
# "01-MRP,Chase,Marriott Rewards Premier,P,V,Credit,85_00,01-MRP-50/1/90,Marriott Rewards,,Y,,01-MRP-50/1/90-AB
# "07-PRG,American Express,Premier Rewards Gold,P,A,Charge,195_00,07-PRG-50/1/90,Amex (Membership Rewards),,,07G,07G-PRG-50/1/90-AB
# "07-MBP,American Express,Platinum Mercedes Benz,P,A,Credit,475_00,07-MBP-50/3/90,Amex (Membership Rewards),,,07D,07D-MBP-50/3/90-AB
# "02-CIBM,Chase,Ink Bold,B,M,Charge,95_00,Chase
# "09-COP,Capital One,Platinum,P,M,Credit,39_00,,Capital One (No Hassle),Card Apps & Acct 311
# "08-ABG,American Express,Business Gold,B,A,Charge,175_00,Amex (Membership Rewards),,,08A
# "01-IHG,Chase,IHG Rewards,P,V,Credit,49_00,01-IHG-70/1/90,IHG Rewards Club
# "13-UCC,US Bank,Club Carlson,P,V,Credit,75_00,Club Carlson Gold
# "07-APP,American Express,Personal Platinum,P,A,Charge,450_00,Amex (Membership Rewards),,,07C,07C-APP-40/3/90-AB
# "11-ASA,Bank of America,Alaska Airlines,P,V,Credit,75_00,11-ASA-25/AP/0,Alaska Airlines (Mileage Plan)
# "12-ASA,Bank of America,Alaska Airlines,B,V,Credit,75_00,12-ASA-25/FP/90,Alaska Airlines (Mileage Plan)
# "07-EDP,American Express,EveryDay Preferred,P,A,Credit,95_00,07-EDP-15/1/90,Amex (Membership Rewards),,,07E,07E-EDP-15/1/90-AB
# "02-SWPV,Chase,Southwest Premier,B,V,Credit,99_00,02-SWPV-50/2/90,Southwest Airlines (Rapid Rewards),,,02C,02C-SWPV-50/2/90-AB
# "13-PFP,US Bank,Flex Perks,P,,Credit,,,Flex Perks
# "03-CAG,Citibank,AAdvantage Gold,P,V,Credit,,,American Airlines (AAdvantage),Card Apps & Acct 470
# "03-CAB,Citibank,AAdvantage Bronze,P,V,Credit,0_00,,American Airlines (AAdvantage),,,,03-CABM-30/1/90
# "07-HHH,American Express,Hilton Honors,P,,Credit,,,Hilton Honors,Card Apps & Acct 468
# "03-CSM,Citibank,Citi Simplicity,P,Mastercard,Credit,0_00,Card Offer 101,,Card Apps & Acct 595,,,,,w
# "07-AED,American Express,Amex EveryDay,P,A,Credit,0_00,Amex (Membership Rewards),Card Apps & Acct 596
# "11-XXX,Bank of America,Non Rewards Card,P,,,,,,Card Apps & Acct 605
# "09-XXX,Capital One,Non Rewards Card,P,,,,,,Card Apps & Acct 606
# "12-XXX,Bank of America,Non Rewards Card,B,,,,,,Card Apps & Acct 607
# "05-XXX,Barclays,Non Rewards Card,P
# "02-XXX,Chase,Non Rewards Card,B
# "01-XXX,Chase,Non Rewards Card,P,,,,,,,Y
# "04-XXX,Citibank,Non Rewards Card,B,,,,,,Card Apps & Acct 715
# "03-XXX,Citibank,Non Rewards Card,P
# "08-XXX,American Express,Non Rewards Card,B
# "07-XXX,American Express,Non Rewards Card,P
# "13-XXX,US Bank,Non Rewards Card,P
# "02-CICM,Chase,Ink Cash,B
# "03-HHR,Citibank,Hilton Honors Reserve,P,,,,,,Card Apps & Acct 691
# "07-DRA,American Express,Delta Reserve,P
# "10-XXX,Capital One,Spark,B,M,Credit,,,,Card Apps & Acct 432
# "09-VOV,Capital One,Venture One,P,V,Credit,0_00,,Capital One (No Hassle),Card Apps & Acct 730
# "Card 74,Chase,,B,,,,,,,,,03A-CPSV-50/3/90-AB
# ",,,,,,Sum 4855_00
