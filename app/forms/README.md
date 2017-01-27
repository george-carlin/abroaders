# Form Objects

---

## Form Objects are deprecated. Don't add new ones. The existing ones will eventually be phased out and replaced with Reform objects. If you need to edit an existing form object, and your changes are non-trivial, consider removing the form object entirely and replacing it with Reform.

---

Form objects are our own custom abstraction, inspired by
[Code Climate](blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/).
Form objects live under `app/forms` and inherit from `ApplicationForm`.

Form objects are an extra layer in between controllers and models, and are
responsible for **validating** and **persisting** data - two actions which
in a regular rails app are handled by the model layer.

FOs should **not** do anything except validate and persist data. If it's not
related to these two operations, don't put it in a form object

## How do I do it?

1.  Create a new class that inherits from `ApplicationForm`. It will usually
    (but it doesn't *have to*) have a name that ends in `Form` (for example
    it could have a name that ends in `Survey`. Define the attributes that the
    form has using Virtus. There should generally be a one-to-one
    correspondence with the class's attributes and the fields on the form in
    the web page:

        class WidgetForm < ApplicationForm
          attribute :name,    String
          attribute :count,   Integer
          attribute :account, Account
        end

    (Like other `Application*` classes (`ApplicationRecord`, `ApplicationJob`
    etc), `ApplicationForm` should never be instantiated directly; we only care
    about its subclasses.)

2.  Add validations if you need them, and define a (private) method called
    `#persist!` that assumes your data is valid and saves everything to the DB
    using our regular ActiveRecord models:

        class WidgetForm < ApplicationForm
          # ...

          validates :name,  presence: true
          validates :count, numericality: { greater_than_or_equal_to: 1 }

          private

          def persist!
            account.widgets.create!(
              name:  name.strip,
              count: count,
            )
          end
        end

    `persist!` assumes that the data is valid, so if it's not then the method
    should fail noisily: use bang methods (`save!`,  `create!`, etc) unless you
    have a good reason not to.

    `persist!` is also the place to massage or cast any data before saving if
    you need to (like how in the above example I call `strip` on `name` before
    I save it).

3.  Form objects quack like an ActiveRecord model, which means you can use them
    in your views and controllers in the manner you're used to:

        # widgets_controller.rb

        def new
          @widget = WidgetForm.new(account: current_account)
        end

        def create
          @widget = WidgetForm.new(account: current_account)
          if @widget.update_attributes(widget_params)
            # handle success
          else
            # handle error
          end
        end

        private

        def widget_params
          params.require(:widget).permit(:name, :count)
        end

        # views/widgets/new.html.erb

        <% form_for @widget do |f| %>
          <%= f.text_field   :name %>
          <%= f.number_field :count %>

          <% f.submit %>
        <% end %>

    Note that `form_for` will generate a route based on what it finds at
    `WidgetForm.model_name`, which is provided by `ActiveModel::naming`.
    However, since your route probably doesn't, and shouldn't, include the word
    'form', you'll need to override `WidgetForm.name` so that `model_name`
    generates the right route key:

        class WidgetForm < ApplicationForm
          # ...

          # This will work if in your routes file you have `resources :widgets`
          def self.name
            "Widget"
          end
        end

## Why use form objects? Why not use the model layer like a normal person?

1. ActiveRecord is already a bloated monolith and tries to do too many things
   at once. Moving validations and persistence into a separate layer is a nice
   separation of concerns and more closely follows the Single Responsibility
   Principle.
2. Form objects decouple the view layer from the model layer. With a form
   object the views and form builders don't know or care about the database
   schema; they only care about the attributes of the form object, which can be
   whatever we like. This lets us put 'virtual' attributes into our form
   without having to edit the underlying ActiveRecord model.
3. Following on from the above, form objects are also a nice and clean way
   to update/create multiple database entries with a single form. See
   `SpendingSurvey` for one example of this - `SpendingSurvey#persist!`
   creates a `SpendingInfo` and also updates the spending info's `Person`.
4. Sometimes a record can be updated from multiple different places within the
   application, but we might want different validations at each point (e.g.
   there might be an attribute which isn't required on `create` but must then
   be provided later on a different form.) The 'Rails Way' is turn your
   model validations into a mess of `if: -> { condition }`s and `on: :creates`.
   Form objects abstract this away by letting you use multiple form
   objects for the same model (e.g. we currently have `EditTravelPlanForm`
   and `NewTravelPlanForm`) and putting different validations in each place.

## Things not to do

1. Don't do other things like sending emails or calling external APIs within
   `#persist!`. Those are responsibilities of the controller.
2. Don't touch the database anywhere except from within `#persist!`
3. Don't use `attr_reader`, `attr_accessor` etc unless you have a good reason
   to. Stick with `attribute :name, Class`, which is provided by the gem
   Virtus.
4. Don't start a form object's name with `Create` or `Update`. Use `New` and
   `Edit` instead.
5. Don't wrap the code inside `persist!` in a transaction. That's already
   being handled in the superclass.

## A quick gotcha

`ApplicationForm` includes `ActiveModel::Validations`, which is what lets us
write lines like `validate :name, presence: true`. However,
`ActiveModel::Validations` doesn't include a validator to check that an
attribute is *unique*. This is because `validates_uniqueness_of` is
fundamentally different from the other regular validations that ship with
Rails, as it makes a database-query and thus requires a DB-backed model, which
is outside the scope of `ActiveModel`.

So if you want to add a uniqueness validation to a form object, you need to
write it yourself. Here's an example of how we're doing it in the `SignUp` form
object:

    class SignUp < ApplicationForm
      attribute :email,      String

      # ...

      validate :email_is_unique, if: "email.present?"

      # ...

      private

      # ActiveModel::Validations doesn't provide validates_uniqueness_of, so
      # we have to do it ourselves:
      def email_is_unique
        if Account.exists?(email: email.downcase) || Admin.exists?(email: email.downcase)
          errors.add(:email, :taken)
        end
      end
    end
