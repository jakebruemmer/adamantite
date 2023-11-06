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

class PasswordInformation

  attr_accessor :title

  def initialize
  end

  def set_title(title)
    @title = title
  end
end

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

class AddPasswordRequest

  attr_accessor :website_title, :username, :password, :password_confirmation, :password_saved

  def initialize(master_password, master_password_salt)
    @master_password = master_password
    @master_password_salt = master_password_salt
    @password_saved = false
  end

  def confirm_and_add_password!
    if @password == @password_confirmation
      @password_saved = true
      pw_info_for_file = make_pw_info(@username, @password, @master_password, @master_password_salt)
      write_pw_to_file(@website_title, **pw_info_for_file)
    end
  end
end

class AdamantiteApp
  include Glimmer::LibUI::Application

  attr_accessor :add_password_request, :stored_passwords

  before_body do
    login_request = LoginRequest.new

    login_screen(login_request: login_request).show

    if !login_request.authenticated
      exit(0)
    end

    @stored_passwords = get_stored_pws.map do |title|
      pw_info = get_pw_file(title)
      [title, pw_info["username"]]
    end
    @master_password = login_request.master_password
    @master_password_salt = login_request.master_password_salt
    @add_password_request = AddPasswordRequest.new(@master_password, @master_password_salt)
  end

  body {
    window('Adamantite') {
      margined true

      vertical_box {
        table {
          text_column('Title')
          text_column('Username')

          cell_rows <=> [self, :stored_passwords]
        }
        # @stored_passwords.each_with_index do |password_title, index|
        #   horizontal_box {
        #     label("#{index + 1}. #{password_title}")

        #     button('Copy') {
        #       on_clicked do
        #         pw_info = get_pw_file(password_title)
        #         stored_pw_selection = decrypt_pw(pw_info["iv"], pw_info["password"], @master_password, @master_password_salt)
        #         IO.popen('pbcopy', 'w') { |f| f << stored_pw_selection }
        #         copy_screen(password_title: password_title).show
        #       end
        #     }

        #     button('Show') {
        #       on_clicked do
        #         pw_info = get_pw_file(password_title)
        #         stored_pw_selection = decrypt_pw(pw_info["iv"], pw_info["password"], @master_password, @master_password_salt)
        #         show_screen(password: stored_pw_selection).show
        #       end
        #     }
        #   }
        # end
        vertical_box {
          form {
            entry {
              label 'Website Title'
              text <=> [@add_password_request, :website_title]
            }
            entry {
              label 'Username'
              text <=> [@add_password_request, :username]
            }
            password_entry {
              label 'Password'
              text <=> [@add_password_request, :password]
            }
            password_entry {
              label 'Confirm Password'
              text <=> [@add_password_request, :password_confirmation]
            }
          }
          horizontal_box {
            button('Add Password') {
              on_clicked do
                @add_password_request.confirm_and_add_password!
                if @add_password_request.password_saved
                  @stored_passwords << [@add_password_request.website_title, @add_password_request.username]
                  @add_password_request.website_title = ''
                  @add_password_request.username = ''
                  @add_passsword_request.password = ''
                  @add_password_request.password_confirmation = ''
                end
              end
            }
          }
        }
      }
    }
  }
end

AdamantiteApp.launch