require 'coderay'

class UnifiedDiff < Array  
  def initialize(diff, type="inline")
    diff_table = DiffTable.new type
    diff.each do |line|
      if line =~ /^(---|\+\+\+) (.*)$/
        self << diff_table if diff_table.length > 1
        diff_table = DiffTable.new type
      end
      a = diff_table.add_line line
    end
    self << diff_table unless diff_table.empty?
    self
  end
end

# Class that represents a file diff
class DiffTable < Hash  
  attr_reader :file_name, :line_num_l, :line_num_r    

  # Initialize with a Diff file and the type of Diff View
  # The type view must be inline or sbs (side_by_side)
  def initialize(type="inline")
    @parsing = false
    @nb_line = 1
    @start = false
    @before = 'same'
    @second = true
    @type = type
  end

  # Function for add a line of this Diff
  def add_line(line)
    unless @parsing
      if line =~ /^(---|\+\+\+) (.*)$/
        @file_name = $2
        return false
      elsif line =~ /^@@ (\+|\-)(\d+)(,\d+)? (\+|\-)(\d+)(,\d+)? @@/
        @line_num_l = $5.to_i
        @line_num_r = $2.to_i
        @parsing = true
      end
    else
      if line =~ /^[^\+\-\s@\\]/
        @parsing = false
        return false
      elsif line =~ /^@@ (\+|\-)(\d+)(,\d+)? (\+|\-)(\d+)(,\d+)? @@/
        @line_num_l = $5.to_i
        @line_num_r = $2.to_i
      else
        @nb_line += 1 if parse_line(line, @type)          
      end
    end
    return true
  end

  def inspect
    puts '### DIFF TABLE ###'
    puts "file : #{file_name}"
    self.each do |d|
      d.inspect
    end
  end

private  
  # Test if is a Side By Side type
  def sbs?(type, func)
    if @start and type == "sbs"
      if @before == func and @second
        tmp_nb_line = @nb_line
        self[tmp_nb_line] = Diff.new
      else
          @second = false
          tmp_nb_line = @start
          @start += 1
          @nb_line -= 1
      end
    else
      tmp_nb_line = @nb_line
      @start = @nb_line
      self[tmp_nb_line] = Diff.new
      @second = true
    end
    unless self[tmp_nb_line]
      @nb_line += 1
      self[tmp_nb_line] = Diff.new
    else
      self[tmp_nb_line]
    end
  end

  # Escape the HTML for the diff
  def escapeHTML(line)
      CGI.escapeHTML(line)
  end

  def parse_line(line, type="inline")
    if line[0, 1] == "+"
      diff = sbs? type, 'add'
      @before = 'add'
      diff.line_left = escapeHTML line[1..-1]
      diff.nb_line_left = @line_num_l
      diff.type_diff_left = 'diff_in'
      @line_num_l += 1
      true
    elsif line[0, 1] == "-"
      diff = sbs? type, 'remove'
      @before = 'remove'
      diff.line_right = escapeHTML line[1..-1]
      diff.nb_line_right = @line_num_r
      diff.type_diff_right = 'diff_out'
      @line_num_r += 1
      true
    elsif line[0, 1] =~ /\s/
      @before = 'same'
      @start = false
      diff = Diff.new
      diff.line_right = escapeHTML line[1..-1]
      diff.nb_line_right = @line_num_r
      diff.line_left = escapeHTML line[1..-1]
      diff.nb_line_left = @line_num_l
      self[@nb_line] = diff
      @line_num_l += 1
      @line_num_r += 1
      true
    elsif line[0, 1] = "\\"
        true
      else
        false
      end
    end
  end

# A line of diff
class Diff  
  attr_accessor :nb_line_left
  attr_accessor :line_left
  attr_accessor :nb_line_right
  attr_accessor :line_right
  attr_accessor :type_diff_right
  attr_accessor :type_diff_left
  
  def initialize()
    self.nb_line_left = ''
    self.nb_line_right = ''
    self.line_left = ''
    self.line_right = ''
    self.type_diff_right = ''
    self.type_diff_left = ''
  end

  def inspect
    puts '### Start Line Diff ###'
    puts self.nb_line_left
    puts self.line_left
    puts self.nb_line_right
    puts self.line_right
  end
end


class TextDiffHandler < DiffHandler
  
  def self.diff(relativePath, snapshot1, snapshot2, helper)
    abs1 = helper.absPathForRelPathAndSnapshot(relativePath, snapshot1)
    abs2 = helper.absPathForRelPathAndSnapshot(relativePath, snapshot2)
    out = `diff --unified "#{abs2}" "#{abs1}"`.lines.to_a[2..-1].to_s
    return "<span class='info'>The text is identical.</span>" if out.strip.length == 0
    
    difftype = "sbs"
    tables = UnifiedDiff.new(out, difftype)
    
    eruby = Erubis::Eruby.new(File.read("Diffs/Handlers/Text.rxhtml"))
    
    context = {:tables => tables, :diff_type => difftype}
    
    
    return eruby.evaluate(context)
  end
end

$diffHandlers["application/x-ruby"] = TextDiffHandler
$diffHandlers["text/x-ruby"] = TextDiffHandler
$diffHandlers["application/javascript"] = TextDiffHandler
$diffHandlers["text/css"] = TextDiffHandler
$diffHandlers["text/x-c"] = TextDiffHandler
$diffHandlers["application/xhtml+xml"] = TextDiffHandler
$diffHandlers["application/xml"] = TextDiffHandler
$diffHandlers["text/plain"] = TextDiffHandler