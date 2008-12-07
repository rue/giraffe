class Page
  # The basename is just a hack to display trees better.
  #
  attr_reader :name, :dir, :uri, :filename, :relative_path, :full_path
  attr_reader :object
  attr_reader :attach_dir

  def self.from_git(object)
    name  = Giraffe.to_uri.call object.name
    dir   = File.dirname(object.path).split "/"
    uri   = if dir.empty? then name else File.join(dir, name) end

    new name, dir, uri, object
  end

  def self.from_uri(dir, name)
    name      = name
    dir       = dir.split "/"
    uri       = if dir.empty? then name else File.join(dir, name) end

    filename  = Giraffe.to_filename.call name
    relative  = if dir.empty? then filename else File.join(dir, filename) end

    begin
      object    = Giraffe.wiki.object_for relative
    rescue
      raise ArgumentError, "Invalid path"
    end

    attach_dir    = File.join Giraffe.wikiroot, '_attachments'

    new name, dir, uri, object
  end

  # Create a Page object--the file may or may not exist.
  #
  def initialize(name, dir, uri, object)
    @name   = name
    @dir    = dir
    @uri    = uri
    @object = object
  end

  # List any attachments for page.
  #
  def attachments()
    false
  end

  # Rendered page body.
  #
  def body()
    # Just say no to wiki linking. You have Markdown, use it.
    @body ||= RubyPants.new(RDiscount.new(raw_body).to_html).to_html
  end

  # Whether this entity corresponds to a directory.
  #
  # TODO:   Needs work. Currently if any page name, when lowercased,
  #         matches a directory (taking into account any directory
  #         prefix), it is considered a directory. This will fail
  #         horribly with more complex name mappings.
  #
  def directory?()
    File.directory? File.join(Giraffe.wikiroot, File.join(@dir), @name.downcase)
  end

  # Escape < and > from the raw page content.
  #
  def escaped_raw_body()
    raw_body.gsub(/[<>]/) { |matched| (matched == '<' ? '&lt;' : '&gt;') }
  end

  # Is page already in the repo?
  #
  def exists?()
    !!@object
  end

  # Next version of page.
  #
  # TODO: ADD
  #
  def newer()
    false
  end

  # Previous version of page.
  #
  # TODO: ADD
  #
  def older()
    false
  end

  # Slightly more humane file path.
  #
  # The base filename is humanized, i.e. "important_doc" => "Important Doc".
  # In addition, all path components of the possible prefix path are given.
  # The method returns ["some", "path", "to", "Important Doc"].
  #
  def pretty_name()
    dir = if @dir.empty? then [""] else @dir.dup end
    dir << @name.split(/\s+|_/).map {|word| word.sub(/^(\w)/) { $1.capitalize } }.join(" ")
  end

  # Unrendered page body.
  #
  def raw_body()
    @raw_body ||= @object.data
  end

  # Update file contents and commit the change.
  #
  def update(content, comments = nil)
    message = if exists? then "Giraffe edited #{@name}" else "Giraffe created #{@name}" end
    message << " : #{comments}" if comments

    @object.data = content + "\n"
    @object.add!
    @object.commit! message

    Giraffe.wiki = Giraffe.wiki.HEAD
  end

  # Time of last commit.
  #
  # TODO: ADD
  #
  def updated_at()
    Time.now
  end


#
#  def branch_name
#    Giraffe.repo.current_branch
#  end
#
#  def history
#    return nil unless tracked?
#    @history ||= Giraffe.repo.log.path(@relative_name)
#  end
#
#  def delta(rev)
#    Giraffe.repo.diff(previous_commit, rev).path(@relative_name).patch
#  end
#
#  def commit
#    @commit ||= Giraffe.repo.log.object(@rev || 'master').path(@relative_name).first
#  end
#
#  def previous_commit
#    @previous_commit ||= Giraffe.repo.log(2).object(@rev || 'master').path(@relative_name).to_a[1]
#  end
#
#  def next_commit
#    begin
#      if (self.history.first.sha == self.commit.sha)
#        @next_commit ||= nil
#      else
#        matching_index = nil
#        history.each_with_index { |c, i| matching_index = i if c.sha == self.commit.sha }
#        @next_commit ||= history.to_a[matching_index - 1]
#      end
#    rescue
#      @next_commit ||= nil
#    end
#  end
#
#  def version(rev)
#    data = blob.contents
#    RubyPants.new(RDiscount.new(data).to_html).to_html.wiki_linked
#  end
#
#  def blob
#    @blob ||= (Giraffe.repo.gblob(@rev + ':' + @relative_name))
#  end
#
#  # save a file into the _attachments directory
#  def save_file(file, name = '')
#    if name.size > 0
#      filename = name + File.extname(file[:filename])
#    else
#      filename = file[:filename]
#    end
#    FileUtils.mkdir_p(@attach_dir) if !File.exists?(@attach_dir)
#    new_file = File.join(@attach_dir, filename)
#
#    f = File.new(new_file, 'w')
#    f.write(file[:tempfile].read)
#    f.close
#
#    commit_message = "uploaded #{filename} for #{@name}"
#    begin
#      Giraffe.repo.add(new_file)
#      Giraffe.repo.commit(commit_message)
#    rescue
#      nil
#    end
#  end
#
#  def delete_file(file)
#    file_path = File.join(@attach_dir, file)
#    if File.exists?(file_path)
#      File.unlink(file_path)
#
#      commit_message = "removed #{file} for #{@name}"
#      begin
#        Giraffe.repo.remove(file_path)
#        Giraffe.repo.commit(commit_message)
#      rescue
#        nil
#      end
#
#    end
#  end
#

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
