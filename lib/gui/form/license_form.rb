# frozen_string_literal: true

module Adamantite
  module GUI
    module Screen
      class LicenseForm
        include Glimmer::LibUI::CustomWindow

        option :set_master_license_key_request

        body do
          window('Adamantite - Set License', 600, 150) do
            margined true
            vertical_box do
              horizontal_box do
                form do
                  entry do
                    label 'License - please include hyphens'
                    text <=> [set_master_license_key_request, :master_license_key]
                  end
                end
              end
              horizontal_box do
                button('Set License') do
                  on_clicked do
                    set_master_license_key_request.activate_license!
                    if set_master_license_key_request.master_license_key_activated
                      body_root.destroy
                      ::LibUI.quit
                    else
                      set_master_license_key_request.master_license_key = ''
                    end
                  end
                end
              end
              horizontal_box do
                info = <<-TEXT
                  This window will close if your license is entered successfully. Restart
                  Adamantite to begin using it.
                TEXT
                label(info)
              end
            end
          end
        end
      end
    end
  end
end