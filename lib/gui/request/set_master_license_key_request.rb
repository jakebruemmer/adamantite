# frozen_string_literal: true

module Adamantite
  module GUI
    module Request
      class SetMasterLicenseKeyRequest
        attr_accessor :adamantite, :master_license_key, :master_license_key_activated

        def initialize(adamantite)
          @adamantite = adamantite
          @master_license_key_activated = false
        end

        def activate_license!
          @adamantite.activate_license!(master_license_key)
          @master_license_key_activated = true if @adamantite.licensed?
        end
      end
    end
  end
end
