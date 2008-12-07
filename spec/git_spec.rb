#
# Specs for the few git commands we use.
#

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require "giraffe/git"

require "fileutils"

describe Git, "'opening'  a Repository" do

  before :all do
    FileUtils.mkdir "/tmp/giraffe_not_a_repo"

    FileUtils.mkdir_p "/tmp/giraffe_repo/tracked/subdir"

    FileUtils.touch   "/tmp/giraffe_repo/tracked/file.txt"
    FileUtils.touch   "/tmp/giraffe_repo/tracked/subdir/file2.txt"
    FileUtils.touch   "/tmp/giraffe_repo/tracked/no_file.txt"

    FileUtils.mkdir_p "/tmp/giraffe_repo/not_tracked"
    FileUtils.touch   "/tmp/giraffe_repo/not_tracked/no_file.txt"

    Dir.chdir("/tmp/giraffe_repo") {
      `git init`
      `git add tracked/file.txt`
      `git commit -m "First"`
      `git add tracked/subdir`
      `git commit -m "Second"`
    }
  end

  after :all do
    FileUtils.rm_r "/tmp/giraffe_repo"
    FileUtils.rm_r "/tmp/giraffe_not_a_repo"
  end

  it "fails if the given path does not exist" do
    lambda {
      Git::Repository.open "/tmp/giraffe_nonesuch_#{$$}"
    }.should raise_error(Git::NoRepo)
  end

  it "fails if the given path is not a git repo" do
    lambda {
      Git::Repository.open "/tmp/giraffe_not_a_repo"
    }.should raise_error(Git::NoRepo)
  end

  it "can be opened at the top level of the repository" do
    Git::Repository.open "/tmp/giraffe_repo"
  end

  it "can be opened at a subdirectory of the repository" do
    Git::Repository.open "/tmp/giraffe_repo/tracked"
  end

  it "can be opened at a nontracked subdirectory of the repository" do
    Git::Repository.open "/tmp/giraffe_repo/not_tracked"
  end

end

describe Git::Repository, "accessing files" do

  before :all do
    FileUtils.mkdir_p "/tmp/giraffe_repo/tracked/subdir"

    FileUtils.touch   "/tmp/giraffe_repo/tracked/file.txt"
    FileUtils.touch   "/tmp/giraffe_repo/tracked/subdir/file2.txt"
    FileUtils.touch   "/tmp/giraffe_repo/tracked/no_file.txt"

    FileUtils.mkdir_p "/tmp/giraffe_repo/not_tracked"
    FileUtils.touch   "/tmp/giraffe_repo/not_tracked/no_file.txt"

    Dir.chdir("/tmp/giraffe_repo") {
      `git init`
      `git add tracked/file.txt`
      `git commit -m "First"`
      `git add tracked/subdir`
      `git commit -m "Second"`
    }

    @repo = Git::Repository.open "/tmp/giraffe_repo"
  end

  after :all do
    FileUtils.rm_r "/tmp/giraffe_repo"
  end

  it "the repository itself is a Tree" do
    @repo.should be_kind_of(Git::Tree)
  end

end


describe Git::Tree, "object list" do

  before :all do
    FileUtils.mkdir_p "/tmp/giraffe_repo/tracked/subdir"

    FileUtils.touch   "/tmp/giraffe_repo/file0.txt"
    FileUtils.touch   "/tmp/giraffe_repo/tracked/file1.txt"
    FileUtils.touch   "/tmp/giraffe_repo/tracked/subdir/file2.txt"
    FileUtils.touch   "/tmp/giraffe_repo/tracked/no_file.txt"

    FileUtils.mkdir_p "/tmp/giraffe_repo/not_tracked"
    FileUtils.touch   "/tmp/giraffe_repo/not_tracked/no_file.txt"

    Dir.chdir("/tmp/giraffe_repo") {
      `git init`
      `git add file0.txt tracked/file1.txt`
      `git commit -m "First"`
      `git add tracked/subdir`
      `git commit -m "Second"`
    }

    @repo = Git::Repository.open "/tmp/giraffe_repo"
    @sub = Git::Repository.open "/tmp/giraffe_repo/tracked"
  end

  after :all do
    FileUtils.rm_r "/tmp/giraffe_repo"
  end

  it "has an entry for each object in the tree" do
    (!!@repo.objects.find {|o| o.path == "file0.txt" }).should == true
    (!!@repo.objects.find {|o| o.path == "tracked" }).should == true
  end

  it "does not include untracked objects in the tree" do
    (!!@repo.objects.find {|o| o.path == "not_tracked" }).should_not == true
    (!!@repo.objects.find {|o| o.path == "not_tracked/no_file.txt" }).should_not == true
  end

  it "does not contain objects from subtrees" do
    (!!@repo.objects.find {|o| o.path == "tracked/file1.txt" }).should_not == true
    (!!@repo.objects.find {|o| o.path == "tracked/subdir" }).should_not == true
    (!!@repo.objects.find {|o| o.path == "tracked/subdir/file2.txt" }).should_not == true
  end

