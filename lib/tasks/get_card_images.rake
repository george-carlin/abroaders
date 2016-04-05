namespace :ab do
  desc "download card images from Wallaby's CDN"
  task :get_card_images do
    require "csv"
    require "json"
    require "open-uri"

    data_root = Pathname.new(File.expand_path("../../../lib/data", __FILE__))

    wallaby_data = JSON.parse(File.read(data_root.join("wallaby_cards.json")))
    card_data    = CSV.parse(File.read(data_root.join("selected_wallaby_cards_with_offers.csv")))

    selected_wallaby_ids = card_data.map { |c| c[6].strip }.uniq.sort

    dir = data_root.join("card_images")

    count = 0
    wallaby_data.each do |data|
      id = data["id"]
      # unless selected_wallaby_ids.include?(id)
      #   puts "skipping card #{id}"
      #   next
      # end

      next if File.exists?(dir.join("#{id}.png"))

      puts "downloading image for card #{id}..."
      open(data["image_url"]) do |f|
        File.open(dir.join("#{id}.png"), "wb") do |file|
          file.puts(f.read)
        end
      end
      count += 1
    end

    puts "downloaded #{count} card images"
  end
end
