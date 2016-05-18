require 'job-integration-contrib'
require 'active_record'

configure :development, :test, :staging, :production do
  ENV['RACK_ENV'] ||= 'development'

  config = JobIntegrationContrib::YamlFileLoader.load_file "#{File.dirname(__FILE__)}/database.yml"
  db = config[ENV['RACK_ENV'].to_s]

  ActiveRecord::Base.establish_connection(
    :adapter => db['adapter'],
    :host     => db['host'],
    :username => db['username'],
    :password => db['password'],
    :database => db['database'],
    :encoding => db['encoding']
  )
end