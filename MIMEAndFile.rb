require 'mime/types'

DirectoryMimeType = MIME::Type.new("application/x-directory")


module MIME
  class Types
    
    #Unlike 'type_for',
    #this will actually examine the path, and may return MIME::Types["application/x-directory"]
    def self.type_for_path(path)
      types_for = self.type_for(path)
      
      return types_for if types_for.length > 0
      
      return [DirectoryMimeType] if File.directory?(path)
      
      return [MIME::Types["application/octet-stream"]]
      
    end
  end
end

class File

  def self.kind(path)
    return `file -b "#{path}"`
  end
  
  #This method is intended to help when encountering OS X packages.
  #Such packages are directories, but not folders. (Or at least that's the vocabulary that I'm using.)
  def self.isFolder?(path)
    return false if not File.directory?(path)
    return false if MIME::Types.type_for_path(path)[0] != DirectoryMimeType
    return true
  end
  
end