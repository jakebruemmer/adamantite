require "file_utils/adamantite_file_utils"
require "rbnacl"
require "base64"

module Adamantite
  module Base
    class Adamantite
      include AdamantiteFileUtils

      attr_reader :authenticated, :master_password, :master_password_salt, :stored_passwords

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
            derived_key = rbnacl_scrypt_hash(master_password, master_password_salt)
            @vault = RbNaCl::SimpleBox.from_secret_key(derived_key)
            @stored_passwords = get_stored_pws.map do |stored_password|
              {
                "dir_name": stored_password,
                "website_title": decode_encrypted_utf8_string(stored_password),
                "username": retrieve_password_info(stored_password, "username")
              }
            end
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
          encrypted_file_name_ascii_8bit = @vault.encrypt(website_title)
          dir_name = Base64.urlsafe_encode64(encrypted_file_name_ascii_8bit)
          make_password_dir(dir_name)
          write_to_file(password_file(dir_name, "username"), @vault.encrypt(username), true)
          write_to_file(password_file(dir_name, "password"), @vault.encrypt(password), true)
          dir_name
        end
      end

      def delete_password(password_dir_name)
        FileUtils.remove_entry_secure(password_file(password_dir_name))
      end

      def retrieve_password_info(website_title, info_name)
        if authenticated?
          @vault.decrypt(read_file(password_file(website_title, info_name), true))
        end
      end

      def serialize_master_password(master_password, master_password_confirmation)
        if master_password == master_password_confirmation
          master_password_salt = rbnacl_random_bytes
          master_password_hash = rbnacl_scrypt_hash(master_password, master_password_salt)
          vault_key = rbnacl_random_bytes
          derived_key = rbnacl_scrypt_hash(master_password, master_password_salt)
          vault = RbNaCl::SimpleBox.from_secret_key(derived_key)
          encrypted_vault_key = vault.encrypt(vault_key)
          write_master_info(master_password_hash, master_password_salt, encrypted_vault_key)
          true
        else
          false
        end
      end

      def update_master_password!(new_master_password, new_master_password_confirmation)
        if new_master_password == new_master_password_confirmation && authenticated?
          master_password_salt = rbnacl_random_bytes
          master_password_hash = generate_master_password_hash(new_master_password, master_password_salt)
          vault_key = rbnacl_random_bytes
          derived_key = rbnacl_scrypt_hash(master_password, master_password_salt)
          vault = RbNaCl::SimpleBox.from_secret_key(derived_key)
          encrypted_vault_key = vault.encrypt(vault_key)

          new_password_data = @stored_passwords.map do |stored_password|
            info = {}
            website_title = vault.encrypt(decode_encrypted_utf8_string(stored_password))
            encrypted_file_name_ascii_8bit = @vault.encrypt(website_title)
            dir_name = Base64.urlsafe_encode64(encrypted_file_name_ascii_8bit)
            info["dir_name"] = dir_name
            info["username"] = vault.encrypt(@vault.decrypt(read_file(password_file(stored_password, "username"), true)))
            info["password"] = vault.encrypt(@vault.decrypt(read_file(password_file(stored_password, "password"), true)))
          end

          new_password_data.each do |new_password|
            make_password_dir(new_password["dir_name"])
            write_to_file(password_file(new_password["dir_name"], "username"), new_password["username"], true)
            write_to_file(password_file(new_password["dir_name"], "password"), new_password["password"], true)
          end

          write_master_info(master_password_hash, master_password_salt, encrypted_vault_key)
          @master_password_hash = master_password_hash
          @master_password_salt = master_password_salt
          @master_vault_key = encrypted_vault_key
          @vault = vault
          true
        else
          false
        end
      end

      def generate_master_password_hash(master_password, stored_salt = nil)
        salt = stored_salt.nil? ? rbnacl_random_bytes : stored_salt
        rbnacl_scrypt_hash(master_password, salt)
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

      def rbnacl_random_bytes
        RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
      end

      def rbnacl_scrypt_hash(password, salt)
        RbNaCl::PasswordHash.scrypt(password, salt, OPSLIMIT, MEMLIMIT, DIGEST_SIZE)
      end

      def decode_encrypted_utf8_string(encrypted_string)
        decoded_data = Base64.urlsafe_decode64(encrypted_string)
        @vault.decrypt(decoded_data)
      end

      def write_master_info(master_password_hash, master_password_salt, master_vault_key)
        write_to_file(password_file("master_password_hash"), master_password_hash, true)
        write_to_file(password_file("master_password_salt"), master_password_salt, true)
        write_to_file(password_file("master_vault_key"), encrypted_vault_key, true)
      end
    end
  end
end