
require 'hosterizer/application_type'

module Hosterizer::ApplicationType::Rails
  extend Hosterizer::ApplicationType

  def self.reject_paths
    @@reject_paths ||= []
    @@reject_paths
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
end

