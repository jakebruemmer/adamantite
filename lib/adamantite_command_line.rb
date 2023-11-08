require "bcrypt"
require "openssl"
require "base64"
require "json"
require "io/console"

require "file_utils/file_utils"
require "pw_utils/pw_utils"

include PWManager::FileUtils
include PWManager::PWUtils

puts "Welcome to Adamantite."

if pw_file_exists?('master')
  user_master_pw_info = get_master_pw_info
  master_pw_hash = user_master_pw_info['password']
  master_pw_salt = user_master_pw_info['salt']

  master_pw = IO::console.getpass("Please enter your master password:")
  master_pw_comparator = BCrypt::Password.new(master_pw_hash)

  while master_pw_comparator != master_pw + master_pw_salt
    puts "Entered password didn't match."
    master_pw = IO::console.getpass("Please enter your master password:")
    master_pw_hash = BCrypt::Password.create(master_pw + user_master_pw_info['salt'])
  end

  puts "Master password successfully entered."
  puts "Here are your stored passwords:"
  get_stored_pws.each_with_index do |pw, index|
    puts "#{index + 1}. #{pw}"
  end

  puts "Would you like to enter another password? (Y/N)"
  response = gets.chomp
  while !["Y", "N"].include?(response)
    puts "Please enter Y or N"
  end

  if response == "Y"
    puts "What do you want to call this password?"
    title = gets.chomp
    puts "What is the username for #{title}?"
    username = gets.chomp
    pw = IO::console.getpass("Enter the password for this site.")
    pw_confirmation = IO::console.getpass("Confirm the password for this site.")

    while pw != pw_confirmation
      puts "Those didn't match, please enter them again."
      pw = IO::console.getpass("Enter the password for this site.")
      pw_confirmation = IO::console.getpass("Confirm the password for this site.")
    end

    pw_info_for_file = make_pw_info(username, pw, master_pw, master_pw_salt)
    write_pw_to_file(title, **pw_info_for_file)
    puts "Successfully stored password for #{title}."

  elsif response == "N"
    puts "Exiting"
  end

  puts "Here are your stored passwords:"
  stored_pws = get_stored_pws
  stored_pws.each_with_index do |pw, index|
    puts "#{index + 1}. #{pw}"
  end

  puts "Enter the number of the password that you would like to retrieve."
  pw_entry = gets.chomp.to_i

  pw_info = get_pw_file(stored_pws[pw_entry - 1])
  stored_pw_selection = decrypt_pw(pw_info["iv"], pw_info['password'], master_pw, master_pw_salt)

  IO.popen('pbcopy', 'w') { |f| f << stored_pw_selection }

  puts "Your password has been copied to your clipboard."

else
  puts "You don't have a master password. Please enter one now."
  master_pw = IO::console.getpass("Enter your master password:")
  master_pw_confirmation = IO::console.getpass("Confirm your master password:")

  while master_pw != master_pw_confirmation
    puts "Those didn't match, please enter them again."
    master_pw = IO::console.getpass("Enter your master password:")
    master_pw_confirmation = IO::console.getpass("Confirm your master password:")
  end

  master_pw_info = generate_master_pw_hash(master_pw)

  write_pw_to_file('master', password: master_pw_info[:master_pw_hash], salt: master_pw_info[:salt])

  puts "Wrote master pw to file."
end
