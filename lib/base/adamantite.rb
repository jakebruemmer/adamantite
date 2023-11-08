require "file_utils/file_utils"
require "pw_utils/pw_utils"

include Adamantite::FileUtils
include Adamantite::PWUtils

module Adamantite
  module Base
    class Adamantite

      attr_accessor :authenticated

      def initialize(master_pw)
        @master_pw = master_pw
        @authenticated = false
        @master_pw_exists = pw_file_exists?('master')
      end

      def authenticate!
        return false unless @master_pw_exists
        master_pw_info = get_master_pw_info
        master_pw_hash = master_pw_info['password']
        master_pw_salt = master_pw_info['salt']
        master_pw_comparator = generate_master_pw_comparator(master_pw_hash)

        if master_pw_comparator == @master_pw + master_pw_salt
          @authenticated = true
          @master_pw_hash = master_pw_hash
          @master_pw_salt = master_pw_salt
          @stored_passwords = get_stored_pws
          true
        else
          false
        end
      end

      def update_master_password!(new_master_pw, new_master_pw_confirmation)
        return false unless new_master_pw == new_master_pw_confirmation && @authenticated

        new_master_pw_info = generate_master_pw_hash(new_master_pw)
        new_master_pw_hash = new_master_pw_info[:master_pw_hash]
        new_master_pw_salt = new_master_pw_info[:salt]

        @stored_passwords.each do |stored_password|
          pw_info = get_pw_file(stored_password)
          pw = decrypt_pw(pw_info['iv'], pw_info['password'], @master_pw, @master_pw_salt)
          pw_info_for_file = make_pw_info(pw_info['username'], pw, new_master_pw, new_master_pw_salt)
          write_pw_to_file(stored_password, **pw_info_for_file)
        end

        write_pw_to_file('master', password: new_master_pw_hash, salt: new_master_pw_salt)
        @master_pw_hash = get_master_pw_info
        @master_pw = new_master_pw
        @master_pw_salt = new_master_pw_salt
        true
      end
    end
  end
end