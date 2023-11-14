module Adamantite
  module GUI
    module Screen
      class UpdateMasterPasswordScreen
        include Glimmer::LibUI::CustomWindow

        option :update_master_password_request

        body {
          window('Adamantite - Update Master Password', 450, 150) {
            margined true
            vertical_box {
              form {
                password_entry {
                  label 'New Master Password'
                  text <=> [update_master_password_request, :new_master_pw]
                }
                password_entry {
                  label 'New Master Password Confirmation'
                  text <=> [update_master_password_request, :new_master_pw_confirmation]
                }
              }
              button('Update') {
                on_clicked do
                  new_master_pw = update_master_password_request.new_master_pw
                  new_master_pw_confirmation = update_master_password_request.new_master_pw_confirmation
                  success = update_master_password_request.adamantite.update_master_password!(new_master_pw, new_master_pw_confirmation)
                  if success
                    body_root.destroy
                    ::LibUI.quit
                  else
                    update_master_password_request.new_master_pw = ''
                    update_master_password_request.new_master_pw_confirmation = ''
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
