class ArchivePreviewer < PreviewHandler
  
  def self.canPreviewPath(actualPath)
    return true unless File.basename(actualPath).match(/\.tar\.(bz2|gz)$/).nil?
    return false
  end
  
  def self.previewForPath(actualPath)
    compress = 
    
    entries = []
    `tar -jtvf "#{actualPath}"`.lines.each do |line|
      split = line.split(" ")
      entries << {:name => split[-1]}
    end
    
    eruby = Erubis::Eruby.new(File.read("Previews/Handlers/Archives.rxhtml"))
    context = {:entries => entries}
    
    return eruby.evaluate(context)
  end
  
end

$handlers["application/x-bzip2"] = ArchivePreviewer
$handlers["application/x-gzip"] = ArchivePreviewer
