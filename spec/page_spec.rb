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

end
