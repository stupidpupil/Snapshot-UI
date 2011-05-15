require 'erubis'

$diffHandlers = {} unless $diffHandlers

def diffHandler(relativePath, snapshot1, snapshot2, helper)
  eruby = Erubis::Eruby.new(File.read("Diffs/Diff.rxhtml"))
  
    context = {:diffContent => TextDiffHandler.diff(relativePath, snapshot1, snapshot2, helper)}
  
  return [200, {"Content-Type" => "application/xhtml+xml", "Expires" => (Time.now + 10.years).rfc2822,"Cache-Control" => "private, max-age=5000000"}, [eruby.evaluate(context)]]

end

def canDiff(relativePath, snapshot1, snapshot2, helper)
  #Do mimetypes match?
  #Do we have a handler for that mimetype?
  #Does that handler believe it can diff?
  
    
  return false if mimetypeForPath(helper.absPathForRelPathAndSnapshot(relativePath, snapshot1)) != mimetypeForPath(helper.absPathForRelPathAndSnapshot(relativePath, snapshot2))
  
  mime = mimetypeForPath(helper.absPathForRelPathAndSnapshot(relativePath, snapshot2))
  
  return true if $diffHandlers.has_key?(mime) and $diffHandlers[mime].canDiff(relativePath, snapshot1, snapshot2, helper)
  return false
end

require "Diffs/Handlers/HandlerClass.rb"
require "Diffs/Handlers/Text.rb"
