RSpec::Matchers.define :have_sidebar do
  match { |page| page.has_selector?("#menu") }
  description { "display the sidebar" }
end

RSpec::Matchers.define :have_no_sidebar do
  match { |page| page.has_no_selector?("#menu") }
  description { "not display the sidebar" }
end
