class PasswordPresenter < ApplicationPresenter
  def recover_form(&block)
    h.form_for self, url: password_path, html: { role: "form" }, &block
  end

  def update_form(&block)
    h.form_for self, url: password_path, method: :put, html: { role: "form" }, &block
  end

  private

  def password_path
    h.password_path(h.resource_name)
  end
end