end

describe Git::Object, "name and path info" do

  before :all do
    FileUtils.mkdir_p "/tmp/giraffe_repo/tracked/subdir"

    FileUtils.touch   "/tmp/giraffe_repo/file0.txt"
    FileUtils.touch   "/tmp/giraffe_repo/tracked/file1.txt"
    FileUtils.touch   "/tmp/giraffe_repo/tracked/subdir/file2.txt"
    FileUtils.touch   "/tmp/giraffe_repo/tracked/no_file.txt"

    FileUtils.mkdir_p "/tmp/giraffe_repo/not_tracked"
    FileUtils.touch   "/tmp/giraffe_repo/not_tracked/no_file.txt"

    Dir.chdir("/tmp/giraffe_repo") {
      `git init`
      `git add file0.txt tracked/file1.txt`
      `git commit -m "First"`
      `git add tracked/subdir`
      `git commit -m "Second"`
    }

    @repo = Git::Repository.open "/tmp/giraffe_repo"
    @repo2 = Git::Repository.open "/tmp/giraffe_repo/tracked"

    @obj = @repo.object_for("tracked/subdir/file2.txt")
    @obj2 = @repo2.object_for("subdir/file2.txt")
  end

  after :all do
    FileUtils.rm_r "/tmp/giraffe_repo"
  end

  it "name is always just object name" do
    @obj.name.should == "file2.txt"
    @obj2.name.should == "file2.txt"
  end

  it "path is always full name relative to the repository" do
    @obj.path.should == "tracked/subdir/file2.txt"
    @obj2.path.should == "subdir/file2.txt"
  end

end

describe Git::Tree, "direct object access" do

  before :all do
    FileUtils.mkdir_p "/tmp/giraffe_repo/tracked/subdir"

    FileUtils.touch   "/tmp/giraffe_repo/file0.txt"
    FileUtils.touch   "/tmp/giraffe_repo/tracked/file1.txt"
    FileUtils.touch   "/tmp/giraffe_repo/tracked/subdir/file2.txt"
    FileUtils.touch   "/tmp/giraffe_repo/tracked/no_file.txt"

    FileUtils.mkdir_p "/tmp/giraffe_repo/not_tracked"
    FileUtils.touch   "/tmp/giraffe_repo/not_tracked/no_file.txt"

    Dir.chdir("/tmp/giraffe_repo") {
      `git init`
      `git add file0.txt tracked/file1.txt`
      `git commit -m "First"`
      `git add tracked/subdir`
      `git commit -m "Second"`
    }

    @repo = Git::Repository.open "/tmp/giraffe_repo"
  end

  after :all do
    FileUtils.rm_r "/tmp/giraffe_repo"
  end

  it "returns an object for a given path" do
    @repo.object_for("tracked/subdir/file2.txt").path.should == "tracked/subdir/file2.txt"
  end

  it "returns nil if path is not valid" do
    @repo.object_for("tracked/file2.txt").should == nil
  end

  it "returns nil if path is untracked" do
    @repo.object_for("tracked/no_file.txt").should == nil
  end

end


describe "blob" do

  before :each do
    FileUtils.mkdir_p "/tmp/giraffe_repo/tracked/subdir"

    File.open("/tmp/giraffe_repo/file0.txt", "w+") {|f| f.puts $$ }
    File.open("/tmp/giraffe_repo/file1.txt", "w+") {|f| f.puts $$ }

    Dir.chdir("/tmp/giraffe_repo") {
      `git init`
      `git add file0.txt`
      `git add file1.txt`
      `git commit -m "First"`
    }

    @repo = Git::Repository.open "/tmp/giraffe_repo"
  end

  after :each do
    FileUtils.rm_r "/tmp/giraffe_repo"
  end

  it "shows contents through #data" do
    @repo.object_for("file0.txt").data.chomp.should == $$.to_s
  end

  it "writes to the file with #data= but does not commit" do
    o = @repo.object_for "file0.txt"
    o.data = "Hi there"

    File.read(o.full_path).should == "Hi there"
    o.data.should == $$.to_s
    @repo.object_for("file0.txt").data.should == $$.to_s
  end

  it "can be staged with #add!" do
    Dir.chdir("/tmp/giraffe_repo") { `git status`.should =~ /nothing to commit/ }

    @repo.object_for("file0.txt").data = "1"
    @repo.object_for("file1.txt").data = "2"

    @repo.object_for("file0.txt").add!

    Dir.chdir("/tmp/giraffe_repo") {
      `git status`.should =~ /changes to be committed.+?file0.txt.+?changed but not updated.+?file1.txt/mi
    }
  end

  it "can be commit!ted if staged" do
    o = @repo.object_for("file0.txt")
    o.data = "1"
    o.add!
    o.commit! "message"

    @repo = @repo.HEAD

    o2 = @repo.object_for "file0.txt"
    o2.sha1.should_not == o.sha1
    o2.data.should == "1"
  end

  it "sets the commit message to given" do
    o = @repo.object_for("file0.txt")
    o.data = "1"
    o.add!
    o.commit! "Yay my message"

    Dir.chdir("/tmp/giraffe_repo") { `git log -n 1`.should =~ /Yay my message/ }
  end

