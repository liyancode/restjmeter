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

log_path =CONFIG["System_Log_File"]
if log_path != nil
  LOGGER = Logger.new(log_path)
else
  LOGGER = Logger.new(STDOUT)
end

LOGGERLEVEL = CONFIG["System_Log_Level"]
if LOGGERLEVEL.eql? 'DEBUG'
  LOGGER.level = Logger::DEBUG
elsif LOGGERLEVEL.eql? 'INFO'
  LOGGER.level = Logger::INFO
elsif LOGGERLEVEL.eql? 'WARN'
  LOGGER.level = Logger::WARN
else
  LOGGER.level = Logger::ERROR
end