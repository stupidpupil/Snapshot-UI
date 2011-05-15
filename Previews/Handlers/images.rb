
class PNGPreviewer < PreviewHandler
  def self.previewForPath(actualPath)
    maxResolution = "512x512"
    intermediatePath = "#{Dir.tmpdir}/qlTmpDir.#{Process.pid}.#{File.basename(actualPath)}"
    `cp "#{actualPath}" "#{intermediatePath}"`
    pngOut = `convert "#{intermediatePath}" -thumbnail "#{maxResolution}>" -strip png:-`
    dataURI = "data:image/png;base64,#{Base64.encode64(pngOut)}".delete("\n")
    File.delete(intermediatePath)
    return eruby = Erubis::Eruby.new("<img src=\"#{dataURI}\"/>").evaluate(nil)
  end
  
end

class JPEGPreviewer < PreviewHandler
  def self.previewForPath(actualPath)
    maxResolution = "512x512"
    maxSizeBytes = 290*1024
    quality = 90


    intermediatePath = "#{Dir.tmpdir}/qlTmpDir.#{Process.pid}.#{File.basename(actualPath)}"

    `cp "#{actualPath}" "#{intermediatePath}"`

    `convert "#{intermediatePath}" -thumbnail "#{maxResolution}>" -strip "#{intermediatePath}.tiff"`

    outputSizeBytes = maxSizeBytes + 1
    while outputSizeBytes > maxSizeBytes and quality-7 >= 5
    	quality -= 7
    	jpegOut = `convert "#{intermediatePath}.tiff" -quality #{quality} jpg:-`
    	outputSizeBytes = jpegOut.size
    end

    File.delete(intermediatePath)
    File.delete("#{intermediatePath}.tiff")

    dataURI = "data:image/jpeg;base64,#{Base64.encode64(jpegOut)}".delete("\n")
    return eruby = Erubis::Eruby.new("<img src=\"#{dataURI}\"/>").evaluate(nil)
  end
  
end

$handlers["image/png"] = PNGPreviewer
$handlers["image/jpeg"] = JPEGPreviewer
$handlers["image/tiff"] = JPEGPreviewer
$handlers["image/vnd.adobe.photoshop"] = JPEGPreviewer

class PDFPreviewer < PreviewHandler
  def self.previewForPath(actualPath)
    maxResolution = "1024x1024"
    intermediatePath = "#{Dir.tmpdir}/qlTmpDir.#{Process.pid}.#{File.basename(actualPath)}"
    `cp "#{actualPath}" "#{intermediatePath}"`
    pngOut = `convert "#{intermediatePath}[0]" -thumbnail "#{maxResolution}>" -strip png:-`  
    dataURI = "data:image/png;base64,#{Base64.encode64(pngOut)}".delete("\n")
    File.delete(intermediatePath)
    return eruby = Erubis::Eruby.new("<img src=\"#{dataURI}\"/>").evaluate(nil)
  end
end

$handlers["application/pdf"] = PDFPreviewer
