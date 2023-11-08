module Adamantite
  module GUI
    module Screen
      class SetMasterPasswordScreen
        include Glimmer::LibUI::CustomWindow

        option :set_master_password_request

        body {
          window('Adamantite - Create Master Password', 450, 150) {
            margined true
            vertical_box {
              form {
                password_entry {
                  label 'Master Password'
                  text <=> [set_master_password_request, :new_master_pw]
                }
                password_entry {
                  label 'Master Password Confirmation'
                  text <=> [set_master_password_request, :new_master_pw_confirmation]
                }
              }
              button('Set Master Password') {
                on_clicked do
                  set_master_password_request.set_master_password!
                  if set_master_password_request.success
                    body_root.destroy
                    ::LibUI.quit
                  else
                    set_master_password_request.new_master_pw = ''
                    set_master_password_request.new_master_pw_confirmation = ''
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