require "bcrypt"
require "openssl"
require "base64"
require "rbnacl"

require "file_utils/file_utils"

module Adamantite
  module PWUtils
    include Adamantite::FileUtils

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

    def generate_master_pw_hash(master_password)
      salt = RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
      opslimit = 2**20
      memlimit = 2**24
      digest_size = 64
      output_key_material = RbNaCl::PasswordHash.scrypt(master_password, salt, opslimit, memlimit, digest_size)
      master_password_hash = Base64.encode64(output_key_material).encode('utf-8')
      salt_utf8 = Base64.encode64(salt).encode('utf-8')
      {'salt': salt, 'master_pw_hash': master_password_hash}
    end

    def generate_master_pw_comparator(master_password_entry)
      master_password_info = get_master_pw_info
      opslimit = 2**20
      memlimit = 2**24
      digest_size = 64
      output_key_material = RbNaCl::PasswordHash.scrypt(master_password_entry[:salt], salt, opslimit, memlimit, digest_size)
      Base64.encode64(output_key_material).encode('utf-8')
    end
  end
end