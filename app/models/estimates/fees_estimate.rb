module Estimates
  class FeesEstimate < BaseEstimate
    FEES = begin
      csv  = File.read(Rails.root.join("lib", "data", "fees_estimates.csv"))
      data = CSV.parse(csv)
      data.shift # remove the headers
      data.each_with_object({}) do |row, hash|
        key    = row[0..1]
        points = row.drop(2).map(&:to_i)
        hash[key] = {
          "economy"        => { "low" => points[0], "high" => points[1] },
          "business_class" => { "low" => points[2], "high" => points[3] },
          "first_class"    => { "low" => points[4], "high" => points[5] },
        }
      end
    end

    NON_US_SINGLE_FEES_MIN_USD = 50
    NON_US_SINGLE_FEES_MAX_USD = 125
    NON_US_RETURN_FEES_MIN_USD  = 125
    NON_US_RETURN_FEES_MAX_USD  = 200

    US_TO_US_SINGLE_FEES_USD = 5.60
    US_TO_US_RETURN_FEES_USD = 11.20

    def low
      if us_domestic?
        us_domestic_fee
      elsif us_international?
        us_international_fee(limit: :low)
      else
        non_us_fee(limit: :low)
      end
    end

    def high
      if us_domestic?
        us_domestic_fee
      elsif us_international?
        us_international_fee(limit: :high)
      else
        non_us_fee(limit: :high)
      end
    end

    private

    def column_index(limit:)
      raise unless [:low, :high].include?(limit)
      i = %w[economy business_class first_class].index(class_of_service)
      limit == :low ? 2 * i + 2 : 2 * i + 3
    end

    def non_us_fee(limit:)
      raise unless [:low, :high].include?(limit)
      if limit == :low
        single? ? NON_US_SINGLE_FEES_MIN_USD : NON_US_RETURN_FEES_MIN_USD
      else
        single? ? NON_US_SINGLE_FEES_MAX_USD : NON_US_RETURN_FEES_MAX_USD
      end
    end

    def us_domestic_fee
      single? ? US_TO_US_SINGLE_FEES_USD : US_TO_US_RETURN_FEES_USD
    end

    def us_international_fee(limit:)
      result = international_fees_data(from, to)[class_of_service][limit.to_s]

      if return?
        result += international_fees_data(to, from)[class_of_service][limit.to_s]
      end
      # round to the nearest 5
      (result / 5.0).round * 5 * no_of_passengers
    end

    def international_fees_data(from, to)
      FEES[[from.region.code, to.region.code]]
    end
  end
end
