module Adamantite
  module Base
    class PasswordObject
      attr_accessor :website_title, :username, :password, :password_confirmation, :row_index, :dir_name, :initial_dir_name

      def initialize(website_title = nil, username = nil, password = nil, password_confirmation = nil, row_index = nil, initial_dir_name = nil)
        @website_title = website_title
        @username = username
        @password = password
        @password_confirmation = password_confirmation
        @row_index = row_index
        @initial_dir_name = initial_dir_name
      end
    end
  end
end