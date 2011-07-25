require 'erubis'

$diffHandlers = {} unless $diffHandlers

def diffHandler(relativePath, snapshot1, snapshot2, helper)
  eruby = Erubis::Eruby.new(File.read("Diffs/Diff.rxhtml"))
  
    mime = MIME::Types.type_for_path(helper.absPathForRelPathAndSnapshot(relativePath, snapshot2))[0].to_s
    context = {:diffContent =>  $diffHandlers[mime].diff(relativePath, snapshot1, snapshot2, helper)}
  
  return [200, {"Content-Type" => "application/xhtml+xml", "Expires" => (Time.now + 10.years).rfc2822,"Cache-Control" => "private, max-age=5000000"}, [eruby.evaluate(context)]]

end

def canDiff(relativePath, snapshot1, snapshot2, helper)
  #Do mimetypes match?
  #Do we have a handler for that mimetype?
  #Does that handler believe it can diff?
  
    
  return false if MIME::Types.type_for_path(helper.absPathForRelPathAndSnapshot(relativePath, snapshot1)) != MIME::Types.type_for_path(helper.absPathForRelPathAndSnapshot(relativePath, snapshot2))
  
  mime = MIME::Types.type_for_path(helper.absPathForRelPathAndSnapshot(relativePath, snapshot2))[0].to_s
  
  return true if $diffHandlers.has_key?(mime) and $diffHandlers[mime].canDiff(relativePath, snapshot1, snapshot2, helper)
  return false
end

require "Diffs/Handlers/HandlerClass.rb"
require "Diffs/Handlers/Text.rb"
require "Diffs/Handlers/images.rb"
