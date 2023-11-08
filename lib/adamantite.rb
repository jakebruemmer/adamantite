require "glimmer-dsl-libui"
require "bcrypt"
require "openssl"
require "base64"
require "json"
require "io/console"

require "file_utils/file_utils"
require "pw_utils/pw_utils"
require "base/adamantite"

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
    window('Adamantite', 400, 100) {
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
    window('Copy', 400, 100) {
      margined true
      label("Copied password for #{password_title} to your clipboard.")
    }
  }
end

class ShowScreen
  include Glimmer::LibUI::CustomWindow

  option :password

  body {
    window('Show', 400, 100) {
      margined true

      label("#{password}")
    }
  }
end

class UpdateMasterPasswordRequest

  attr_accessor :new_master_pw, :new_master_pw_confirmation, :adamantite_object

  def initialize(adamantite_object)
    @adamantite_object = adamantite_object
  end
end

class UpdateMasterPasswordScreen
  include Glimmer::LibUI::CustomWindow

  option :update_master_password_request

  body {
    window('Adamantite - Update Master Password', 450, 150) {
      margined true
      vertical_box {
        form {
          password_entry {
            label 'New Master Password'
            text <=> [update_master_password_request, :new_master_pw]
          }
          password_entry {
            label 'New Master Password Confirmation'
            text <=> [update_master_password_request, :new_master_pw_confirmation]
          }
        }
        button('Update') {
          on_clicked do
            new_master_pw = update_master_password_request.new_master_pw
            new_master_pw_confirmation = update_master_password_request.new_master_pw_confirmation
            success = update_master_password_request.adamantite_object.update_master_password!(new_master_pw, new_master_pw_confirmation)
            if success
              body_root.destroy
              ::LibUI.quit
            else
              update_master_password_request.new_master_pw = ''
              update_master_password_request.new_master_pw_confirmation = ''
            end
          end
        }
      }
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
      [title, pw_info["username"], 'Copy', 'Show', 'Delete']
    end
    @master_password = login_request.master_password
    @master_password_salt = login_request.master_password_salt
    @adamantite_object = PWManager::Adamantite.new(@master_password)
    @adamantite_object.authenticate!
    @add_password_request = AddPasswordRequest.new(@master_password, @master_password_salt)
  end

  body {
    window('Adamantite', 600, 400) {
      margined true

      vertical_box {
        table {
          text_column('Title')
          text_column('Username')
          button_column('Copy') {
            on_clicked do |row|
              password_title = @stored_passwords[row].first
              pw_info = get_pw_file(password_title)
              stored_pw_selection = decrypt_pw(pw_info["iv"], pw_info["password"], @master_password, @master_password_salt)
              IO.popen('pbcopy', 'w') { |f| f << stored_pw_selection }
              copy_screen(password_title: password_title).show
            end
          }
          button_column('Show') {
            on_clicked do |row|
              pw_info = get_pw_file(@stored_passwords[row].first)
              stored_pw_selection = decrypt_pw(pw_info["iv"], pw_info["password"], @master_password, @master_password_salt)
              show_screen(password: stored_pw_selection).show
            end
          }
          button_column('Delete') {
            on_clicked do |row|
              delete_pw_file(@stored_passwords[row].first)
              @stored_passwords.delete_at(row)
            end
          }

          cell_rows <=> [self, :stored_passwords]

        }
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
                  new_stored_password = [@add_password_request.website_title, @add_password_request.username]
                  new_stored_password << 'Copy'
                  new_stored_password << 'Show'
                  new_stored_password << 'Delete'
                  @stored_passwords << new_stored_password
                  @add_password_request.website_title = ''
                  @add_password_request.username = ''
                  @add_password_request.password = ''
                  @add_password_request.password_confirmation = ''
                end
              end
            }
            button('Update Master Password') {
              on_clicked do
                update_master_password_request = UpdateMasterPasswordRequest.new(@adamantite_object)
                update_master_password_screen(update_master_password_request: update_master_password_request).show
              end
            }
          }
        }
      }
    }
  }
end

AdamantiteApp.launch