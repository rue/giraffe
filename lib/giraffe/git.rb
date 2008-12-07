#
# Minimal abstraction of git for our purposes.
#

module Git

  # Some special errors

  class NoRepo < Exception; end


  # Object is a tree (directory) or a blob (file).
  #
  class Object
    attr_reader :repo, :name, :path, :parent, :sha1, :mode

    attr_reader :full_path

    # Lazily initialized objects.
    #
    def initialize(repo, name, path, parent, sha1, mode)
      @repo = repo
      @name = name
      @path = path
      @parent = parent
      @sha1 = sha1
      @mode = mode

      @full_path = File.join @repo.dir, @path
    end

    # Shell out a command and capture all output.
    #
    def git(command)
      there { `git #{command} 2>&1`.strip }
    end

    # Work from the root.
    #
    def there(&block)
      Dir.chdir @repo.dir, &block
    end

  end

  # Blob is a file git knows about.
  #
  class Blob < Object

    # Stage to be committed.
    #
    def add!()
      git "add #{@path}"
    end

    # Commit (whatever is in index)
    #
    def commit!(message)
      git "commit -m \"#{message}\""
    end

    # Contents of file at whichever revision we are using.
    #
    def data()
      git "show #{@sha1}"
    end

    # Write to the file (does not commit).
    #
    def data=(string)
      File.open(@full_path, "w+") {|f| f << string }
    end

  end


  # Commit information
  #
  class Commit < Object

    attr_reader :subject

    # New commit info
    #
    def initialize(repo, sha1, subject)
      @repo = repo
      @sha1 = sha1
      @subject = subject
    end

  end


  # Directory that git knows about.
  #
  class Tree < Object

    attr_reader :objects

    # Populate a tree from the given path.
    #
    def initialize(repo, name, path, parent, sha1, mode)
      super

      @objects =  git("ls-tree #{@repo.commit}").split("\n").map {|entry|
                    mode, type, sha1, name = entry.split /\s+/, 4
                    next if type == "commit"

                    path = if @path.empty? then name else File.join(@path, name) end

                    type = Git.const_get(type.capitalize)
                    type.new repo, name, path, self, sha1, mode
                  }.compact
    end

    # Show commits for this tree.
    #
    def commits()
      git("rev-list --pretty=oneline #{@repo.commit}").split("\n").map {|commit|
        sha1, subject = commit.split /\s+/, 2

        Commit.new @repo, sha1, subject
      }
    end

    # Locate object directly by path or return nil.
    #
    def object_for(path)
      # We do the traversal so that the user does not need to.
      path.split("/").inject(self) {|tree, name|
        tree.objects.find {|obj| obj.name == name }
      }
    end

    # Use the path as the repo to work with.
    #
    def there(&block)
      Dir.chdir File.join(@repo.dir, @path), &block
    end

  end


  # A repository is a branch at a path.
  #
  class Repository < Tree

    # Opens an existing repo.
    #
    def self.open(path, commit = "HEAD")
      new path, commit
    end

    attr_reader :dir, :commit


    # Set up repo that refers to given path.
    #
    # Raises if the path does not seem to be a git repo.
    #
    def initialize(path, commit)
      @repo = self
      @dir = path
      @path = ""
      @commit = commit

      raise NoRepo if git("status") =~ /not a git repo/i

      super(self, "", @path, nil, @commit, File.stat(@dir).mode)

    rescue Errno::ENOENT, Errno::EACCES, Errno::EPERM
      raise NoRepo
    end

    # Repository for current HEAD
    #
    # TODO: Add #head!
    #
    def HEAD()
      self.class.open @dir, "HEAD"
    end

  end

end

