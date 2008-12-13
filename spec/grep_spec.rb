require "spec/spec_helper"


describe "Grep result page" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "contains link to pages where search was successful" do
    links = Nokogiri::HTML.parse(get("/grep/one?").body).css ".match a"
    links.size.should == 1
    links.first["href"].should == "/file1"

    links = Nokogiri::HTML.parse(get("/grep/text?").body).css ".match a"
    links.size.should == 3
    links[0]["href"].should == "/file1"
    links[1]["href"].should == "/subdir/file5"
    links[2]["href"].should == "/subdir/sub_subdir/file9"
  end

  it "contains (unrendered) line that matched in successful search" do
    match = Nokogiri::HTML.parse(get("/grep/one?").body).css ".match"
    match.size.should == 1

    match.first.content.should =~ /File \*one\* text #{$$}/
  end

  it "does not link to pages that match but are not part of wiki" do
    links = Nokogiri::HTML.parse(get("/grep/one?").body).css ".match a"
    links.find {|link| link["href"] =~ /file(2|3|4|6|7|8)/}.should == nil
  end

  it "supports the completely useless but fun /grep/term/ style" do
    match = Nokogiri::HTML.parse(get("/grep/one/").body).css ".match"
    match.size.should == 1
    match.first.content.should =~ /File \*one\* text #{$$}/

    links = Nokogiri::HTML.parse(get("/grep/one/").body).css ".match a"
    links.find {|link| link["href"] =~ /file(2|3|4|6|7|8)/}.should == nil
  end

  it "has some measure of safety" do
    fail
  end

end

describe "Initiating a grep from the top menu" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "produces a GET request of the form /s?for=term" do
    form = Nokogiri::HTML.parse(get("/file1").body).css("form[@name='greppy']").first
    form["action"].should == "/s"
    form["method"].should == "GET"
    form.css("input").size.should == 1
    form.css("input").first["type"].should == "text"
    form.css("input").first["name"].should == "for"
  end

  it "redirects the request as a GET from /s?for=term to /grep/term" do
    response = get "/s?for=bunnies"
    response.status.should == 303
    response.location.should == "/grep/bunnies"
  end

  it "allows terms using / (i.e. path matches)" do
    response = get "/s?for=subdir/file5"
    response.status.should == 303
    response.location.should == "/grep/subdir/file5"
  end

  it "fails if there is no search term or term is empty" do
    get("/s?term").status.should == 400
    get("/s?for=").status.should == 400
    get("/s?for").status.should == 400
    get("/s?").status.should == 400
    get("/s").status.should == 400
  end

end

