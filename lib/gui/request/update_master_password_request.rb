module Adamantite
  module GUI
    module Request
      class UpdateMasterPasswordRequest

        attr_accessor :new_master_pw, :new_master_pw_confirmation, :adamantite_object

        def initialize(adamantite_object)
          @adamantite_object = adamantite_object
        end
      end
    end
  end
end