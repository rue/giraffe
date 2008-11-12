class Page
  attr_reader :name, :attach_dir

  def initialize(name, rev=nil)
    @name = name
    @rev = rev
    @filename = File.join(GIT_REPO, @name)
    @attach_dir = File.join(GIT_REPO, '_attachments', unwiki(@name))
  end
  
  def unwiki(string)
    string.downcase
  end

  def body
    @body ||= RubyPants.new(RDiscount.new(raw_body).to_html).to_html.wiki_linked
  end
  
  def branch_name
    $repo.current_branch
  end
  
  def updated_at
    commit.committer_date rescue Time.now
  end

  def raw_body
    if @rev
       @raw_body ||= blob.contents
    else
      @raw_body ||= File.exists?(@filename) ? File.read(@filename) : ''
    end
  end

  def update(content, message=nil)
    File.open(@filename, 'w') { |f| f << content }
    commit_message = tracked? ? "edited #{@name}" : "created #{@name}" 
    commit_message += ' : ' + message if message && message.length > 0
    begin
      $repo.add(@name)
      $repo.commit(commit_message)
    rescue 
      nil
    end
    @body = nil; @raw_body = nil
    @body
  end

  def tracked?
    $repo.ls_files.keys.include?(@name)
  end

  def history
    return nil unless tracked?
    @history ||= $repo.log.path(@name)
  end

  def delta(rev)
    $repo.diff(previous_commit, rev).path(@name).patch
  end
  
  def commit
    @commit ||= $repo.log.object(@rev || 'master').path(@name).first
  end

  def previous_commit
    @previous_commit ||= $repo.log(2).object(@rev || 'master').path(@name).to_a[1]
  end

  def next_commit
    begin
      if (self.history.first.sha == self.commit.sha)
        @next_commit ||= nil
      else
        matching_index = nil
        history.each_with_index { |c, i| matching_index = i if c.sha == self.commit.sha }
        @next_commit ||= history.to_a[matching_index - 1]
      end
    rescue 
      @next_commit ||= nil
    end
  end

  def version(rev)
    data = blob.contents
    RubyPants.new(RDiscount.new(data).to_html).to_html.wiki_linked
  end

  def blob
    @blob ||= ($repo.gblob(@rev + ':' + @name))
  end
  
  # save a file into the _attachments directory
  def save_file(file, name = '')
    if name.size > 0
      filename = name + File.extname(file[:filename])
    else
      filename = file[:filename]
    end
    FileUtils.mkdir_p(@attach_dir) if !File.exists?(@attach_dir)
    new_file = File.join(@attach_dir, filename)

    f = File.new(new_file, 'w')
    f.write(file[:tempfile].read)
    f.close
        
    commit_message = "uploaded #{filename} for #{@name}"
    begin
      $repo.add(new_file)
      $repo.commit(commit_message)
    rescue 
      nil
    end
  end
  
  def delete_file(file)
    file_path = File.join(@attach_dir, file)
    if File.exists?(file_path)
      File.unlink(file_path)

      commit_message = "removed #{file} for #{@name}"
      begin
        $repo.remove(file_path)
        $repo.commit(commit_message)
      rescue 
        nil
      end
      
    end
  end
  
  def attachments
    if File.exists?(@attach_dir)
      return Dir.glob(File.join(@attach_dir, '*')).map { |f| Attachment.new(f, unwiki(@name)) }
    else
      false
    end
  end
  
  class Attachment
    attr_accessor :path, :page_name
    def initialize(file_path, name)
      @path = file_path
      @page_name = name
    end
    
    def name
      File.basename(@path)
    end

    def link_path
      File.join('/_attachment', @page_name, name)
    end

    def delete_path
      File.join('/a/file/delete', @page_name, name)
    end

    def image?
      ext = File.extname(@path)
      case ext
      when '.png', '.jpg', '.jpeg', '.gif'; return true
      else; return false
      end
    end

    def size
      size = File.size(@path).to_i
      case
      when size.to_i == 1;     "1 Byte"
      when size < 1024;        "%d Bytes" % size
      when size < (1024*1024); "%.2f KB"  % (size / 1024.0)
      else                     "%.2f MB"  % (size / (1024 * 1024.0))
      end.sub(/([0-9])\.?0+ /, '\1 ' )
    end
  end
  
end