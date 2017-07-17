Updated 14th July:

As of this commit, the test suite is passing! Yay!

Now all I need to do is remove all the unnecesary bullshit that I copied from devise but that I'm not using.

Rubocop is currently failing too.

Action steps:
- Remove unused stuff. Obvious first candidates: commented-out code, the modules/modules like trackable that I'm not using, configurable devise options where I have no reason to not just hard-code it.
- Auth::FailureApp and Auth::Mapping seem like candidates for a big simplifying refactor.
- grep for all DEVISETODO comments
- grep -ri devise and see what I can remove/simplify replace
- possibly change the code which sets env variables called 'devise.*', but make sure this won't fuck up existing logins.

Notes on how Devise::Mapping works:

`Devise.mappings` is a simple class variable that stores an ActiveSupport::OrderedHash

`add_mapping` gets called from `devise_for` in the routes, generates the Mapping, adds it to Devise.mappings.

'devise.mapping' gets set as a key in @request.env (I should really figure out how request.env actually works). The value is the mapping object.

`Auth::Mapping.find_scope!` is used all over the place, but I think it's overcomplicated.
