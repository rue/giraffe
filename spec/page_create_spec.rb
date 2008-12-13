require "spec/spec_helper"


describe "Creating a new page resource with PUT" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "redirects to the page resource" do
    response = put("/file0", :input => "contents=Bleh%20this%20sucks&message=whatever")

    response.status.should == 302
    response.location.should == "/file0"
  end

  it "commits the update into the repository indicating new file" do
    old = Dir.chdir(@repo) { `git show HEAD 2>&1` }

    response = put("/file0", :input => "contents=w00t&message=Cool%20#{@proc}%20message")

    noob = Dir.chdir(@repo) { `git show HEAD 2>&1` }

    noob.should_not == old
    noob.should =~ /Cool #{@proc} message\s*$\s*Giraffe created file0.txt/im
  end

  it "shows the updated resource when having redirected" do
    put "/file0", :input => "contents=w00t&message=Cool%20#{@proc}%20message"

    noob = Nokogiri::HTML.parse(get("/file0").body).css("#body").first.content

    noob.should =~ /w00t/
    noob.should_not =~ /cool\s+#{@proc}\s+message/i
  end

  it "fails if the page already existed" do
    response = put "/file1", :input => "contents=Bleh%20this%20sucks&message=whatever"
    response.status.should == 400
  end
end

