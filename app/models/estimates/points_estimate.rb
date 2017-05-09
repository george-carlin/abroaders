module Estimates
  class PointsEstimate < BaseEstimate
    POINTS = begin
      csv  = File.read(Rails.root.join("lib", "data", "points_estimates.csv"))
      data = CSV.parse(csv)
      data.shift # remove the headers
      data.each_with_object({}) do |row, hash|
        key    = row[0..1]
        points = row.drop(2).map { |p| (p.to_f * 1_000).round }
        hash[key] = {
          "economy"        => { "low" => points[0], "high" => points[1] },
          "business_class" => { "low" => points[2], "high" => points[3] },
          "first_class"    => { "low" => points[4], "high" => points[5] },
        }
      end
    end

    def low
      POINTS[key][class_of_service]["low"] * no_of_passengers * (round_trip? ? 2 : 1)
    end

    def high
      POINTS[key][class_of_service]["high"] * no_of_passengers * (round_trip? ? 2 : 1)
    end

    private

    def key
      [from.region.code, to.region.code]
    end
  end
end
