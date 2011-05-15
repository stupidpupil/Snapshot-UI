$handlers["video/mpeg"] = proc do |actualPath|
  intermediatePath = "#{Dir.tmpdir}/qlTmpDir.#{Process.pid}.#{File.basename(actualPath)}"
  
  `mplayer -ss 120 -frames 1 -vo jpeg:outdir="#{intermediatePath}" "#{actualPath}"`
  
  return "<span class=\"previewError\"> Unable to generate preview.</span>" unless File.exists?(intermediatePath+"/00000001.jpg")
  
  return $handlers["image/jpeg"].call(intermediatePath+"/00000001.jpg")
end

$handlers["video/mp4"] = $handlers["video/mpeg"]
$handlers["video/x-msvideo"] = $handlers["video/mpeg"]
$handlers["video/x-matroska"] = $handlers["video/mpeg"]