module Adamantite
  module GUI
    module Screen
      class CopyScreen
        include Glimmer::LibUI::CustomWindow

        option :password_title

        body {
          window('Adamantite - Copy Password', 400, 100) {
            margined true
            label("Copied password for #{password_title} to your clipboard.")
          }
        }
      end
    end
  end
end