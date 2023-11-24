# frozen_string_literal: true

module Adamantite
  module GUI
    module Screen
      class UpdateMasterPasswordScreen
        include Glimmer::LibUI::CustomWindow

        option :update_master_password_request

        body do
          window('Adamantite - Update Master Password', 450, 150) do
            margined true
            vertical_box do
              form do
                password_entry do
                  label 'New Master Password'
                  text <=> [update_master_password_request, :new_master_pw]
                end
                password_entry do
                  label 'New Master Password Confirmation'
                  text <=> [update_master_password_request, :new_master_pw_confirmation]
                end
              end
              button('Update') do
                on_clicked do
                  new_master_pw = update_master_password_request.new_master_pw
                  new_master_pw_confirmation = update_master_password_request.new_master_pw_confirmation
                  pass = update_master_password_request.adamantite.update_master_password!(new_master_pw,
                                                                                           new_master_pw_confirmation)
                  if pass
                    body_root.destroy
                    ::LibUI.quit
                  else
                    update_master_password_request.new_master_pw = ''
                    update_master_password_request.new_master_pw_confirmation = ''
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
