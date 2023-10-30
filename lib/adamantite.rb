require "glimmer-dsl-libui"
require "bcrypt"
require "openssl"
require "base64"
require "json"
require "io/console"

require "file_utils/file_utils"
require "pw_utils/pw_utils"

include PWManager::FileUtils
include PWManager::PWUtils

class LoginRequest

  attr_accessor :master_password, :master_password_salt, :authenticated

  def authenticate!
    user_master_pw_info = get_master_pw_info
    master_pw_hash = user_master_pw_info['password']
    master_pw_salt = user_master_pw_info['salt']
    master_pw_comparator = BCrypt::Password.new(master_pw_hash)

    if master_pw_comparator == master_password + master_pw_salt
      @authenticated = true
      @master_password = master_password
      @master_password_salt = master_pw_salt
    end
  end
end


class LoginScreen
  include Glimmer::LibUI::CustomWindow

  option :login_request

  body {
    window('Adamantite') {
      margined true

      vertical_box {
        form {
          password_entry {
            label 'Master Password'
            text <=> [login_request, :master_password]
          }
        }

        button('Login') {
          on_clicked do
            login_request.authenticate!
            # Destroy window if password is correct.
            if login_request.authenticated
              body_root.destroy
              ::LibUI.quit
            end
          end
        }
      }
    }
  }
end

class CopyScreen
  include Glimmer::LibUI::CustomWindow

  option :password_title

  body {
    window('Copy') {
      margined true
      label("Copied password for #{password_title} to your clipboard.")
    }
  }
end

class ShowScreen
  include Glimmer::LibUI::CustomWindow

  option :password

  body {
    window('Show') {
      margined true

      label("#{password}")
    }
  }
end


class AdamantiteApp
  include Glimmer::LibUI::Application

  STORED_PASSWORDS = get_stored_pws

  before_body do
    login_request = LoginRequest.new

    login_screen(login_request: login_request).show

    if !login_request.authenticated
      exit(0)
    end

    MASTER_PASSWORD = login_request.master_password
    MASTER_PASSWORD_SALT = login_request.master_password_salt
  end

  body {
    window('Adamantite') {
      margined true

      vertical_box {
        STORED_PASSWORDS.each_with_index do |password_title, index|
          horizontal_box {
            label("#{index + 1}. #{password_title}")

            button('Copy') {
              on_clicked do
                pw_info = get_pw_file(password_title)
                stored_pw_selection = decrypt_pw(pw_info["iv"], pw_info['password'], MASTER_PASSWORD, MASTER_PASSWORD_SALT)
                IO.popen('pbcopy', 'w') { |f| f << stored_pw_selection }
                copy_screen(password_title: password_title).show
              end
            }

            button('Show') {
              on_clicked do
                pw_info = get_pw_file(password_title)
                stored_pw_selection = decrypt_pw(pw_info["iv"], pw_info['password'], MASTER_PASSWORD, MASTER_PASSWORD_SALT)
                show_screen(password: stored_pw_selection).show
              end
            }
          }
        end
      }
    }
  }
end

AdamantiteApp.launch