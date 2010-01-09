
require 'hosterizer'


module Hosterizer::HostType
  def self.extended( mod )
    types << mod
  end

  def self.types
    @@types ||= []
    @@types
  end

end

