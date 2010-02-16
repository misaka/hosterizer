require 'hosterizer'
require 'set'


class Hosterizer::Application
  attr_accessor :name, :path

  def self.auto_discoverable
    applications << self
  end

  def self.extended( mod )
    applications << mod
  end

  def self.applications
    @@applications ||= Set.new
    @@applications
  end

  def initialize( params )
    self.name = params[:name]
    self.path = params[:path]
  end
end

