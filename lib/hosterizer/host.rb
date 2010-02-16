
require 'hosterizer'

class Hosterizer::Host

  attr_accessor :connection_type, :gateway, :hostname, :username

  def initialize( info = {} )
    self.connection_type = info[:connection_type]
    self.gateway         = info[:gateway]
    self.hostname        = info[:hostname]
    self.username        = info[:username]
  end

  # Create a host object that can be connected to from a string definition.
  #
  # The hostname can have encoded in it a gateway host and/or a username to
  # use to connect with. The syntax for the hosts is:
  #
  #   [[gateway_user@]gateway/][user@]host
  #
  # This method will decode this and return the host object. The connect
  # method below can be used to connect to this host and run commands.
  def self.create_from_string( host_string )
    hosts = host_string.match( Regexp.new( '(?:(.*)/)?(.*)' ) )
    host_info = {}

    if hosts[1]
      host_info[:connection_type] = :ssh_gateway

      user_and_gateway = hosts[1].match( /(?:(.*)@)?(.*)/ )
      host_info[:gateway] = {
        :hostname => user_and_gateway[2],
        :username => user_and_gateway[1]
      }
    else
      host_info[:connection_type] = :ssh
    end

    user_and_host = hosts[2].match( /(?:(.*)@)?(.*)/ )
    host_info[:username] = user_and_host[1]
    host_info[:hostname] = user_and_host[2]

    self.new host_info
  end

  def connect( &block )
    HosterizerApp::LOGGER.debug "connection type: #{connection_type.to_s}"

    case connection_type
      when :ssh_gateway
        gateway_connection = Net::SSH::Gateway.new( gateway[:hostname], gateway[:username] )
        HosterizerApp::LOGGER.debug( "connecting to host '#{gateway[:hostname]}' as '#{gateway[:username]}'" )
        gateway_connection.ssh( hostname, username, &block )

      when :ssh
        HosterizerApp::LOGGER.debug( "connecting to host '#{hostname}' as '#{username}'" )
        Net::SSH.start( hostname, username, &block )
    end
  end

  def list_applications
    applications = {}

    connect do |connection|
      Hosterizer::ApplicationType.types.each do |type|
        HosterizerApp::LOGGER.debug "checking application configuration #{type.to_s}"

        # Get a list of applications of this type for this host.
        applications[type.to_s] = type.find_applications( connection, hostname )

        # Get info for each application.
        if !HosterizerApp::CONFIG[:list_apps]
          applications[type.to_s].each do |app,info|
            HosterizerApp::LOGGER.debug "getting details for application '#{app}'"
            type.get_app_details app, info, connection
          end
        end
      end
    end

    applications
  end

end
