require "base/editor/password_object_editor"

module Adamantite
  module GUI
    module Form
      class PasswordObjectFormWindow
        include Glimmer::LibUI::CustomWindow

        # This holds the final user produced by the form
        # And, a user can be optionally passed (e.g. `user_form(user: someuser)`) when editing an existing user
        option :password_object, default: nil
        option :on_save, default: lambda { |password_object| }
        option :master_pw
        option :master_pw_salt

        before_body do
          @password_object_editor = Adamantite::Base::Editor::PasswordObjectEditor.new(master_pw, master_pw_salt, password_object)
        end

        body {
          window('Password Form', 50, 50) { |password_object_form_editor|
            margined true

            vertical_box {
              form {
                entry {
                  label 'Website Title'
                  text <=> [@password_object_editor.editable_password_object, :website_title]
                }
                entry {
                  label 'Username'
                  text <=> [@password_object_editor.editable_password_object, :username]
                }

                password_entry {
                  label 'Password'
                  text <=> [@password_object_editor.editable_password_object, :password]
                }
                password_entry {
                  label 'Password Confirmation'
                  text <=> [@password_object_editor.editable_password_object, :password_confirmation]
                }
              }
              horizontal_box {
                stretchy false

                button('Save') {
                  on_clicked do
                    self.password_object = @password_object_editor.save
                    on_save.call(password_object)
                    password_object_form_editor.destroy
                  end
                }

                button('Cancel') {
                  on_clicked do
                    @password_object_editor.cancel
                    password_object_form_editor.destroy
                  end
                }
              }
            }

            on_closing do
              @password_object_editor.cancel
            end
          }
        }
      end
    end
  end
end
