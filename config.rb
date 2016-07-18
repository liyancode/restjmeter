# config.rb
require 'yaml'
#load global config file, CONFIG will be available as global constant
CONFIG = YAML.load_file('config/config.yml')

# listen on all interfaces
set :bind, '0.0.0.0'

# server port, default is 4567 if not explicitly set
set :port, CONFIG["SinatraPort"]

# global constants
DB = Sequel.connect(CONFIG["DataBase_Connection"])