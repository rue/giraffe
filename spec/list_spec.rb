require "spec/spec_helper"

describe "Wiki page list at toplevel" do

  before :each do
    time = Time.now.to_i

    @repo   = "/tmp/giraffe_list_spec_repo_#{$$}_#{time}"
    @wiki   = "weeky"

    @config = "/tmp/giraffe_list_spec_config_#{$$}_#{time}"

    FileUtils.mkdir_p File.join(@repo, @wiki, "subdir", "sub_subdir")

    Dir.chdir @repo do
      `git init`
    end

    Dir.chdir File.join(@repo, @wiki) do
      File.open("file1.txt", "w+")                         {|f| f << "File one list text #{$$}" }
      File.open("file2", "w+")                             {|f| f << "File two list text #{$$}" }
      File.open("file3.markdown", "w+")                    {|f| f << "File three list text #{$$}" }
      File.open("file4.txt", "w+")                         {|f| f << "File four list text #{$$}" }
      File.open("subdir/file5.txt", "w+")                  {|f| f << "File five list text #{$$}" }
      File.open("subdir/file6", "w+")                      {|f| f << "File six list text #{$$}" }
      File.open("subdir/file7.markdown", "w+")             {|f| f << "File seven list text #{$$}" }
      File.open("subdir/file8.txt", "w+")                  {|f| f << "File eight list text #{$$}" }
      File.open("subdir/sub_subdir/file9.txt", "w+")       {|f| f << "File nine list text #{$$}" }
      File.open("subdir/sub_subdir/file10", "w+")          {|f| f << "File ten list text #{$$}" }
      File.open("subdir/sub_subdir/file11.markdown", "w+") {|f| f << "File eleven list text #{$$}" }
      File.open("subdir/sub_subdir/file12.txt", "w+")      {|f| f << "File twelve list text #{$$}" }


      `git add file1.txt subdir/file5.txt subdir/sub_subdir/file11.markdown`
      `git commit -m \"Initial Commit\"`
      `git add file3.markdown subdir/file7.markdown subdir/file6`
      `git commit -m \"Second Commit\"`
      `git add file2 subdir/sub_subdir/file9.txt subdir/sub_subdir/file10`
      `git commit -m \"Third Commit\"`
    end

    config = <<-ENDCONFIG
# Directory in which the wiki pages live
Giraffe::Conf.wikiroot    = "#{File.join @repo, @wiki}"

# Directory in which .git lives
Giraffe::Conf.reporoot    = "#{File.join @repo, @wiki}/.."

# Append extension to *all* page name candidates
Giraffe::Conf.to_filename = lambda {|uri| uri + ".txt" }
Giraffe::Conf.to_uri      = lambda {|file| file.chomp ".txt" }

# No showing stuff other than .txt for now
Giraffe::Conf.list_filter = lambda {|file| file =~ /\.txt$/ }

# Resource files allowed
RESOURCES = { "png"     => {:mime => "image/png"}
            }

Giraffe::Conf.resource_filter = lambda {|uri|
                                  uri.match /.+\.(.+)$/
                                  RESOURCES[$1]
                                  }
    ENDCONFIG

    File.open(@config, "w+") {|f| f << config }

    ENV["GIRAFFE_CONF"] = @config

    Waves << Giraffe
  end

  after :each do
    FileUtils.rm_r @config
    FileUtils.rm_r @repo
    Waves.applications.clear
  end

  it "contains names of tracked pages conforming to URI mapping (.txt here)" do
    File.open("/tmp/list.html", "w+") {|f| f << get("/l").body }

    entries = Nokogiri::HTML.parse(get("/l").body).css ".entry > .page"

    %w[ file1 file5 file9 ].all? {|page|
      entries.find {|entry|
        link = entry.css("a").first
        link.content =~ %r|#{page}|i
      }
    }.should == true
  end

  it "does not contain names of tracked pages not conforming to URI mapping (.txt here)" do
    entries = Nokogiri::HTML.parse(get("/l").body).css ".entry > .page"

    %w[ file11 file3 file7 file6 file10 ].any? {|page|
      entries.find {|entry|
        link = entry.css("a").first
        link.content =~ %r|#{page}|i
      }
    }.should == false
  end

  it "does not contain names of nontracked pages" do
    links = Nokogiri::HTML.parse(get("/l").body).css "a"

    %w[ file4 file8 file12 ].any? {|page|
      links.find {|link|
        link["href"] =~ %r|^/#{page}| or link.content =~ %r|#{page}|i
      }
    }.should == false
  end

  it "lists pages inside subdirectories after those directories" do
    entries = Nokogiri::HTML.parse(get("/l").body).css ".entry > .page"

    entries.find {|entry|
      link = entry.css("a").first
      link["href"] =~ %r|^/subdir/file5| and link.content =~ %r|file5|i
    }.should_not == nil

    entries.find {|entry|
      link = entry.css("a").first
      link["href"] =~ %r|^/subdir/sub_subdir/file9| and link.content =~ %r|file9|i
    }.should_not == nil
  end

  it "contains links to page, an editable page and the page history" do
    entries = Nokogiri::HTML.parse(get("/l").body).css ".entry > .page"

    [%w[file1 file1],
     %w[subdir/file5 file5],
     %w[subdir/sub_subdir/file9 file9]].each_with_index {|(file, name), i|
      links = entries[i].css("a")

      links[0]["href"].should =~ %r|^/#{file}| and
      links[0].content.should =~ %r|#{name}|i and
      links[1]["href"].should =~ %r|^/e/#{file}| and
      links[1].content.should =~ %r|edit|i and
      links[2]["href"].should =~ %r|^/h/#{file}| and
      links[2].content.should =~ %r|history|i
    }
  end

end
#
#describe "Wiki page list at subdirectory" do
#  before do
#    Waves << Giraffe
#  end
#
#  after do
#    Waves.applications.clear
#  end
#
#  it "contains names of tracked pages in that subdirectory" do
#    body = get("/l/subdir").body
#    body.should =~ /\bFile3\b/i
#    body.should =~ /\bFile5\b/i
#  end
#
#  it "does not contain names of nontracked pages" do
#    body = get("/l/subdir").body
#    body.should.not =~ /\bFile4\b/i
#  end
#
#  it "does not contain pages in higher directories" do
#    body = get("/l/subdir").body
#    body.should.not =~ /\bFile1\b/i
#  end
#
#  it "lists pages inside further subdirectories after those directories" do
#    body = get("/l/subdir").body
#    body.should =~ /\bsub_subdir\/\b.*?\bFile5\b/im
#  end
#
#end

