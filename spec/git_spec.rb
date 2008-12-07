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
    fail
  end

  it "returns nil if path is untracked" do
    fail
  end

end


