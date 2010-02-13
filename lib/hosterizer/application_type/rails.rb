
require 'hosterizer/application_type'

module Hosterizer::ApplicationType::Rails
  extend Hosterizer::ApplicationType

  def self.reject_paths
    @@reject_paths ||= [ /\.\d+$/ ]
    @@reject_paths
  end

  def self.options
    @options ||= {
      :environment => 'production'
    }
  end

  def self.find_applications( ssh, host )
    applications = []

    ssh.exec!( "echo /opt/railsapps/applications/*" ) do |ch, stream, data|
      if stream == :stdout
        applications = data.split( /\s+/ ).
          reject { |path| reject_paths.find { |reject| path.match( reject ) } }.
          inject( {} ) do |app_hash, path|
          application_name = File.split( path ).last
          app_hash[application_name] = {
            :path => path,
            :type => :rails
          }
          app_hash
        end
      end
    end

    applications
  end

  def self.get_app_details( app, info, connection )
    app_details = {}

    cmd = "cat /opt/railsapps/applications/#{app}/current/config/database.yml"
    connection.exec!( cmd ) do |ch, stream, data|
      if stream == :stdout
        yaml = YAML.load( data )
        # Parse the yaml doc for the environment ... er, which one? 'production'?
        info[:db_type] = yaml[ options[:environment] ]['adapter']
        info[:db_host] = yaml[ options[:environment] ]['host']
      end
    end
  end
end

