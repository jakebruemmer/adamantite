require "file_utils/file_utils"
require "rbnacl"

include Adamantite::FileUtils

module Adamantite
  module Base
    class Adamantite

      attr_reader :authenticated, :master_password, :master_password_salt

      OPSLIMIT = 2**20
      MEMLIMIT = 2**24
      DIGEST_SIZE = 32

      def initialize(master_password)
        @master_password = master_password
        @authenticated = false
      end

      def authenticate!
        if master_password_exists?
          master_password_hash = get_master_password_hash
          master_password_salt = get_master_password_salt
          entered_master_password_hash = generate_master_password_hash(@master_password, master_password_salt)

          if secure_compare(entered_master_password_hash, master_password_hash)
            @authenticated = true
            @master_password_hash = master_password_hash
            @master_password_salt = master_password_salt
            @master_vault_key = get_master_vault_key
            derived_key = RbNaCl::PasswordHash.scrypt(@master_password, @master_password_salt, OPSLIMIT, MEMLIMIT, DIGEST_SIZE)
            @vault = RbNaCl::SimpleBox.from_secret_key(derived_key)
            @stored_passwords = get_stored_pws
            true
          else
            false
          end
        else
          false
        end
      end

      def save_password(website_title, username, password, password_confirmation)
        if password == password_confirmation && authenticated?
          make_password_dir(website_title)
          write_to_file(password_file(website_title, "website_title"), @vault.encrypt(website_title), true)
          write_to_file(password_file(website_title, "username"), @vault.encrypt(username), true)
          write_to_file(password_file(website_title, "password"), @vault.encrypt(password), true)
        end
      end

      def retrieve_password_info(website_title, info_name)
        if authenticated?
          @vault.decrypt(read_file(password_file(website_title, info_name), true))
        end
      end

      def serialize_master_password(master_password, master_password_confirmation)
        if master_password == master_password_confirmation
          master_password_salt = RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
          master_password_hash = RbNaCl::PasswordHash.scrypt(master_password, master_password_salt, OPSLIMIT, MEMLIMIT, DIGEST_SIZE)
          vault_key = RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
          derived_key = RbNaCl::PasswordHash.scrypt(master_password, master_password_salt, OPSLIMIT, MEMLIMIT, DIGEST_SIZE)

          # Use the derived key to encrypt the vault key
          vault = RbNaCl::SimpleBox.from_secret_key(derived_key)
          encrypted_vault_key = vault.encrypt(vault_key)
          write_to_file(password_file("master_password_hash"), master_password_hash, true)
          write_to_file(password_file("master_password_salt"), master_password_salt, true)
          write_to_file(password_file("master_vault_key"), encrypted_vault_key, true)
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

      def generate_master_password_hash(master_password, stored_salt = nil)
        salt = stored_salt.nil? ? RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES) : stored_salt
        RbNaCl::PasswordHash.scrypt(master_password, salt, OPSLIMIT, MEMLIMIT, DIGEST_SIZE)
      end

      def authenticated?
        @authenticated
      end

      private

      # Constant-time comparison to prevent timing attacks
      def secure_compare(a, b)
        return false unless a.bytesize == b.bytesize

        l = a.unpack("C#{a.bytesize}")

        res = 0
        b.each_byte { |byte| res |= byte ^ l.shift }
        res.zero?
      end
    end
  end
end