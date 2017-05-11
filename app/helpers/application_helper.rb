module ApplicationHelper
  include BootstrapOverrides

  def current_user
    current_admin || current_account
  end

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
