GIRAFFE_ROOT  = File.expand_path(File.join(File.dirname(__FILE__), ".."))
GIRAFFE_LIBS  = File.join GIRAFFE_ROOT, "lib"

GIRAFFE_WAVES = File.join GIRAFFE_ROOT, "waves", "lib"


$LOAD_PATH.unshift GIRAFFE_LIBS
$LOAD_PATH.unshift GIRAFFE_ROOT
$LOAD_PATH.unshift GIRAFFE_WAVES

require "waves"
require "waves/runtime/mocks"

require "rubygems"
  require "nokogiri"

Waves::Runtime.new
include Waves::Mocks

require "run_giraffe_run"

require "fileutils"


# Helpers

def create_good_repo()
  @proc   = $$
  @repo   = "/tmp/giraffe_spec_repo_#{$$}"
  @wiki   = "weeky"

  @config = "/tmp/giraffe_spec_config_#{$$}"

  FileUtils.mkdir_p File.join(@repo, @wiki, "subdir", "sub_subdir")

  Dir.chdir @repo do
    `git init`
  end

  Dir.chdir File.join(@repo, @wiki) do
    File.open("file1.txt", "w+")                         {|f| f << "File *one* text #{$$}" }
    File.open("file2", "w+")                             {|f| f << "File two text #{$$}" }
    File.open("file3.markdown", "w+")                    {|f| f << "File three text #{$$}" }
    File.open("file4.txt", "w+")                         {|f| f << "File four text #{$$}" }
    File.open("subdir/file5.txt", "w+")                  {|f| f << "File *five* text #{$$}" }
    File.open("subdir/file6", "w+")                      {|f| f << "File six text #{$$}" }
    File.open("subdir/file7.markdown", "w+")             {|f| f << "File seven text #{$$}" }
    File.open("subdir/file8.txt", "w+")                  {|f| f << "File eight text #{$$}" }
    File.open("subdir/sub_subdir/file9.txt", "w+")       {|f| f << "File *nine* text #{$$}" }
    File.open("subdir/sub_subdir/file10", "w+")          {|f| f << "File ten text #{$$}" }
    File.open("subdir/sub_subdir/file11.markdown", "w+") {|f| f << "File eleven text #{$$}" }
    File.open("subdir/sub_subdir/file12.txt", "w+")      {|f| f << "File twelve text #{$$}" }


    `git add file1.txt subdir/file5.txt subdir/sub_subdir/file11.markdown`
    `git commit -m \"Initial Commit\"`
    `git add file3.markdown subdir/file7.markdown subdir/file6`
    `git commit -m \"Second Commit\"`
    `git add file2 subdir/sub_subdir/file9.txt subdir/sub_subdir/file10`
    `git commit -m \"Third Commit\"`
  end

  config = <<-ENDCONFIG
# Directory in which the wiki pages live
Giraffe.wikiroot    = "#{File.join @repo, @wiki}"

# Directory in which .git lives
Giraffe.reporoot    = "#{File.join @repo, @wiki}/.."

# Append extension to *all* page name candidates
Giraffe.to_filename = lambda {|uri| uri + ".txt" }
Giraffe.to_uri      = lambda {|file| file.chomp ".txt" }

# No showing stuff other than .txt for now
Giraffe.list_filter = lambda {|file| file =~ /\.txt$/ }

# Resource files allowed
RESOURCES = { "png"     => {:mime => "image/png"} } unless defined? RESOURCES

Giraffe.resource_filter = lambda {|uri|
                                uri.match /.+\.(.+)$/
                                RESOURCES[$1]
                                }
  ENDCONFIG

  File.open(@config, "w+") {|f| f << config }

  ENV["GIRAFFE_CONF"] = @config
end

def add_commits()
  Dir.chdir File.join(@repo, @wiki) do
    File.open("file1.txt", "a+")                         {|f| f << "more file one" }
    File.open("subdir/file5.txt", "a+")                  {|f| f << "file more five" }
    File.open("subdir/sub_subdir/file9.txt", "a+")       {|f| f << "nine more file" }

    `git add file1.txt subdir/file5.txt subdir/sub_subdir/file9.txt`
    `git commit -m \"Fourth Commit\"`
  end
end

def delete_good_repo()
  FileUtils.rm @config
  FileUtils.rm_r @repo
end
