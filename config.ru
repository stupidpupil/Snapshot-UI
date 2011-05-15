require 'rubygems'
require 'uri'
require 'date'
require 'base64'
require "active_support/core_ext"

require "SnapshotModule/SnapshotClass.rb"
require "SnapshotModule/SnapshotHelperClass.rb"
require "SnapshotModule/ZFSSnapshotHelper.rb"

require 'LinkIDs.rb'

require 'Metadata/mimetype.rb'
require 'Previews/PreviewHandler.rb'
require 'Diffs/DiffHandler.rb'

require 'Apps/about.rb'
require 'Apps/info.rb'
require 'Apps/versions.rb'
require 'Apps/diff.rb'
require 'Apps/download.rb'
require 'Apps/preview.rb'

use Rack::Reloader, 0
use Rack::ConditionalGet
use Rack::ETag
use Rack::Deflater

#
# Config
#

helper = ZFSSnapshotHelper.new(File.expand_path("~"))

#
#
#

staticApp = Rack::File.new("static")
decryptApp = proc do |env|
  req = Rack::Request.new(env)
  id = req.params["id"]
  
  hash = degenerateLinkId(id)
  return [200, {"Content-Type" => "application/json"}, [hash.to_json]]
  
end

indexApp = proc do |env|
  return [200, {"Content-Type" => "application/xhtml+xml"}, [File.open("static/index.xhtml").read]]
end

versionsApp = versionsAppWithHelper(helper)
infoApp = infoAppWithHelper(helper)
previewApp = previewAppWithHelper(helper)
diffApp = diffAppWithHelper(helper)
downloadApp = downloadAppWithHelper(helper)
aboutApp = aboutServerAppWith(helper)

map '/static' do
  run staticApp
end

map '/' do
  run indexApp
end

map '/link' do
  run indexApp
end

map '/about' do
  run aboutApp
end

map '/snapshots' do
  run versionsApp
end

map '/info' do
  run infoApp
end

map '/preview' do
  run previewApp
end

map '/diff' do
  run diffApp
end

map '/decrypt' do
  run decryptApp
end

map '/download' do
  run downloadApp
end