# frozen_string_literal: true

module Adamantite
  module Model
    module Presenter
      class AdamantitePresenter
        attr_reader :adamantite
        attr_accessor :stored_passwords
        
        def initialize(adamantite)
          @adamantite = adamantite
          # TODO consider storing passwords as hashes instead of arrays to improve code readability
          @stored_passwords = @adamantite.stored_passwords.map do |stored_password|
            [stored_password[:website_title], stored_password[:username], 'Edit', 'Copy', 'Show', 'Delete']
          end
        end
        
        def password_object_for_edit(row)
          website_title = @stored_passwords[row][0]
          username = @stored_passwords[row][1]
          dir_name = @adamantite.stored_passwords[row][:dir_name]
          password = @adamantite.retrieve_password_info(dir_name, 'password')
          Model::PasswordObject.new(website_title, username, password, password, row, dir_name)
        end
        
        def save_password(password_object)
          stored_password = []
          stored_password << password_object.website_title
          stored_password << password_object.username
          stored_password << 'Edit'
          stored_password << 'Copy'
          stored_password << 'Show'
          stored_password << 'Delete'
          @stored_passwords[password_object.row_index] = stored_password
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
          stored_password = []
          stored_password << password_object.website_title
          stored_password << password_object.username
          stored_password << 'Edit'
          stored_password << 'Copy'
          stored_password << 'Show'
          stored_password << 'Delete'
          @stored_passwords << stored_password
        end
      end
    end
  end
end
