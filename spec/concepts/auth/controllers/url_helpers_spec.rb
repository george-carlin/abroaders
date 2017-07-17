require 'rails_helper'

# These specs are horrifically overengineered. I'm sorry
RSpec.describe Auth::Controllers::UrlHelpers do
  include Rails.application.routes.url_helpers
  include described_class

  let(:main_app) { self }
  let(:scopes) do # { account: [:account, Account, Account.new], admin: ... }
    [Account, Admin].each_with_object({}) do |model, h|
      scope = model.to_s.underscore.to_sym
      h[scope] = [scope, model, model.new]
    end
  end

  def get_path(helper_method_name, *args)
    opts = args.extract_options!
    # the 'host' option is necessary to make _url helpers work:
    send(helper_method_name, *args, opts.merge(host: 'example.com'))
  end

  {
    password: [nil, 'new', 'edit'],
    registration: [nil, 'new', 'edit'],
    session: [nil, 'new', 'destroy'],
  }.each do |module_name, actions|
    actions.each do |action|
      %w[path url].each do |path_or_url|
        helper = [action, module_name, path_or_url].compact.join('_')

        example "##{helper}" do
          scopes.each do |scope, args|
            real_path = [action, scope, module_name, path_or_url].compact.join('_')
            # skip if the 'result' route doesn't exist (e.g. new admin registration)
            next unless respond_to?(real_path)
            args.each do |arg|
              expect(get_path(helper, arg)).to eq get_path(real_path)
            end
          end
        end
      end
    end
  end
end
