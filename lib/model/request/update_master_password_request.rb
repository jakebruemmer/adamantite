# frozen_string_literal: true

module Adamantite
  module Model
    module Request
      class UpdateMasterPasswordRequest
        attr_accessor :new_master_pw, :new_master_pw_confirmation, :adamantite

        def initialize(adamantite)
          @adamantite = adamantite
        end
      end
    end
  end
end
