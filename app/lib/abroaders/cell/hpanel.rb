module Abroaders::Cell
  module Hpanel
    def show
      content_tag(:div, super, class: 'hpanel')
    end

    def panel_body(&block)
      content_tag(:div, class: 'panel-body', &block)
    end

    def panel_heading(&block)
      content_tag(:div, class: 'panel-heading hbuilt', &block)
    end
  end
end
