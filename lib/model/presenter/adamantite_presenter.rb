# frozen_string_literal: true

require 'model/presenter/password_presenter'

module Adamantite
  module Model
    module Presenter
      class AdamantitePresenter
        attr_reader :adamantite
        attr_accessor :stored_passwords
        
        def initialize(adamantite)
          @adamantite = adamantite
          @stored_passwords = @adamantite.stored_passwords.map do |stored_password|
            PasswordPresenter.new(stored_password[:website_title], stored_password[:username])
          end
        end
        
        def password_object_for_edit(row)
          website_title = @stored_passwords[row].title
          username = @stored_passwords[row].username
          dir_name = @adamantite.stored_passwords[row][:dir_name]
          password = @adamantite.retrieve_password_info(dir_name, 'password')
          Model::PasswordObject.new(website_title, username, password, password, row, dir_name)
        end
        
        def save_password(password_object)
          updated_stored_password = PasswordPresenter.new(password_object.website_title, password_object.username)
          @stored_passwords[password_object.row_index] = updated_stored_password
          adamantite_stored_password = {
            'dir_name': password_object.dir_name,
            'website_title': password_object.website_title,
            'username': @adamantite.retrieve_password_info(password_object.dir_name, 'username')
          }
          @adamantite.stored_passwords[password_object.row_index] = adamantite_stored_password
        end
        
        def copy_password(row)
          IO.popen('pbcopy', 'w') do |f|
            dir_name = @adamantite.stored_passwords[row][:dir_name]
            f << @adamantite.retrieve_password_info(dir_name, 'password')
          end
        end
        
        def delete_password(row)
          @adamantite.delete_password(@adamantite.stored_passwords[row][:dir_name])
          @stored_passwords.delete_at(row)
        end
        
        def add_password(password_object)
          new_stored_password = PasswordPresenter.new(password_object.website_title, password_object.username)
          @stored_passwords << new_stored_password
        end
        
      end
    end
  end
end
