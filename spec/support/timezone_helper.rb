# Form http://approache.com/blog/testing-rails-across-time-zones/
module TimeZoneHelpers
  extend ActiveSupport::Concern

  def self.randomise_timezone!
    offsets = ActiveSupport::TimeZone.all.group_by(&:formatted_offset)
    zones = offsets[offsets.keys.sample] # Random offset to better vary the time zone differences
    Time.zone = zones.sample # Random zone from the offset (can be just 1st, but let's do random)
    puts "Current rand time zone: #{Time.zone}. Repro: Time.zone = #{Time.zone.name.inspect}"
  end

  module ClassMethods
    def context_with_time_zone(zone, &block)
      context ", in the time zone #{zone}," do
        before do
          @prev_time_zone = Time.zone
          Time.zone = zone
        end
        after { Time.zone = @prev_time_zone }
        self.instance_eval(&block)
      end
    end

    def across_time_zones(step: 8.hours, &block)
      offsets = ActiveSupport::TimeZone.all.group_by(&:utc_offset).sort_by { |off, _zones| off }
      last_offset = -10.days # far enough in the past
      offsets.each do |(current_offset, zones)|
        if (current_offset - last_offset) > step
          last_offset = current_offset
          context_with_time_zone(zones.sample, &block)
        end
      end
    end
  end
end
