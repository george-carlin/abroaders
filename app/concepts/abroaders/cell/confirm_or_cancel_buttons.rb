module Abroaders
  module Cell
    class ConfirmOrCancelButtons < Abroaders::Cell::Base
      option :small
      option :id, optional: true
      option :class_name, optional: true

      def show
        content_tag :div, id: id, class: "#{class_name} btn-group" do
          "#{confirm_btn}#{cancel_btn}"
        end
      end

      private

      def cancel_btn
        classes = 'btn btn-default'
        classes << ' btn-sm' if small
        classes << " #{id}_cancel_btn" unless id.nil?
        classes << " #{class_name}_cancel_btn" unless class_name.nil?
        button_tag('Cancel', class: classes)
      end

      def confirm_btn
        classes = 'btn btn-primary'
        classes << ' btn-sm' if small
        classes << " #{id}_confirm_btn" unless id.nil?
        classes << " #{class_name}_confirm_btn" unless class_name.nil?
        button_tag('Confirm', class: classes)
      end
    end
  end
end
