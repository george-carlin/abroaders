# Models

(Remember: not everything in `app/models` has to be an ActiveRecord model)

## ActiveRecord models

Organise classes like this:

```
class Model < ApplicationRecord
  ## put all `include` and `extend` statements at the very top:
  include MyModule
  extend  AnotherModule

  ## configuration
  devise :database_authenticatable
  self.inheritance_column = :no_sti

  # Attributes
  ## (enum, alias_attribute, virtual attributes, delegate)

  # Validations

  # Callbacks

  # Scopes

  private

end
```

- In general, validations should be kept out of the model file, and put in
  form objects instead.

- Use callbacks sparingly. 90% of the time, it's better to move the logic
  into the controller, a form object, or another class entirely.
