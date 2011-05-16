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

require 'AppFactory/init.rb'
require 'AppFactory/info.rb'
require 'AppFactory/versions.rb'
require 'AppFactory/diff.rb'
require 'AppFactory/download.rb'
require 'AppFactory/preview.rb'

use Rack::Reloader, 0
use Rack::ConditionalGet
use Rack::ETag
use Rack::Deflater

#
# Config
#

helper = ZFSSnapshotHelper.new(File.expand_path("~"))

appFactory = SPSnapshot::UIAppFactory.new(helper)

map '/about' do
  run appFactory.aboutApp
end

map '/snapshots' do
  run appFactory.versionsApp
end

map '/info' do
  run appFactory.infoApp
end

map '/preview' do
  run appFactory.previewApp
end

map '/diff' do
  run appFactory.diffApp
end

map '/download' do
  run appFactory.downloadApp
end

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


map '/static' do
  run staticApp
end

map '/' do
  run indexApp
end

map '/link' do
  run indexApp
end

map '/decrypt' do
  run decryptApp
end