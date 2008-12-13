require "spec/spec_helper"


describe "Existing editable page" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "presents the current raw content of the page in an editable section" do
    inputs = Nokogiri::HTML.parse(get("/e/file1").body).css("#forms > form > textarea")
    current = inputs.find {|i| i["name"] == "contents" }

    current.content.should =~ /^\s*File \*one\* text #{@proc}\s*$/
  end

  it "presents an additional field in which a commit message may be entered" do
    inputs = Nokogiri::HTML.parse(get("/e/file1").body).css("#forms > form > textarea")
    current = inputs.find {|i| i["name"] == "message" }

    current.content.should == ""
  end

  it "has a button with which to submit page text" do
    inputs = Nokogiri::HTML.parse(get("/e/file1").body).css("#forms > form input")
    inputs.find {|i| i["type"] == "submit" }.should_not == nil
  end

  it "will POST to the page resource" do
    form = Nokogiri::HTML.parse(get("/e/file1").body).css("#forms > form").first

    form["method"].should == "post"
    form["action"].should == "/file1"
  end

  it "contains links to go to page resource or to page history" do
    links = Nokogiri::HTML.parse(get("/e/file1").body).css "a"

    links.find {|link| link["href"] == "/file1" }.should_not == nil
    links.find {|link| link["href"] == "/h/file1" and link.content =~ /history/i }.should_not == nil
  end
end

describe "Nonexisting editable page" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "presents an empty content input section" do
    inputs = Nokogiri::HTML.parse(get("/e/file0").body).css("#forms > form > textarea")
    current = inputs.find {|i| i["name"] == "contents" }

    current.content.should == ""
  end

  it "presents an additional field in which a commit message may be entered" do
    inputs = Nokogiri::HTML.parse(get("/e/file0").body).css("#forms > form > textarea")
    current = inputs.find {|i| i["name"] == "message" }

    current.content.should == ""
  end

  it "has a button with which to submit page text" do
    inputs = Nokogiri::HTML.parse(get("/e/file0").body).css("#forms > form input")
    inputs.find {|i| i["type"] == "submit" }.should_not == nil
  end

  it "will PUT to the page resource" do
    form = Nokogiri::HTML.parse(get("/e/file0").body).css("#forms > form").first

    form["method"].should == "put"
    form["action"].should == "/file0"
  end

  it "does not contain links to go to page resource or to page history" do
    links = Nokogiri::HTML.parse(get("/e/file0").body).css "a"

    links.find {|link| link["href"] == "/file0" }.should == nil
    links.find {|link| link["href"] == "/h/file0" }.should == nil
  end
end


describe "Editable page in a subdirectory" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "presents the page's current content in an editable field" do
    inputs = Nokogiri::HTML.parse(get("/e/subdir/file5").body).css("#forms > form > textarea")
    current = inputs.find {|i| i["name"] == "contents" }

    current.content.should =~ /^\s*File \*five\* text #{@proc}\s*$/
  end

  it "includes the correct directory prefixes" do
    editable = get("/e/subdir/file5").body

    form = Nokogiri::HTML.parse(editable).css("#forms > form").first

    form["method"].should == "post"
    form["action"].should == "/subdir/file5"

    links = Nokogiri::HTML.parse(editable).css "a"

    links.find {|link| link["href"] == "/subdir/file5" }.should_not == nil
    links.find {|link| link["href"] == "/h/subdir/file5" and link.content =~ /history/i }.should_not == nil
  end
end
