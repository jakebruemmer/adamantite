# frozen_string_literal: true

module PWManager
  module GUI
    module Screen
      class LoginScreen
        include Glimmer::LibUI::CustomWindow

        option :login_request

        body do
          window('Adamantite - Login', 400, 100) do
            margined true

            vertical_box do
              form do
                password_entry do
                  label 'Master Password'
                  text <=> [login_request, :master_password]
                end
              end

              button('Login') do
                on_clicked do
                  login_request.authenticate!
                  # Destroy window if password is correct.
                  if login_request.authenticated
                    body_root.destroy
                    ::LibUI.quit
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
