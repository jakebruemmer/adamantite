# frozen_string_literal: true

require 'model/password_object'
require 'model/utils/adamantite_file_utils'

module Adamantite
  module Model
    module Editor
      class PasswordObjectEditor
        include Utils::AdamantiteFileUtils

        # editable_user provides the temporary user object for editing
        attr_reader :editable_password_object
        attr_accessor :error_message

        # initializes a user editor with nil when creating a new user
        # or with an existing user when editing an existing user
        def initialize(adamantite, password_object = nil)
          @password_object = password_object || PasswordObject.new
          @adamantite = adamantite
          reset_editable_password_object
        end

        def reset_editable_password_object
          @editable_password_object = PasswordObject.new
          @editable_password_object.website_title = @password_object.website_title
          @editable_password_object.username = @password_object.username
          @editable_password_object.password = @password_object.password
          @editable_password_object.password_confirmation = @password_object.password_confirmation
        end

        # saves editable user data and returns final user to add to DB/File/Array/etc...
        def save
          unless @editable_password_object.password == @editable_password_object.password_confirmation
            self.error_message = 'Password & Confirmation must match!'
            return false
          end

          @password_object.website_title = @editable_password_object.website_title
          @password_object.username = @editable_password_object.username
          @password_object.password = @editable_password_object.password
          @password_object.password_confirmation = @editable_password_object.password_confirmation
          @password_object.dir_name = @adamantite.save_password(@password_object.website_title,
                                                                @password_object.username,
                                                                @password_object.password,
                                                                @password_object.password_confirmation)

          @adamantite.delete_password(@password_object.initial_dir_name) if @password_object.initial_dir_name
          @password_object
        end

        def cancel
          reset_editable_password_object
          nil
        end
      end
    end
  end
end
