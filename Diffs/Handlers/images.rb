
class PNGDiffHandler < DiffHandler
  def self.diff(relativePath, snapshot1, snapshot2, helper)
    maxResolution = "512x512"
    abs1 = helper.absPathForRelPathAndSnapshot(relativePath, snapshot1)
    abs2 = helper.absPathForRelPathAndSnapshot(relativePath, snapshot2)
    in1 = "#{Dir.tmpdir}/qlTmpDir.#{Process.pid}.1.#{File.basename(abs1)}"
    in2 = "#{Dir.tmpdir}/qlTmpDir.#{Process.pid}.2.#{File.basename(abs1)}"
    
    `cp "#{abs1}" "#{in1}"`
    `cp "#{abs2}" "#{in2}"`
    
    pngOut = `convert -fuzz 5% -compose change-mask -composite "#{in1}" "#{in2}" -thumbnail "#{maxResolution}>" -strip png:-`
    dataURI = "data:image/png;base64,#{Base64.encode64(pngOut)}".delete("\n")
    File.delete(in1)
    File.delete(in2)
    
    return eruby = Erubis::Eruby.new("<img src=\"#{dataURI}\"/>").evaluate(nil)
  end
  
end

class JPEGDiffHandler < DiffHandler
  def self.diff(relativePath, snapshot1, snapshot2, helper)
    maxResolution = "512x512"
    maxSizeBytes = 290*1024
    quality = 90
  
    abs1 = helper.absPathForRelPathAndSnapshot(relativePath, snapshot1)
    abs2 = helper.absPathForRelPathAndSnapshot(relativePath, snapshot2)
    in1 = "#{Dir.tmpdir}/qlTmpDir.#{Process.pid}.1.#{File.basename(abs1)}"
    in2 = "#{Dir.tmpdir}/qlTmpDir.#{Process.pid}.2.#{File.basename(abs1)}"
    
    `cp "#{abs1}" "#{in1}"`
    `cp "#{abs2}" "#{in2}"`
    
    intermediatePath = "#{Dir.tmpdir}/qlTmpDir.#{Process.pid}.#{File.basename(abs1)}.png"
    
    pngOut = `convert -fuzz 5% -compose change-mask -composite "#{in1}" "#{in2}" -thumbnail "#{maxResolution}>" -strip png:-`
    
    File.delete(in1)
    File.delete(in2)
    
    #outputSizeBytes = maxSizeBytes + 1
    #while outputSizeBytes > maxSizeBytes and quality-7 >= 5
    #	quality -= 7
    #	jpegOut = `convert "#{intermediatePath}" -quality #{quality} jpg:-`
    #	outputSizeBytes = jpegOut.size
    #end
    #
    #File.delete(intermediatePath)

    dataURI = "data:image/png;base64,#{Base64.encode64(pngOut)}".delete("\n")
    return eruby = Erubis::Eruby.new("<img src=\"#{dataURI}\"/>").evaluate(nil)
    
  end
  
end

$diffHandlers["image/png"] = PNGDiffHandler
$diffHandlers["image/jpeg"] = JPEGDiffHandler

