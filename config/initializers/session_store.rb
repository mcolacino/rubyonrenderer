# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_app_session',
  :secret      => 'd4c1733dec8c3ae671ffa57bcb1567094b2dca11785651ef70ee5df82dbb02930be8337b39e351bbf7d6fee40de143f4e4f6f2b72f76ac807686db30f7bf07f7'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
