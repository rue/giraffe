require "spec/spec_helper"


describe "POSTing an update to an existing page resource" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "redirects to the page resource" do
    response = post("/file1", :input => "contents=Bleh%20this%20sucks&message=whatever")

    response.status.should == 302
    response.location.should == "/file1"
  end

  it "commits the update into the repository" do
    old = Dir.chdir(@repo) { `git show HEAD 2>&1` }

    response = post("/file1", :input => "contents=Bleh%20this%20sucks&message=Whatever%20#{@proc}")

    noob = Dir.chdir(@repo) { `git show HEAD 2>&1` }

    noob.should_not == old
    noob.should =~ /Whatever #{@proc}\s*$\s*Giraffe edited file1.txt/im
  end

  it "shows the updated resource when having redirected" do
    old = Nokogiri::HTML.parse(get("/file1").body).css("#body").first.content
    old.should =~ /File\s+one\s+text #{@proc}/

    response = post("/file1", :input => "contents=Bleh%20this%20sucks#{@proc}&message=whaTever")

    noob = Nokogiri::HTML.parse(get("/file1").body).css("#body").first.content
    noob.should =~ /Bleh this sucks#{@proc}/

    noob.should_not =~ /\bwhaTever\b/
  end

end

