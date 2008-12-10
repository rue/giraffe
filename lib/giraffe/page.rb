class Page

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

    #TODO
    @object.data = content + "\n"
    @object.add!
    @object.commit! message

    Giraffe.wiki = Giraffe.wiki.HEAD
  end

  # Time of last commit.
  #
  def updated_at()
    Time.at @object.commits(1).first.time.to_i
  end

end
