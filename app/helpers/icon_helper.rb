module IconHelper

  def sort_icons
    raw(%i[asc desc].map { |dir| fa_icon("sort-#{dir}") }.join)
  end

end
