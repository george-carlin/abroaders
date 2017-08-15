module HomeAirports::Cell
  class Survey < Abroaders::Cell::Base
    option :editing, default: false
    option :form

    def title
      'Add Home Airports'
    end

    private

    def body
      cell(Body, model, form: form)
    end

    class Body < Abroaders::Cell::Base
      option :editing, default: false
      option :form

      def submit_path
        editing ? overwrite_home_airports_path : survey_home_airports_path
      end
    end
  end
end
