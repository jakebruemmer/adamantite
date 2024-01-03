# frozen_string_literal: true

require 'glimmer-dsl-libui'

require 'fileutils'
require 'file_utils/adamantite_file_utils'
require 'model/adamantite'
require 'model/password_object'
require 'model/presenter/adamantite_presenter'
require 'model/request/login_request'
require 'model/request/add_password_request'
require 'model/request/update_master_password_request'
require 'model/request/set_master_license_key_request'
require 'model/request/set_master_password_request'
require 'gui/screen/copy_screen'
require 'gui/screen/login_screen'
require 'gui/screen/set_master_password_screen'
require 'gui/screen/show_screen'
require 'gui/screen/update_master_password_screen'
require 'gui/form/license_form'
require 'gui/form/password_object_form_window'

module Adamantite
  class AdamantiteApp
    include Glimmer::LibUI::Application
    include Adamantite::AdamantiteFileUtils

    attr_accessor :add_password_request, :password_presenter

    before_body do
      unless master_password_exists?
        set_master_password_request = Model::Request::SetMasterPasswordRequest.new
        set_master_password_screen(set_master_password_request: set_master_password_request).show
      end

      login_request = Model::Request::LoginRequest.new
      login_screen(login_request: login_request).show

      unless login_request.authenticated
        exit(0)
      end

      @adamantite = login_request.adamantite
      @adamantite_presenter = Model::Presenter::AdamantitePresenter.new(@adamantite)
      # TODO add_password_request does not seem used anywhere... could we delete it?
      @add_password_request = Model::Request::AddPasswordRequest.new(
        @adamantite.master_password,
        @adamantite.master_password_salt
      )
    end

    menu('About') do
      menu_item('Software Information') do
        on_clicked do
          msg_box('For more information please visit https://jakebruemmer.github.io/adamantite/')
        end
      end
      menu_item('Author') do
        on_clicked do
          msg_box('Jake Bruemmer - https://x.com/jakebruemmer')
        end
      end
      # following is needed for Mac to enable easy quitting with CMD+Q shortcut
      quit_menu_item
    end

    body do
      window('Adamantite', 800, 400, true) do
        margined true
        if @adamantite.licensed?
          vertical_box do
            table do
              text_column('Title')
              text_column('Username')
              button_column('Edit') do
                on_clicked do |row|
                  on_save = lambda do |password_object|
                    @adamantite_presenter.save_password(password_object)
                  end
                  password_object = @adamantite_presenter.password_object_for_edit(row)
                  password_object_form_window(adamantite: @adamantite, on_save: on_save, password_object: password_object).show
                end
              end
              button_column('Copy') do
                on_clicked do |row|
                  @adamantite_presenter.copy_password(row)
                  copy_screen(password_title: @adamantite_presenter.stored_passwords[row].first).show
                end
              end
              button_column('Show') do
                on_clicked do |row|
                  dir_name = @adamantite.stored_passwords[row][:dir_name]
                  show_screen(password: @adamantite.retrieve_password_info(dir_name, 'password')).show
                end
              end
              button_column('Delete') do
                on_clicked do |row|
                  @adamantite_presenter.delete_password(row)
                end
              end
              cell_rows <=> [@adamantite_presenter, :stored_passwords]
            end
            horizontal_box do
              stretchy false

              button('Add Password') do
                on_clicked do
                  on_save = lambda do |password_object|
                    @adamantite_presenter.add_password(password_object)
                  end
                  password_object_form_window(adamantite: @adamantite, on_save: on_save).show
                end
              end
              button('Update Master Password') do
                on_clicked do
                  update_master_password_request = Model::Request::UpdateMasterPasswordRequest.new(@adamantite)
                  update_master_password_screen(update_master_password_request: update_master_password_request).show
                end
              end
            end
            horizontal_box do
              stretchy false
              label_text = <<-TEXT
                This is valid Adamantite installation on a #{@adamantite.master_license_tier} license.
              TEXT
              label(label_text)
            end
          end
        else
          vertical_box do
            license_label = <<-TEXT
              No license detected. Please add one to start using Adamantite.
              If you need one, visit https://jakebruemmer.github.io/adamantite/
              for more information.
            TEXT
            label(license_label)
            button('Add License Info') do
              on_clicked do
                set_master_license_key_request = Model::Request::SetMasterLicenseKeyRequest.new(@adamantite)
                license_form(set_master_license_key_request: set_master_license_key_request).show
              end
            end
          end
        end
      end
    end
  end
end
