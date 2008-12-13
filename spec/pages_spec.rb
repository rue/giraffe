require "spec/spec_helper"

describe "Wiki page list at toplevel using /pages/" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "contains names of tracked pages conforming to URI mapping (.txt here)" do
    entries = Nokogiri::HTML.parse(get("/pages").body).css ".entry > .page"
    %w[ file1 file5 file9 ].all? {|page|
      entries.find {|entry|
        link = entry.css("a").first
        link.content =~ %r|#{page}|i
      }
    }.should == true
  end

  it "does not contain names of tracked pages not conforming to URI mapping (.txt here)" do
    entries = Nokogiri::HTML.parse(get("/pages").body).css ".entry > .page"

    %w[ file11 file3 file7 file6 file10 ].any? {|page|
      entries.find {|entry|
        link = entry.css("a").first
        link.content =~ %r|#{page}|i
      }
    }.should == false
  end

  it "does not contain names of nontracked pages" do
    links = Nokogiri::HTML.parse(get("/pages").body).css "a"

    %w[ file4 file8 file12 ].any? {|page|
      links.find {|link|
        link["href"] =~ %r|^/#{page}| or link.content =~ %r|#{page}|i
      }
    }.should == false
  end

  it "lists pages inside subdirectories after those directories" do
    entries = Nokogiri::HTML.parse(get("/pages").body).css ".entry > .page"

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
    entries = Nokogiri::HTML.parse(get("/pages").body).css ".entry > .page"

    [%w[file1 file1],
     %w[subdir/file5 file5],
     %w[subdir/sub_subdir/file9 file9]].each_with_index {|(file, name), i|
      links = entries[i].css("a")

      links[0]["href"].should =~ %r|^/#{file}| and
      links[0].content.should =~ %r|#{name}|i and
      links[1]["href"].should =~ %r|^/editable/#{file}| and
      links[1].content.should =~ %r|edit|i and
      links[2]["href"].should =~ %r|^/changes/#{file}| and
      links[2].content.should =~ %r|history|i
    }
  end

end


describe "Wiki page list from subdirectory using /pages/sub/diffir/path" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "does not contain pages from higher up in the hierarchy" do
    entries = Nokogiri::HTML.parse(get("/pages/subdir").body).css ".entry > .page"

    entries.any? {|entry|
      link = entry.css("a").first
      link.content =~ %r|file1|i
    }.should == false
  end

  it "contains names of tracked pages in further subdirectories" do
    entries = Nokogiri::HTML.parse(get("/pages").body).css ".entry > .page"

    entries.find {|entry|
      link = entry.css("a").first
      link.content =~ %r|file9|i
    }.should_not == nil
  end

  it "does not contain names of tracked pages not conforming to URI mapping (.txt here)" do
    entries = Nokogiri::HTML.parse(get("/pages/subdir").body).css ".entry > .page"

    %w[ file11 file7 file6 file10 ].any? {|page|
      entries.find {|entry|
        link = entry.css("a").first
        link.content =~ %r|#{page}|i
      }
    }.should == false
  end

  it "does not contain names of nontracked pages" do
    links = Nokogiri::HTML.parse(get("/pages/subdir").body).css "a"

    %w[ file8 file12 ].any? {|page|
      links.find {|link|
        link["href"] =~ %r|^/#{page}| or link.content =~ %r|#{page}|i
      }
    }.should == false
  end

  it "contains links to page, an editable page and the page history, with correct prefix path" do
    entries = Nokogiri::HTML.parse(get("/pages/subdir").body).css ".entry > .page"

    [%w[ subdir/file5 file5 ],
     %w[ subdir/sub_subdir/file9 file9 ]].each_with_index {|(file, name), i|
      links = entries[i].css("a")

      links[0]["href"].should =~ %r|^/#{file}| and
      links[0].content.should =~ %r|#{name}|i and
      links[1]["href"].should =~ %r|^/editable/#{file}| and
      links[1].content.should =~ %r|edit|i and
      links[2]["href"].should =~ %r|^/changes/#{file}| and
      links[2].content.should =~ %r|history|i
    }
  end

end