end

describe "repository history" do

  before :each do
    FileUtils.mkdir "/tmp/giraffe_not_a_repo"

    FileUtils.mkdir_p "/tmp/giraffe_repo/tracked/subdir"

    FileUtils.touch   "/tmp/giraffe_repo/tracked/file.txt"
    FileUtils.touch   "/tmp/giraffe_repo/tracked/subdir/file2.txt"
    FileUtils.touch   "/tmp/giraffe_repo/tracked/no_file.txt"

    FileUtils.mkdir_p "/tmp/giraffe_repo/not_tracked"
    FileUtils.touch   "/tmp/giraffe_repo/not_tracked/no_file.txt"

    Dir.chdir("/tmp/giraffe_repo") {
      `git init`
      `git add tracked/file.txt`
      `git commit -m "First"`
      `git add tracked/subdir`
      `git commit -m "Second"`
    }

    @repo = Git::Repository.open "/tmp/giraffe_repo"
  end

  after :each do
    FileUtils.rm_r "/tmp/giraffe_repo"
    FileUtils.rm_r "/tmp/giraffe_not_a_repo"
  end

  it "is accessed through Tree#commits" do
    @repo.commits
  end

  it "consists of an Array of Commit objects" do
    @repo.commits.each {|c| c.should be_kind_of(Git::Commit) }
  end

  it "sorts commits newest to oldest" do
    @repo.commits[0].subject.should == "Second"
    @repo.commits[1].subject.should == "First"
  end

  it "can be viewed for individual blob with Blob#commits" do
    commits = @repo.object_for("tracked/file.txt").commits
    commits.size.should == 1
    commits.first.subject.should == "First"
  end

  it "can be limited by giving the number of commits to show" do
    @repo.commits.size.should == 2
    @repo.commits(1).size.should == 1
  end

end


describe "searching the repository" do

  before :each do
    FileUtils.mkdir_p "/tmp/giraffe_repo/tracked/subdir"

    File.open("/tmp/giraffe_repo/file0.txt", "w+") {|f| f.puts "hi bob" }
    File.open("/tmp/giraffe_repo/file1.txt", "w+") {|f| f.puts "Hi, james" }
    File.open("/tmp/giraffe_repo/file2.txt", "w+") {|f| f.puts "hippie" }

    Dir.chdir("/tmp/giraffe_repo") {
      `git init`
      `git add file0.txt`
      `git add file1.txt`
      `git add file2.txt`
      `git commit -m "First"`
    }

    @repo = Git::Repository.open "/tmp/giraffe_repo"
  end

  after :each do
    FileUtils.rm_r "/tmp/giraffe_repo"
  end

  it "returns an Array of objects + line that matched inside object" do
    matches = @repo.grep "bob"
    matches.size.should == 1
    matches.first.first.path.should == "file0.txt"
  end

  it "only considers whole words" do
    @repo.grep("hi").select {|obj, line| obj.path == "file2.txt" }.should be_empty
  end

  it "is case insensitive" do
    matches = @repo.grep "hi"
    matches.size.should == 2
    matches.first.first.path.should == "file0.txt"
    matches.last.first.path.should == "file1.txt"
  end

end

describe "diffing revisions" do

  before :each do
    FileUtils.mkdir_p "/tmp/giraffe_repo/tracked/subdir"

    Dir.chdir("/tmp/giraffe_repo") {
      `git init`
      File.open("file0.txt", "w+") {|f| f.puts "hi bob" }
      `git add file0.txt`
      `git commit -m "First"`
      File.open("file0.txt", "w+") {|f| f.puts "hi joe" }
      `git add file0.txt`
      `git commit -m "Second"`
    }

    @repo = Git::Repository.open "/tmp/giraffe_repo"
  end

  after :each do
    FileUtils.rm_r "/tmp/giraffe_repo"
  end

  it "shows diff using receiver as current revision" do
    prev = @repo.object_for("file0.txt").commits.last.sha1
    diff = @repo.object_for("file0.txt").diff prev

    diff.should =~ /^-hi bob\s+^\+hi joe/m
  end

end
