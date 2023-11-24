# frozen_string_literal: true

module Adamantite
  module GUI
    module Screen
      class ShowScreen
        include Glimmer::LibUI::CustomWindow

        option :password

        body do
          window('Adamantite - Show Password', 400, 100) do
            margined true

            label(password.to_s)
          end
        end
      end
    end
  end
end
