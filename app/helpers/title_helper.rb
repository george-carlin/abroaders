module TitleHelper
  BASE_TITLE = "Abroaders".freeze

  def full_title(page_title = "")
    page_title.empty? ? BASE_TITLE : "#{page_title.strip} | #{BASE_TITLE}"
  end
end
