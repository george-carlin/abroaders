# Presenters

Presenters control how models and data get displayed to users in view
templates. They're based on [this article](http://nithinbekal.com/posts/rails-presenters/)

## What's the Point?

Say you have a model called `Widget`, and Widgets have a type, a value, and an
icon (an image stored in a paperclip attachment). If you want to display the
widget in a view, you could write something like this:

```
<%= image_tag(widget.icon) %>
<span><%= widget.type.humanize.capitalize %></span>
<span><%= number_to_currency(widget.value) %></span>

<%= link_to "Update widget", widget_path(widget), class: "update-widget-link" %>
```

This is bit verbose, and what if you're displaying widget data in multiple
views throughout the app? You don't want to have to write e.g.
`number_to_currency` every single time you want to display a value.

You could move some of the logic into `Widget` itself:

```
class Widget < ApplicationRecord
  ...
  def type_name
    type.humanize.capitalize
  end
end
```

But this breaks separation of concerns, because the model layer shouldn't
care how data is *displayed*.

You could extract logic to a helper:

```
module WidgetsHelper
  def widget_image_tag(widget)
    image_tag(widget.icon)
  end

  def widget_type(widget)
    widget.type.humanize.capitalize
  end

  ... etc
end

# view:
<%= widget_image_tag(widget) %>
<span><%= widget_type(widget) %></span>
```

But this is verbose, you're defining global methods (global methods are evil!),
you're using repetitive names (prefixing everything with `widget_`), and from
looking at the view you don't know where the helper methods are defined.

Enter presenters. Presenters wrap a model or data and provide an object-oriented
way of handling display logic:


```
class WidgetPresenter < ApplicationPresenter

  def icon
    h.image_tag(icon)
  end

  def type
    super.humanize.capitalize
  end

  def value
    h.number_to_currency(super)
  end

  def link_to_update
    h.link_to "Update widget", h.widget_path(self), class: "update-widget-link"
  end

  ... etc
end

# view:
<% present(widget) do |widget_p| %>
  <%= widget_p.icon %>
  <span><%= widget_p.type %></span>
  <span><%= widget_p.value %></span>
  <%= widget_p.link_to_update %>
<% end
```

## Guidelines

- Presenters inherit from `ApplicationPresenter`.

- Use the `present` or `present_each` methods in views (look at their source
  to see how it works; they're simple) - don't instantiate the presenter
  directly. Give the yielded variable a name like `widget_p` rather than
  calling it `widget` (which would overwrite the outer variable `widget` and
  possible cause subtle bugs.)

