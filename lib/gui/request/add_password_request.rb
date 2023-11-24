# frozen_string_literal: true

module Adamantite
  module GUI
    module Request
      class AddPasswordRequest
        attr_accessor :website_title, :username, :password, :password_confirmation, :password_saved

        def initialize(master_password, master_password_salt)
          @master_password = master_password
          @master_password_salt = master_password_salt
          @password_saved = false
        end

        def confirm_and_add_password!
          return unless @password == @password_confirmation

          @password_saved = true
          pw_info_for_file = make_pw_info(@username, @password, @master_password, @master_password_salt)
          write_pw_to_file(@website_title, **pw_info_for_file)
        end
      end
    end
  end
end
