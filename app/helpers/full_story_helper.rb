module FullStoryHelper

  def include_full_story_js?
    ENV["ACTIVATE_FULL_STORY"] && \
      eval(ENV["ACTIVATE_FULL_STORY"]) && current_account
  end

end
