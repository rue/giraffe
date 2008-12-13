require "spec/spec_helper"


describe "Search result page" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "contains link to pages where search was successful" do
    links = Nokogiri::HTML.parse(get("/s/one?").body).css ".match a"
    links.size.should == 1
    links.first["href"].should == "/file1"

    links = Nokogiri::HTML.parse(get("/s/text?").body).css ".match a"
    links.size.should == 3
    links[0]["href"].should == "/file1"
    links[1]["href"].should == "/subdir/file5"
    links[2]["href"].should == "/subdir/sub_subdir/file9"
  end

  it "contains (unrendered) line that matched in successful search" do
    match = Nokogiri::HTML.parse(get("/s/one?").body).css ".match"
    match.size.should == 1

    match.first.content.should =~ /File \*one\* text #{$$}/
  end

  it "does not link to pages that match but are not part of wiki" do
    links = Nokogiri::HTML.parse(get("/s/one?").body).css ".match a"

    links.find {|link| link["href"] =~ /file(2|3|4|6|7|8)/}.should == nil
  end

  it "fails if there is no search term" do
    get("/s/").status.should == 400
    get("/s").status.should == 400
  end
end

