# frozen_string_literal: true

module Adamantite
  module Model
    module Presenter
      # We are using Object format for presenting passwords in a table  because
      # it is more readable than Array format.
      # Attributes match underscored versions of table columns by convention
      class PasswordPresenter
        BUTTON_EDIT = 'Edit'
        BUTTON_COPY = 'Copy'
        BUTTON_SHOW = 'Show'
        BUTTON_DELETE = 'Delete'
        
        attr_accessor :title, :username
      
        def initialize(website_title, username)
          @title = website_title
          @username = username
        end
        
        def edit
          BUTTON_EDIT
        end
        
        def copy
          BUTTON_COPY
        end
        
        def show
          BUTTON_SHOW
        end
        
        def delete
          BUTTON_DELETE
        end
        
      end
    end
  end
end
