require "active_support/core_ext"
require "date"

module SPSnapshot

class Snapshot
  attr_reader :snapId, :name, :ctime
  
  def initialize(snapId, name = nil, ctime = nil)
    @snapId = snapId
    @name = name.nil? ? snapId : name
    @ctime = ctime
  end
  
  def as_json(options={})
    return {:snapId => self.snapId, :name => self.name, :ctime => self.ctime.to_i}
  end
  
end

end