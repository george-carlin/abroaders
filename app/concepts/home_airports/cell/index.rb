module HomeAirports
  module Cell
    # model = a collection of Airports
    class Index < Abroaders::Cell::Base
      private

      def link_to_edit_home_airports
        link_to(
          'Edit airports',
          edit_home_airports_path,
          class: 'btn btn-primary',
        )
      end
    end
  end
end
