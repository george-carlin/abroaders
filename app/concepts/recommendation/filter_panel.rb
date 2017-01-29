class Recommendation
  module FilterPanel
    def self.included(base)
      base.inheritable_attr :title
    end

    def title
      raise(
        NotImplementedError,
        "cells which include Recommendation::FilterPanel must define a method called 'title'",
      )
    end

    def panel(&block)
      content_tag :div, class: 'col-xs-12 col-md-6 filters-large-column' do
        content_tag :div, class: 'panel panel-primary' do
          content_tag(:div, title, class: 'panel-heading') <<
            content_tag(:div, title, class: 'panel-body', &block)
        end
      end
    end
  end
end
