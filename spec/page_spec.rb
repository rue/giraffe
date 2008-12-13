require "spec/spec_helper"


describe "Existing wiki page at wiki root" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "shows the content of the page" do
    get("/file1").body.should =~ /File.*?one.*?text #{@proc}/
  end

  it "has had its Markdown rendered" do
    get("/file1").body.should =~ /File\s+<em>\s*one\s*<\/em>\s+text #{@proc}/
  end

  it "has a link to the editable page, page's history and raw version of page" do
    links = Nokogiri::HTML.parse(get("/file1").body).css "#page_actions a"

    links.find {|link|
      link["href"] == "/e/file1" and link.content =~ /edit/i
    }.should_not == nil

    links.find {|link|
      link["href"] == "/h/file1" and link.content =~ /history/i
    }.should_not == nil

    links.find {|link|
      link["href"] == "/r/file1" and link.content =~ /raw/i
    }.should_not == nil
  end

end

describe "Existing wiki page in a subdirectory" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "shows the content of the page" do
    get("/subdir/file5").body.should =~ /File.*?five.*?text #{@proc}/
  end

  it "has had its Markdown rendered" do
    get("/subdir/file5").body.should =~ /File\s+<em>\s*five\s*<\/em>\s+text #{@proc}/
  end

  it "has a link to the editable page, page's history and raw version of page with correct path prefix" do
    links = Nokogiri::HTML.parse(get("/subdir/file5").body).css "#page_actions a"

    links.find {|link|
      link["href"] == "/e/subdir/file5" and link.content =~ /edit/i
    }.should_not == nil

    links.find {|link|
      link["href"] == "/h/subdir/file5" and link.content =~ /history/i
    }.should_not == nil

    links.find {|link|
      link["href"] == "/r/subdir/file5" and link.content =~ /raw/i
    }.should_not == nil
  end

end

describe "Page which does not exist" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "redirects to editable page of the same name" do
    response = get("/file0")

    response.status.should == 302
    response.location.should == "/e/file0"

    response = get("/subdir/file0")

    response.status.should == 302
    response.location.should == "/e/subdir/file0"
  end

end

describe "Page which exists in repo but does not conform to URI mapping (.txt here)" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "redirects to editable page of the same name that conforms to URI mapping" do
    response = get("/file0")

    response.status.should == 302
    response.location.should == "/e/file0"

    response = get("/subdir/file0")

    response.status.should == 302
    response.location.should == "/e/subdir/file0"
  end

end

describe "Subdirectory given as a page" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "redirects to page list for that directory" do
    response = get("/subdir")

    response.status.should == 302
    response.location.should == "/l/subdir"
  end

end
