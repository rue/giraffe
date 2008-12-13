require "spec/spec_helper"

describe "Page history for a top-level page" do
  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "shows commits that affected page" do
    commits = Nokogiri::HTML.parse(get("/h/file1").body).css ".commit"

    commits.find {|commit|
      commit.css("a").first.content =~ /Initial Commit/
    }.should_not == nil
  end

  it "does not show commits that did not affect page" do
    commits = Nokogiri::HTML.parse(get("/h/file1").body).css ".commit"

    commits.size.should == 1

    commits.find {|commit|
      commit.css("a").first.content =~ /Initial Commit/
    }.should_not == nil
  end

  it "contains link to current resource and to editable resource" do
    links = Nokogiri::HTML.parse(get("/h/file1").body).css ".sidebar a"

    links.size.should == 2

    links.first["href"].should == "/file1"
    links.first.content.should =~ /current/i

    links.last["href"].should == "/e/file1"
    links.last.content.should =~ /edit/i
  end

  it "commits link to commit view" do
    commits = Nokogiri::HTML.parse(get("/h/file1").body).css ".commit"
    commits.size.should == 1

    cs = Giraffe.wiki.object_for("file1.txt").commits

    commits[0].css("a").size.should == 1
    commits[0].css("a").first["href"].should == "/c/#{cs.first.sha1}"
  end

  it "all older commits have a link to diff against most recent commit" do
    add_commits

    commits = Nokogiri::HTML.parse(get("/h/file1").body).css ".commit"
    commits.size.should == 2

    commits[0].css("a").size.should == 1
    commits[1].css("a").size.should == 2

    cs = Giraffe.wiki.object_for("file1.txt").commits

    commits[1].css("a").last["href"].should == "/d/#{cs[1].sha1}/file1"
    commits[1].css("a").last.content.should =~ /diff/i
  end
end


describe "Page history for a page in a subdirectory" do
  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "shows commits that affected page" do
    commits = Nokogiri::HTML.parse(get("/h/subdir/sub_subdir/file9").body).css ".commit"

    commits.find {|commit|
      commit.css("a").first.content =~ /Third Commit/
    }.should_not == nil
  end

  it "does not show commits that did not affect page" do
    commits = Nokogiri::HTML.parse(get("/h/subdir/sub_subdir/file9").body).css ".commit"

    commits.size.should == 1

    commits.find {|commit|
      commit.css("a").first.content =~ /Third Commit/
    }.should_not == nil
  end

  it "contains link to current resource and to editable resource" do
    links = Nokogiri::HTML.parse(get("/h/subdir/sub_subdir/file9").body).css ".sidebar a"

    links.size.should == 2

    links.first["href"].should == "/subdir/sub_subdir/file9"
    links.first.content.should =~ /current/i

    links.last["href"].should == "/e/subdir/sub_subdir/file9"
    links.last.content.should =~ /edit/i
  end

  it "commits link to commit view" do
    commits = Nokogiri::HTML.parse(get("/h/subdir/sub_subdir/file9").body).css ".commit"
    commits.size.should == 1

    cs = Giraffe.wiki.object_for("subdir/sub_subdir/file9.txt").commits

    commits[0].css("a").size.should == 1
    commits[0].css("a").first["href"].should == "/c/#{cs.first.sha1}"
  end

  it "all older commits have a link to diff against most recent commit" do
    add_commits

    commits = Nokogiri::HTML.parse(get("/h/subdir/sub_subdir/file9").body).css ".commit"
    commits.size.should == 2

    commits[0].css("a").size.should == 1
    commits[1].css("a").size.should == 2

    cs = Giraffe.wiki.object_for("subdir/sub_subdir/file9.txt").commits

    commits[1].css("a").last["href"].should == "/d/#{cs[1].sha1}/subdir/sub_subdir/file9"
    commits[1].css("a").last.content.should =~ /diff/i
  end

end

describe "Page history for repository" do
  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "shows all commits affecting wiki in reverse order" do
    commits = Nokogiri::HTML.parse(get("/h").body).css ".commit"

    commits.size.should == 3

    commits[0].css("a").first.content.should =~ /Third Commit/
    commits[1].css("a").first.content.should =~ /Second Commit/
    commits[2].css("a").first.content.should =~ /Initial Commit/
  end

  it "does not contain sidebar links" do
    links = Nokogiri::HTML.parse(get("/h").body).css ".sidebar a"
    links.size.should == 0
  end

  it "links commits to commit view" do
    commits = Nokogiri::HTML.parse(get("/h").body).css ".commit"

    cs = Giraffe.wiki.commits

    commits[0].css("a").size.should == 1
    commits[0].css("a").first["href"].should == "/c/#{cs.first.sha1}"
  end
end
