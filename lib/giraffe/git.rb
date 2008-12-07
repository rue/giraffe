#
# Minimal abstraction of git for our purposes.
#

module Git

  # Some special errors

  class NoRepo < Exception; end


  # Object is a tree (directory) or a blob (file).
  #
  class Object
    attr_reader :repo, :name, :path, :sha1, :mode

    # Lazily initialized objects.
    #
    def initialize(repo, name, path, sha1, mode)
      @repo = repo
      @name = name
      @path = path
      @sha1 = sha1
      @mode = mode
    end

    # Shell out a command and capture all output.
    #
    def git(command)
      there { `git #{command} 2>&1`.strip }
    end

    # Use the path as the repo to work with.
    #
    def there(&block)
      Dir.chdir @repo.path, &block
    end

  end

  # Directory that git knows about.
  #
  class Tree < Object

    attr_reader :objects

    # Populate a tree from the given path.
    #
    def initialize(repo, name, path, sha1, mode)
      super

      @objects =  git("ls-tree #{@sha1}").split("\n").map {|entry|
                    mode, type, sha1, name = entry.split /\s+/, 4

                    path = if @name.empty? then name else File.join @name, name end

                    type = Git.const_get(type.capitalize)
                    type.new repo, name, path, sha1, mode
                  }
    end


    # Locate object directly by path.
    #
    def object_for(path)
    end

  end

  # Blob is a file git knows about.
  #
  class Blob < Object
  end

  # Commit information
  #
  class Commit < Object
  end

  # A repository is a branch at a path.
  #
  class Repository < Tree

    # Opens an existing repo.
    #
    def self.open(path, commit = "HEAD")
      new path, commit
    end

    attr_reader :path, :commit


    # Set up repo that refers to given path.
    #
    # Raises if the path does not seem to be a git repo.
    #
    def initialize(path, commit)
      # Cheat a little bit.
      @repo = self
      @path = path
      @commit = commit

      raise NoRepo if git("status") =~ /not a git repo/i

      super(self, "", @path, @commit, File.stat(@path).mode)

    rescue Errno::ENOENT, Errno::EACCES, Errno::EPERM
      raise NoRepo
    end

  end

end
