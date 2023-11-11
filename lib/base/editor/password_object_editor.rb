require "base/password_object"
require "file_utils/file_utils"
require "pw_utils/pw_utils"

module Adamantite
  module Base
    module Editor
      class PasswordObjectEditor
        include FileUtils
        include PWUtils

        # editable_user provides the temporary user object for editing
        attr_reader :editable_password_object

        # initializes a user editor with nil when creating a new user
        # or with an existing user when editing an existing user
        def initialize(master_pw, master_pw_salt, password_object = nil)
          @password_object = password_object || PasswordObject.new
          @master_pw = master_pw
          @master_pw_salt = master_pw_salt
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
          return false unless @password_object.password == @password_object.password_confirmation
          @password_object.website_title = @editable_password_object.website_title
          @password_object.username = @editable_password_object.username
          @password_object.password = @editable_password_object.password
          @password_object.password_confirmation = @editable_password_object.password_confirmation
          pw_info_for_file = make_pw_info(@password_object.username, @password_object.password, @master_pw, @master_pw_salt)
          write_pw_to_file(@password_object.website_title, **pw_info_for_file)
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