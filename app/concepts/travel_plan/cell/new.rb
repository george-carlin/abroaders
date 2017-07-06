module TravelPlan::Cell
  # @!method self.call(travel_plan, form: form)
  class New < Abroaders::Cell::Base
    subclasses_use_parent_view!

    option :form

    def title
      'Add a Travel Plan'
    end

    private

    def cos_checkboxes(f)
      classes = %w[economy premium_economy business_class first_class]
      cell(COSCheckbox, collection: classes, f: f)
    end

    def errors
      cell(Abroaders::Cell::ValidationErrorsAlert, form)
    end

    def types(f)
      cell(TypeRadio, collection: TravelPlan::Type.values, f: f)
    end

    class COSCheckbox < Abroaders::Cell::Base
      option :f

      def show
        <<-HTML
          <div class="col-xs-6">
            <div class="form-group">
              #{labelled_check_box}
            </div>
          </div>
        HTML
      end

      private

      def labelled_check_box
        <<-HTML
          <label for="travel_plan_accepts_#{model}">
        #{f.check_box("accepts_#{model}")} &nbsp; #{model.titleize} &nbsp;
          </label>
        HTML
      end
    end

    class TypeRadio < Abroaders::Cell::Base
      option :f

      def show
        <<-HTML
          <label class="type-radio">
            #{t("activerecord.attributes.travel_plan.types.#{model}")}
            &nbsp;
            #{radio}
          </label>
        HTML
      end

      private

      def radio
        f.radio_button(:type, model, checked: model == f.object.type)
      end
    end
  end
end
