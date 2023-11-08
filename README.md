# Adamantite

This is my attempt at making a local password manager in Ruby. Inspired by the recent breach at
LastPass and other less recent breaches at other password managers, the purpose of this app is
to create a simple password manager that never shares your stored passwords to another 3rd party.

This comes with obvious downsides. However, it may be preferable to using a service where you
can't see the source code.

# Usage

After installing the required gems, first run the `lib/adamantite_command_line.rb` file to
set your master password. Include the `lib/` directory when you run the file like so:

```
ruby -I path/to/lib/ path/to/lib/adamantite_command_line.rb
```

The `adamantite_command_line.rb` file will run the password manager on the command line and will
prompt you to set your master password the first time you run the file. After setting your master
password, you can then run the native UI component with `lib/adamantite.rb`.

You can also set up a simple desktop shortcut to run the GUI. See the section below for what the
password manager would look like.

# Example Video

https://imgur.com/a/gOg61TV

# Disclaimers

This is a pet project. There are no guarantees at this time that it is actually a secure way to
manage passwords or secrets.
