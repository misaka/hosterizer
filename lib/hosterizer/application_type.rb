require 'hosterizer'


module Hosterizer::ApplicationType
  def self.extended( mod )
    types << mod
  end

  def self.types
    @@types ||= []
    @@types
  end

end

