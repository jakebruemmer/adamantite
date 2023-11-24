# frozen_string_literal: true

require 'base/adamantite'

module Adamantite
  module GUI
    module Request

        attr_accessor :adamantite, :master_password, :authenticated

        def authenticate!
          @adamantite = Base::Adamantite.new(master_password)
          @adamantite.authenticate!
          @authenticated = @adamantite.authenticated?
        end
      end
    end
  end
end
