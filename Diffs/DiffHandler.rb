require 'erubis'

$diffHandlers = {} unless $diffHandlers

def diffHandler(env, helper)
  req = Rack::Request.new(env)
  reqHash = requestToHash(req)      

  path = reqHash[:path]

  snapshots = helper.snapshotsForPath(path)

  snapshot1 = snapshots.find {|x| x.snapId == reqHash[:snapshot]}
  snapshot2 = snapshots.find {|x| x.snapId == reqHash[:snapshot2]}


  mimetype = MIME::Types.type_for_path(helper.absPathForRelPathAndSnapshot(path, snapshot2))[0].to_s

  return $diffHandlers[mimetype].respond(env, helper)

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
