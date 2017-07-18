Updated 14th July:

As of this commit, the test suite is passing! Yay!

Now all I need to do is remove all the unnecesary bullshit that I copied from devise but that I'm not using.

Rubocop is currently failing too.

Action steps:
- move Auth::Mailers::Helpers directly into Auth::Mailer
- settings that can possibly be removed/hardcoded:
    - `omniauth_configs`
    - `clean_up_csrf_token_on_authentication`
    - `router_name`
    - `paranoid`
    - `Auth.mailer_sender`
- Auth::FailureApp and Auth::Mapping seem like candidates for a big simplifying refactor. Also possible Auth::Getter, Auth.setup
- Get rid of `Validatable`; don't included validations in the model.
- grep for all DEVISETODO comments
- grep -ri devise and see what I can remove/simplify replace
- possibly change the code which sets env variables called 'devise.*', but make sure this won't fuck up existing logins.

## Notes on how Devise::Mapping works:

`Devise.mappings` is a simple class variable that stores an ActiveSupport::OrderedHash

`add_mapping` gets called from `devise_for` in the routes, generates the Mapping, adds it to Devise.mappings.

'devise.mapping' gets set as a key in @request.env (I should really figure out how request.env actually works). The value is the mapping object.

`Auth::Mapping.find_scope!` is used all over the place, but I think it's overcomplicated.

Okay, I count 15 uses of find_scope!. *Instances* of mapping are used in:

- FailureApp
- Controllers::Helpers

`Auth.mappings.each_value` is used in 

- sign_in_out.rb
