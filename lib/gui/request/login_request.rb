module Adamantite
  module GUI
    module Request
      class LoginRequest

        attr_accessor :master_password, :master_password_salt, :authenticated

        def authenticate!
          user_master_pw_info = get_master_pw_info
          master_pw_hash = user_master_pw_info['password']
          master_pw_salt = user_master_pw_info['salt']
          master_pw_comparator = generate_master_pw_comparator(master_pw_hash)

          if master_pw_comparator == master_password + master_pw_salt
            @authenticated = true
            @master_password = master_password
            @master_password_salt = master_pw_salt
          end
        end
      end
    end
  end
end