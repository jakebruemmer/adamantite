require "json"

module Adamantite
	module AdamantiteFileUtils
		def home_dir
			ENV['HOME']
		end

		def pwmanager_dir
			File.join(home_dir, '.pwmanager')
		end

		def pwmanager_dir_exists?
			Dir.exists?(pwmanager_dir)
		end

		def make_pwmanager_dir
			Dir.mkdir(pwmanager_dir)
		end

		def make_password_dir(password_dir_title)
			Dir.mkdir(File.join(pwmanager_dir, password_dir_title))
		end

		def pw_file(title)
			File.join(pwmanager_dir, title)
		end

		def password_file(*args)
			File.join(pwmanager_dir, *args)
		end

		def pw_file_exists?(title)
			File.exists?(pw_file(title))
		end

		def write_pw_to_file(title, **kwargs)
			if !pwmanager_dir_exists?
				make_pwmanager_dir
			end

			File.open(pw_file(title), "w") do |f|
				JSON.dump(kwargs, f)
			end
		end

		def write_to_file(file_name, file_contents, binary)
			if binary
				File.open(file_name, "wb") do |f|
					f.write(file_contents)
				end
			else
				File.open(file_name, "w") do |f|
					f.write(file_contents)
				end
			end
		end

		def read_file(file_name, binary)
			if binary
				File.open(file_name, "rb") do |f|
					f.read
				end
			else
				File.open(file_name, "r") do |f|
					f.read
				end
			end
		end

		def delete_pw_file(title)
			File.delete(pw_file(title))
		end

		def get_pw_file(title)
			JSON.load_file(pw_file(title))
		end

		def get_master_password_info
			get_pw_file('master')
		end

		def get_master_password_hash
			File.open(pw_file("master_password_hash"), "rb") do |f|
				f.read
			end
		end

		def get_master_password_salt
			File.open(pw_file("master_password_salt"), "rb") do |f|
				f.read
			end
		end

		def get_master_vault_key
			File.open(pw_file("master_vault_key"), "rb") do |f|
				f.read
			end
		end

		def get_stored_pws
			excluded_filenames = [".", "..", "master_password_hash", "master_password_salt", "master_vault_key"]
			Dir.entries(pwmanager_dir).filter { |f| !excluded_filenames.include?(f) }
		end

		def master_password_exists?
			pw_file_exists?("master_password_hash") && pw_file_exists?("master_password_salt")
		end
	end
end