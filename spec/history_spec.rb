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

end
