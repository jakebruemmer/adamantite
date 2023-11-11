# Adamantite

This is my attempt at making a local password manager in Ruby. Inspired by the recent breach at
LastPass and other less recent breaches at other password managers, the purpose of this app is
to create a simple password manager that never shares your stored passwords to another 3rd party.

This comes with obvious downsides. However, it may be preferable to using a service where you
can't see the source code.

# Usage

```
gem install adamantite
```
The gem page for this project can be found here: https://rubygems.org/gems/adamantite

The binary that's installed with the gem will run the GUI. In order to run the command line app,
you'll need to navigate to where the gem is installed on your machine and run that directly.

# Disclaimers

This is a pet project. There are no guarantees at this time that it is actually a secure way to
manage passwords or secrets.
