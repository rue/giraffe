class Page

  attr_reader :name, :dir, :uri, :filename
  attr_reader :object

  def self.from_git(object)
    name  = Giraffe.to_uri.call object.name
    dir   = File.dirname(object.path).split "/"
    uri   = if dir.empty? then name else File.join(dir, name) end

    new name, dir, uri, object
  end

  def self.from_uri(dir, name)
    name      = name
    dir       = if dir == "." then [] else dir.split "/" end
    uri       = if dir.empty? then name else File.join(dir, name) end

    filename  = Giraffe.to_filename.call name
    relative  = if dir.empty? then filename else File.join(dir, filename) end

    object    = Giraffe.wiki.object_for relative

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
    if @exists.nil?
      @exists = !!@object
    end

    @exists
  end

  # Set up a blank to use as the backend object.
  #
  def make!()
    dir = Giraffe.wiki.object_for @dir.join("/")
    name = Giraffe.to_filename.call @name

    @object = Git::Blob.new dir.repo, name,
                            File.join(dir.path, name),
                            dir, "no sha1", 0
    self
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
    unless @raw_body
      @raw_body = if @object then @object.data else "" end
    end

    @raw_body
  end

  # Update file contents and commit the change.
  #
  def update(content, comments)
    comments = "<no comment by author>" if !comments or comments.empty?
    action = if exists? then "edited" else "created" end

    message = "Giraffe #{action} #{@name}: #{comments}"

    @object.data = content + "\n"
    @object.add!
    @object.commit! message

    @exists = true

    Giraffe.wiki = Giraffe.wiki.HEAD
  end

  # Time of last commit.
  #
  def updated_at()
    Time.at @object.commits(1).first.time.to_i
  end

end

class Resource < Page

  def self.from_uri(dir, name, info)
    name      = name
    dir       = dir.split "/"
    uri       = if dir.empty? then name else File.join(dir, name) end

    filename  = name
    relative  = if dir.empty? then filename else File.join(dir, filename) end

    object    = Giraffe.wiki.object_for relative

    new name, dir, uri, object, info
  end

  def initialize(name, dir, uri, object, info)
    @name = name
    @dir = dir
    @uri = uri
    @object = object

    @mime = info[:mime]
  end

  alias_method  :body, :raw_body
  alias_method  :escaped_raw_body, :raw_body

  attr_reader   :mime
end
