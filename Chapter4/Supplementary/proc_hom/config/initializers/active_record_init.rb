# Be sure to restart your server when you modify this file.

require File.expand_path(File.dirname(__FILE__) + "/../../lib/hsqldb.jar")
#ProcHom::Application.config.active_record.pluralize_table_names = false
ProcHom::Application.config.active_record.timestamped_migrations = false

#The available log levels are: :debug, :info, :warn, :error, and :fatal, corresponding to the log level numbers from 0 up to 4 respectively. To change the default log level, use
#config.log_level = :warn # In any environment initializer, or
#Rails.logger.level = 0 # at any time
