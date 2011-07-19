class ZFSSnapshotHelper < SPSnapshot::SnapshotHelper
  
  def initialize(baseDir, fileSysRoot=nil)
    @baseDir = baseDir
    @fsMountpoint = `df "#{baseDir}"`.lines.to_a[1].split(" ")[-1] if fileSysRoot.nil?
    fileSystems = `zfs list`.lines.to_a[1..-1]
    @fsName = fileSystems.map{|x| x.split("  ") - [""]}.find{|x| x[4].strip == @fsMountpoint}[0]
  end

  
  def snapshots
    return @snapshots unless @snapshots.nil?
    
    output = `zfs list -r -H -t snapshot -o name,creation -s creation "#{@fsName}"`
    retval = []
    
    output.lines.each do |line|
      split = line.strip.split("\t")
      snapId = split[0].split("@")[1]
      
      info = `zfs get -Hp creation,used #{split[0]}`.lines.to_a
            
      creation = Time.at(info[0].split("\t")[-2].to_i)
      size = info[1].split("\t")[-2].to_i
      
      retval << SPSnapshot::Snapshot.new(snapId, prettifySnapshotName(snapId), creation)
    end
    
    retval << SPSnapshot::Snapshot.new("@current", "Current", nil)
    @snapshots = retval.reverse
    
    return @snapshots
  end
  
  def absPathForRelPathAndSnapshot(relativePath, snapshot)
    relativePath = relativePath.gsub("..","")
    raise if File.basename(@baseDir) != relativePath[0..File.basename(@baseDir).length-1]
    
    absolutePath = @baseDir + relativePath[File.split(@baseDir)[1].length..-1]
    
    return absolutePath if snapshot.snapId == "@current"
    return @fsMountpoint + "/.zfs/snapshot/"+snapshot.snapId+absolutePath[@fsMountpoint.length..-1]
  end
  
  # I think it's probably for the best to put this in its own method...
  
  def prettifySnapshotName(snapshotname)

    match = snapshotname.match(/zfs-auto-snap_(.+?)-(\d{4})-(\d{2})-(\d{2})-(\d{2})(_|h)(\d{2})/)

    return snapshotname.capitalize if match.nil?

    case match[1]
    when "monthly"
      return "#{Date::MONTHNAMES[match[3].to_i]} #{match[2]}"
    when "weekly"
      return "#{match[4]} #{Date::MONTHNAMES[match[3].to_i]} #{match[2]}"
    when "daily"
      return "#{match[4]} #{Date::MONTHNAMES[match[3].to_i]} #{match[2]}"
    when "frequent"
      return "Today at #{match[5]}:#{match[7]}" if match[3].to_i == Time.new.month and match[4].to_i == Time.new.day and  match[2].to_i == Time.new.year
      return "Yesterday at #{match[5]}:#{match[7]}" if match[3].to_i == Time.new.month and (match[4].to_i+1) == Time.new.day and  match[2].to_i == Time.new.year
      return "#{Date::ABBR_MONTHNAMES[match[3].to_i]} #{match[4]} #{match[2]} at #{match[5]}:#{match[7]}"
    when "hourly"
      return "Today at #{match[5]}:#{match[7]}" if match[3].to_i == Time.new.month and match[4].to_i == Time.new.day and  match[2].to_i == Time.new.year
      return "Yesterday at #{match[5]}:#{match[7]}" if match[3].to_i == Time.new.month and (match[4].to_i+1) == Time.new.day and  match[2].to_i == Time.new.year
      return "#{Date::ABBR_MONTHNAMES[match[3].to_i]} #{match[4]} #{match[2]} at #{match[5]}:#{match[7]}"
    else
      return "#{Date::ABBR_MONTHNAMES[match[3].to_i]} #{match[4]} #{match[2]} at #{match[5]}:#{match[7]}"
    end
  end
  
end
