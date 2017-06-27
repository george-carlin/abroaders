module ApplicationHelper
  include BootstrapOverrides

  def title(provided = '')
    if @cell_title
      @cell_title
    elsif provided.present?
      provided
    else
      ''
    end
  end
end
