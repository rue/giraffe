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

    # Show commits for this object.
    #
    def commits(count = 30)
      data = git "log -n#{count} --pretty=format:\"%H %ct %s\" #{@repo.commit} #{@path}"
      data.split("\n").map {|c|
        sha1, timestamp, subject = c.split /\s+/, 3

        Commit.new @repo, sha1, Time.at(timestamp.to_i), subject
      }
    end

    # Produce diff using this as the current revision.
    #
    def diff(other_sha1)
      git "diff #{other_sha1} -- #{@path}"
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

    attr_reader :subject, :time

    # New commit info
    #
    def initialize(repo, sha1, time, subject)
      @repo = repo
      @sha1 = sha1
      @time = time
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

    # Search for word in repo.
    #
    # Case-insensitive, only considers full words.
    #
    def grep(word)
      git("grep --ignore-case --word-regexp --extended-regexp #{word}").chomp.split("\n").map {|match|
        name, line = match.split /:\s*/, 2

        if name =~ /binary file (.+) matches/i
          name = $1
          line = "&lt;binary file&gt;"
        end

        [object_for(name), line]
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

    # Move to a specific commit.
    #
    def at(commit)
      self.class.open @dir, commit
    end

  end

end

