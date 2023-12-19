# frozen_string_literal: true

require 'base64'
require 'httparty'
require 'rbnacl'

require 'file_utils/adamantite_file_utils'

module Adamantite
  module Base
    class Adamantite
      include AdamantiteFileUtils

      attr_reader :authenticated, :master_password, :master_password_salt, :stored_passwords,
                  :master_license_key, :free_tier

      OPSLIMIT = 2**20
      MEMLIMIT = 2**24
      DIGEST_SIZE = 32
      LICENSE_ACTIVATION_URL = 'https://api.keygen.sh/v1/accounts/c8f50eb9-eb87-4431-a680-d8f181441ef8/licenses/actions/validate-key'

      def initialize(master_password)
        @master_password = master_password
        @authenticated = false
      end

      def authenticate!
        if master_password_exists?
          master_password_salt = get_master_password_salt
          master_encrypted_vault_key = get_master_encrypted_vault_key
          entered_master_password_hash = rbnacl_scrypt_hash(@master_password, master_password_salt)
          vault = rbnacl_box(entered_master_password_hash)

          begin
            @master_vault_key = vault.decrypt(master_encrypted_vault_key)
            @authenticated = true
            @master_password_salt = master_password_salt
            @vault = rbnacl_box(@master_vault_key)
            update_stored_passwords!
            read_license_key! if has_license_key?
            true
          rescue RbNaCl::CryptoError
            false
          end
        else
          false
        end
      end

      def activate_license!(master_license_key)
        return unless authenticated?

        headers = {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json'
        }
        body = {
          'meta': {
            'key': master_license_key,
            'scope': {
              'product': 'bb6542ab-7d74-44d0-b4f5-1fbc39cdeb99'
            }
          }
        }
        res = HTTParty.post(LICENSE_ACTIVATION_URL, headers: headers, body: body.to_json)

        if res['meta']['valid']
          @master_license_key = master_license_key
          @free_tier = res['data']['attributes']['name'] == 'Adamantite Free'
          write_to_file(password_file('master_license_key'), @vault.encrypt(@master_license_key), true)
          true
        end
        licensed?
      end

      def save_password(website_title, username, password, password_confirmation)
        return unless password == password_confirmation && authenticated?

        encrypted_file_name_ascii_8bit = @vault.encrypt(website_title)
        dir_name = Base64.urlsafe_encode64(encrypted_file_name_ascii_8bit)
        make_password_dir(dir_name)
        write_to_file(password_file(dir_name, 'username'), @vault.encrypt(username), true)
        write_to_file(password_file(dir_name, 'password'), @vault.encrypt(password), true)
        update_stored_passwords!
        dir_name
      end

      def delete_password(password_dir_name)
        FileUtils.remove_entry_secure(password_file(password_dir_name))
        update_stored_passwords!
      end

      def retrieve_password_info(website_title, info_name)
        return unless authenticated?

        @vault.decrypt(read_file(password_file(website_title, info_name), true))
      end

      def serialize_master_password(master_password, master_password_confirmation)
        if master_password == master_password_confirmation
          master_password_salt = rbnacl_random_bytes
          master_password_hash = rbnacl_scrypt_hash(master_password, master_password_salt)
          vault_key = rbnacl_random_bytes
          vault = rbnacl_box(master_password_hash)
          encrypted_vault_key = vault.encrypt(vault_key)
          make_pwmanager_dir
          write_master_info(master_password_salt, encrypted_vault_key)
          true
        else
          false
        end
      end

      def update_master_password!(new_master_password, new_master_password_confirmation)
        if new_master_password == new_master_password_confirmation && authenticated?
          new_master_password_salt = rbnacl_random_bytes
          new_master_password_hash = rbnacl_scrypt_hash(new_master_password, new_master_password_salt)
          vault_key = rbnacl_random_bytes
          vault = rbnacl_box(new_master_password_hash)
          encrypted_vault_key = vault.encrypt(vault_key)

          new_password_data = @stored_passwords.map do |stored_password|
            info = {}
            info['website_title'] = stored_password[:website_title]
            info['username'] = retrieve_password_info(stored_password[:dir_name], 'username')
            info['password'] = retrieve_password_info(stored_password[:dir_name], 'password')
            info
          end

          FileUtils.copy_entry(pwmanager_dir, pwmanager_tmp_dir)
          FileUtils.remove_entry_secure(pwmanager_dir)
          @vault = rbnacl_box(vault_key)
          make_pwmanager_dir
          new_password_data.each do |new_password|
            website_title = new_password['website_title']
            username = new_password['username']
            password = new_password['password']
            save_password(website_title, username, password, password)
          end
          FileUtils.remove_entry_secure(pwmanager_tmp_dir)
          write_master_info(new_master_password_salt, encrypted_vault_key)
          @master_password_salt = master_password_salt
          @master_encrypted_vault_key = encrypted_vault_key
          true
        else
          false
        end
      end

      def authenticated?
        @authenticated
      end

      def update_stored_passwords!
        @stored_passwords = get_stored_pws.map do |stored_password|
          {
            'dir_name': stored_password,
            'website_title': decode_encrypted_utf8_string(stored_password),
            'username': retrieve_password_info(stored_password, 'username')
          }
        end
      end

      def licensed?
        !@master_license_key.nil?
      end

      private

      def rbnacl_box(key)
        RbNaCl::SimpleBox.from_secret_key(key)
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

      def write_master_info(master_password_salt, master_vault_key)
        write_to_file(password_file('master_password_salt'), master_password_salt, true)
        write_to_file(password_file('master_encrypted_vault_key'), master_vault_key, true)
      end

      def read_license_key!
        return unless authenticated?

        @master_license_key = @vault.decrypt(get_license_key)
        @free_tier = @master_license_key == '2B1684-DDC9A4-DDDA73-57C45F-910645-V3'
      end
    end
  end
end
