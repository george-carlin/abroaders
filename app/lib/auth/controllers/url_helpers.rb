module Auth
  module Controllers
    # Example helpers generated for :account:
    #
    #   new_session_path(:account)      => new_account_session_path
    #   session_path(:account)          => account_session_path
    #   destroy_session_path(:account)  => destroy_account_session_path
    #
    #   new_password_path(:account)     => new_account_password_path
    #   password_path(:account)         => account_password_path
    #   edit_password_path(:account)    => edit_account_password_path
    #
    module UrlHelpers
      {
        password: [nil, :new, :edit],
        registration: [nil, :new, :edit, :cancel],
        session: [nil, :new, :destroy],
      }.each do |module_name, actions|
        [:path, :url].each do |path_or_url|
          actions.each do |action|
            action = action ? "#{action}_" : ""
            method = :"#{action}#{module_name}_#{path_or_url}"

            define_method method do |resource_or_scope, *args|
              scope = Devise::Mapping.find_scope!(resource_or_scope)
              main_app.send("#{action}#{scope}_#{module_name}_#{path_or_url}", *args)
            end
          end
        end
      end
    end
  end
end
