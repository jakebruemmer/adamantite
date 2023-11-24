# frozen_string_literal: true

module Adamantite
  module GUI
    module Screen
      class SetMasterPasswordScreen
        include Glimmer::LibUI::CustomWindow

        option :set_master_password_request

        body do
          window('Adamantite - Create Master Password', 450, 150) do
            margined true
            vertical_box do
              form do
                password_entry do
                  label 'Master Password'
                  text <=> [set_master_password_request, :new_master_pw]
                end
                password_entry do
                  label 'Master Password Confirmation'
                  text <=> [set_master_password_request, :new_master_pw_confirmation]
                end
              end
              button('Set Master Password') do
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
              end
            end
          end
        end
      end
    end
  end
end
