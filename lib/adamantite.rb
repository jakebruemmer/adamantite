require "glimmer-dsl-libui"
require "bcrypt"
require "openssl"
require "base64"
require "json"
require "io/console"

require "file_utils/file_utils"
require "pw_utils/pw_utils"
require "base/adamantite"
require "gui/screen/login_screen"
require "gui/screen/copy_screen"
require "gui/screen/show_screen"
require "gui/screen/set_master_password_screen"
require "gui/screen/update_master_password_screen"
require "gui/request/login_request"
require "gui/request/add_password_request"
require "gui/request/update_master_password_request"
require "gui/request/set_master_password_request"

include Adamantite::FileUtils
include Adamantite::PWUtils

class AdamantiteApp
  include Glimmer::LibUI::Application

  attr_accessor :add_password_request, :stored_passwords

  before_body do
    if !pw_file_exists?('master')
      set_master_password_request = Adamantite::GUI::Request::SetMasterPasswordRequest.new
      set_master_password_screen(set_master_password_request: set_master_password_request).show
    end

    login_request = Adamantite::GUI::Request::LoginRequest.new
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
    @adamantite_object = Adamantite::Base::Adamantite.new(@master_password)
    @adamantite_object.authenticate!
    @add_password_request = Adamantite::GUI::Request::AddPasswordRequest.new(@master_password, @master_password_salt)
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
                update_master_password_request = Adamantite::GUI::Request::UpdateMasterPasswordRequest.new(@adamantite_object)
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