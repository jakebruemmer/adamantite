# frozen_string_literal: true

require 'base/adamantite'

module Adamantite
  module GUI
    module Request
      class SetMasterPasswordRequest
        attr_accessor :new_master_pw, :new_master_pw_confirmation, :success

        def set_master_password!
          @success = false
          adamantite = Base::Adamantite.new(@new_master_pw)
          @success = adamantite.serialize_master_password(@new_master_pw, @new_master_pw_confirmation)
        end
      end
    end
  end
end
