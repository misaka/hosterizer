
require 'hosterizer/application'

class Hosterizer::Application::Rails < Hosterizer::Application

  attr_accessor :db_type, :db_host

  auto_discoverable

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
    application_paths = []

    ssh.exec!( "echo /opt/railsapps/applications/*" ) do |ch, stream, data|
      if stream == :stdout
        application_paths.concat data.split( /\s+/ ).
          reject { |path| reject_paths.
          find { |reject| path.match( reject ) } }
      end
    end

    application_paths.map do |path|
      self.new( {
        :name => File.split( path ).last,
        :path => path,
      } )
    end
  end

  def read_configuration( connection )
    app_details = {}

    cmd = "cat #{path}/current/config/database.yml"
    connection.exec!( cmd ) do |ch, stream, data|
      if stream == :stdout
        yaml = YAML.load( data )
        # Parse the yaml doc for the environment ... er, which one? 'production'?
        self.db_type = yaml[ HosterizerApp::CONFIG[:rails_environment] ]['adapter']
        self.db_host = yaml[ HosterizerApp::CONFIG[:rails_environment] ]['host']
      end
    end
  end
end

