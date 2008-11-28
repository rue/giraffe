class Page
  # The basename is just a hack to display trees better.
  #
  attr_reader :name, :basename, :attach_dir

  # Create a Page object--the file may or may not exist.
  #
  def initialize(name, rev = nil)
    @name     = name.chomp GitWiki.extension
    @extended = @name + GitWiki.extension

    @basename = File.basename @name

    @relative_name = File.join GitWiki.relative, @extended
    @filename = File.join GitWiki.wikiroot, @extended

    @attach_dir = File.join(GitWiki.wikiroot, '_attachments', unwiki(@name))

    @rev = rev
  end

  # Slightly more humane file path.
  #
  # The base filename is humanized, i.e. "important_doc" => "Important Doc".
  # In addition, all path components of the possible prefix path are given.
  # The method returns ["some", "path", "to", "Important Doc"].
  #
  def pretty_name()
    prettified = @name.split "/"
    prettified[-1] = prettified[-1].split(/\s+|_/).map {|word| word.sub(/^(\w)/) { $1.capitalize } }.join " "
    pf = if prettified.size == 1 then prettified.unshift ""  else prettified end
  end

  # TODO: Get rid of this.
  def unwiki(string)
    string.downcase
  end

  def body
    # Just say no to wiki linking. You have Markdown, use it.
    @body ||= RubyPants.new(RDiscount.new(raw_body).to_html).to_html
  end

  def branch_name
    GitWiki.repo.current_branch
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

  def escaped_raw_body
    self.raw_body.gsub(/[<,>]/) { |matched| (matched == '<' ? '&lt;' : '&gt;') }
  end

  def update(content, message=nil)
    File.open(@filename, 'w') { |f| f << content }
    commit_message = tracked? ? "edited #{@name}" : "created #{@name}"
    commit_message += ' : ' + message if message && message.length > 0
    begin
      GitWiki.repo.add(@relative_name)
      GitWiki.repo.commit(commit_message)
    rescue
      nil
    end
    @body = nil; @raw_body = nil
    @body
  end

  def tracked?
    GitWiki.repo.ls_files.keys.include?(@relative_name)
  end

  def history
    return nil unless tracked?
    @history ||= GitWiki.repo.log.path(@relative_name)
  end

  def delta(rev)
    GitWiki.repo.diff(previous_commit, rev).path(@relative_name).patch
  end

  def commit
    @commit ||= GitWiki.repo.log.object(@rev || 'master').path(@relative_name).first
  end

  def previous_commit
    @previous_commit ||= GitWiki.repo.log(2).object(@rev || 'master').path(@relative_name).to_a[1]
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
    @blob ||= (GitWiki.repo.gblob(@rev + ':' + @relative_name))
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
      GitWiki.repo.add(new_file)
      GitWiki.repo.commit(commit_message)
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
        GitWiki.repo.remove(file_path)
        GitWiki.repo.commit(commit_message)
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

    def name_uri_escaped
      name.grep(/^(.*)\.(\w.+?)$/) { |m| e = $2; CGI::escape($1).gsub(/\./, '%2E') + '.' + e }
    end

    def link_path
      File.join('/_attachment', @page_name, name_uri_escaped)
    end

    def delete_path
      File.join('/a/file/delete', @page_name, name_uri_escaped)
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
