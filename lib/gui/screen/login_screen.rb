
module PWManager
  module GUI
    module Screen
      class LoginScreen
        include Glimmer::LibUI::CustomWindow

        option :login_request

        body {
          window('Adamantite', 400, 100) {
            margined true

            vertical_box {
              form {
                password_entry {
                  label 'Master Password'
                  text <=> [login_request, :master_password]
                }
              }

              button('Login') {
                on_clicked do
                  login_request.authenticate!
                  # Destroy window if password is correct.
                  if login_request.authenticated
                    body_root.destroy
                    ::LibUI.quit
                  end
                end
              }
            }
          }
        }
      end
    end
  end
end