require "spec/spec_helper"

describe "Wiki page list at toplevel" do

#  File.open("/tmp/list.html", "w+") {|f| f << get("/list").body }

  before do
    Waves << Giraffe
  end

  after do
    Waves.applications.clear
  end

  it "contains names of tracked pages" do
    entries = Nokogiri::HTML.parse(get("/list").body).css ".entry > .page"

    %w[file1 file3 file5].all? {|page|
      entries.find {|entry|
        link = entry.css("a").first
        link.content =~ %r|#{page}|i
      }
    }.should == true
  end

  it "does not contain names of nontracked pages" do
    links = Nokogiri::HTML.parse(get("/list").body).css "a"

    %w[file2 file4 file6].any? {|page|
      links.find {|link|
        link["href"] =~ %r|^/#{page}| or link.content =~ %r|#{page}|i
      }
    }.should == false
  end

  it "lists pages inside subdirectories after those directories" do
    entries = Nokogiri::HTML.parse(get("/list").body).css ".entry > .page"

    entries.find {|entry|
      link = entry.css("a").first
      link["href"] =~ %r|^/subdir/file3| and link.content =~ %r|file3|i
    }.should.not == nil

    entries.find {|entry|
      link = entry.css("a").first
      link["href"] =~ %r|^/subdir/sub_subdir/file5| and link.content =~ %r|file5|i
    }.should.not == nil
  end

  it "contains links to page, an editable page and the page history" do
    entries = Nokogiri::HTML.parse(get("/list").body).css ".entry > .page"

    [%w[file1 file1],
     %w[subdir/file3 file3],
     %w[subdir/sub_subdir/file5 file5]].each_with_index {|(file, name), i|
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

describe "Wiki page list at subdirectory" do
  before do
    Waves << Giraffe
  end

  after do
    Waves.applications.clear
  end

  it "contains names of tracked pages in that subdirectory" do
    body = get("/list/subdir").body
    body.should =~ /\bFile3\b/i
    body.should =~ /\bFile5\b/i
  end

  it "does not contain names of nontracked pages" do
    body = get("/list/subdir").body
    body.should.not =~ /\bFile4\b/i
  end

  it "does not contain pages in higher directories" do
    body = get("/list/subdir").body
    body.should.not =~ /\bFile1\b/i
  end

  it "lists pages inside further subdirectories after those directories" do
    body = get("/list/subdir").body
    body.should =~ /\bsub_subdir\/\b.*?\bFile5\b/im
  end

end

