require 'inflecto'

module AdminArea
  class Cell < Trailblazer::Cell
    # AdminArea::Cell::HomeAirports::List -> 'home_airports/list'
    def self.view_name
      Inflecto.underscore(s).split('/')[2..-1].join('/')
    end

    def self.prefixes
      ['apps/admin_area/lib/admin_area/views']
    end
  end
end
