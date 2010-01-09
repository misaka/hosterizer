
require 'hosterizer/host_type'

module Hosterizer::HostType::Rails
  extend Hosterizer::HostType

  def self.reject_paths
    @@reject_paths ||= []
    @@reject_paths
  end

  def self.probe( ssh, host )
    applications = []

    ssh.exec!( "echo /opt/railsapps/applications/*" ) do |ch, stream, data|
      if stream == :stdout
        applications = data.split( /\s+/ ).
          reject { |path| reject_paths.find { |reject| path.match( reject ) } }
      end
    end

    applications.each do |application|
      puts "#{host} / #{application}"
    end
  end
end

