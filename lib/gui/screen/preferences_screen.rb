# frozen_string_literal: true

module Adamantite
  module GUI
    module Screen
      class PreferencesScreen
        include Glimmer::LibUI::CustomWindow

        body do
          window('Adamantite - Preferences', 800, 400) do
            margined true
            label('Hi')
          end
        end

      end
    end
  end
end