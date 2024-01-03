# frozen_string_literal: true

require 'model/editor/password_object_editor'

module Adamantite
  module View
    module Form
      class PasswordObjectFormWindow
        include Glimmer::LibUI::CustomWindow

        # This holds the final user produced by the form
        # And, a user can be optionally passed (e.g. `user_form(user: someuser)`) when editing an existing user
        option :password_object, default: nil
        option :on_save, default: ->(password_object) {}
        option :adamantite

        before_body do
          @password_object_editor = Model::Editor::PasswordObjectEditor.new(adamantite, password_object)
        end

        body do
          window('Password Form', 50, 50) do |password_object_form_editor|
            margined true

            vertical_box do
              form do
                entry do
                  label 'Website Title'
                  text <=> [@password_object_editor.editable_password_object, :website_title]
                end
                entry do
                  label 'Username'
                  text <=> [@password_object_editor.editable_password_object, :username]
                end

                password_entry do
                  label 'Password'
                  text <=> [@password_object_editor.editable_password_object, :password]
                end
                password_entry do
                  label 'Password Confirmation'
                  text <=> [@password_object_editor.editable_password_object, :password_confirmation]
                end
              end

              horizontal_box do
                stretchy false

                button('Save') do
                  on_clicked do
                    self.password_object = @password_object_editor.save
                    on_save.call(password_object)
                    password_object_form_editor.destroy
                  end
                end

                button('Cancel') do
                  on_clicked do
                    @password_object_editor.cancel
                    password_object_form_editor.destroy
                  end
                end
              end
            end

            on_closing do
              @password_object_editor.cancel
            end
          end
        end
      end
    end
  end
end
