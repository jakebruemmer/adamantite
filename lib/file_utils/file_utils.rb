module PWManager
	module FileUtils
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

		def pw_file(title)
			File.join(pwmanager_dir, title)
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

		def delete_pw_file(title)
			File.delete(pw_file(title))
		end

		def get_pw_file(title)
			JSON.load_file(pw_file(title))
		end

		def get_master_pw_info
			get_pw_file('master')
		end

		def get_stored_pws
			Dir.entries(pwmanager_dir).filter { |f| ![".", "..", "master"].include?(f) }
		end
	end
end