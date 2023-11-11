module Adamantite
  module Base
    class PasswordObject
      attr_accessor :website_title, :username, :password, :password_confirmation, :row_index

      def initialize(website_title = nil, username = nil, password = nil, password_confirmation = nil, row_index = nil)
        @website_title = website_title
        @username = username
        @password = password
        @password_confirmation = password_confirmation
        @row_index = row_index
      end
    end
  end
end