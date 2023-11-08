module Adamantite
  module GUI
    module Request
      class SetMasterPasswordRequest

        attr_accessor :new_master_pw, :new_master_pw_confirmation, :success

        def set_master_password!
          @success = false
          if @new_master_pw == @new_master_pw_confirmation
            master_pw_info = generate_master_pw_hash(@new_master_pw)
            write_pw_to_file('master', password: master_pw_info[:master_pw_hash], salt: master_pw_info[:salt])
            @success = true
          end
          @success
        end
      end
    end
  end
end