# Rails's config option 'raise_on_missing_translations' only applies when `t`
# is called from within views - but we want it to apply everywhere.  (Seems
# like a strange design decision on the part of Rails to limit its scope in
# this way)
#
# Include this module to make `translate`/`t` raise an error if the translation
# is missing and the environment has `raise_on_missing_translations` set to
# true.
#
# Based on https://groups.google.com/forum/#!topic/rubyonrails-core/eCi1iGHjIL8
module I18nWithErrorRaising
  def translate(key, options = {})
    I18n.t(key, options.reverse_merge(raise: ActionView::Base.raise_on_missing_translations))
  end
  alias t translate
end
