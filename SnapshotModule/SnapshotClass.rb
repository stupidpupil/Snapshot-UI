require "active_support/core_ext"
require "date"

module SPSnapshot

class Snapshot
  attr_reader :snapId, :name, :time
  
  def initialize(snapId, name = nil, time = nil)
    @snapId = snapId
    @name = name.nil? ? snapId : name
    @time = time
  end
  
  def as_json(options={})
    return {:snapId => self.snapId, :name => self.name, :iso8601 => (self.time.nil? ? nil : self.time.utc.iso8601)}
  end
  
end

end