require "file_utils/file_utils"

include Adamantite::FileUtils

module Adamantite
  module Base
    class Adamantite

      attr_reader :authenticated, :master_password, :master_password_salt

      OPSLIMIT = 2**20
      MEMLIMIT = 2**24
      DIGEST_SIZE = 64

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
            @stored_passwords = get_stored_pws
            true
          else
            false
          end
        else
          false
        end
      end

      def serialize_master_password(master_password, master_password_confirmation)
        if master_password == master_password_confirmation
          salt = RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
          master_password_hash = RbNaCl::PasswordHash.scrypt(master_password, salt, OPSLIMIT, MEMLIMIT, DIGEST_SIZE)
          write_to_file("master_password_hash", master_password_hash, true)
          write_to_file("master_password_salt", salt, true)
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

      def make_pw_info(username, pw, master_pw, master_pw_salt)
        cipher = OpenSSL::Cipher::AES256.new(:CBC)
        cipher.encrypt
        iv = cipher.random_iv
        cipher.key = Digest::MD5.hexdigest(master_pw + master_pw_salt)
        cipher_text = cipher.update(pw) + cipher.final
        utf8_cipher_text = Base64.encode64(cipher_text).encode('utf-8')
        utf8_iv = Base64.encode64(iv).encode('utf-8')

        {username: username, password: utf8_cipher_text, iv: utf8_iv}
      end

      def decrypt_pw(iv, pw_hash, master_pw, master_pw_salt)
        decrypt_cipher = OpenSSL::Cipher::AES256.new(:CBC)
        decrypt_cipher.decrypt
        iv = Base64.decode64(iv.encode('ascii-8bit'))
        decrypt_cipher.iv = iv
        decrypt_cipher.key = Digest::MD5.hexdigest(master_pw + master_pw_salt)
        decrypt_text = Base64.decode64(pw_hash.encode('ascii-8bit'))
        decrypt_cipher.update(decrypt_text) + decrypt_cipher.final
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