# frozen_string_literal: true

require 'model/adamantite'

module Adamantite
  module Model
    module Request
      class LoginRequest

        attr_accessor :adamantite, :master_password, :authenticated

        def authenticate!
          @adamantite = Model::Adamantite.new(master_password)
          @adamantite.authenticate!
          @authenticated = @adamantite.authenticated?
        end
      end
    end
  end
end
