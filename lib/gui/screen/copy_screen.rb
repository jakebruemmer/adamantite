# frozen_string_literal: true

module Adamantite
  module GUI
    module Screen
      class CopyScreen
        include Glimmer::LibUI::CustomWindow

        option :password_title

        body do
          window('Adamantite - Copy Password', 400, 100) do
            margined true
            label("Copied password for #{password_title} to your clipboard.")
          end
        end
      end
    end
  end
end
