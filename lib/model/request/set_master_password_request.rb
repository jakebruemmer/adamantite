# frozen_string_literal: true

require 'model/adamantite'

module Adamantite
  module Model
    module Request
      class SetMasterPasswordRequest
        attr_accessor :new_master_pw, :new_master_pw_confirmation, :success

        def set_master_password!
          @success = false
          adamantite = Model::Adamantite.new(@new_master_pw)
          @success = adamantite.serialize_master_password(@new_master_pw, @new_master_pw_confirmation)
        end
      end
    end
  end
end
