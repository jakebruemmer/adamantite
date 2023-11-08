module Adamantite
  module GUI
    module Screen
      class ShowScreen
        include Glimmer::LibUI::CustomWindow

        option :password

        body {
          window('Show', 400, 100) {
            margined true

            label("#{password}")
          }
        }
      end
    end
  end
end