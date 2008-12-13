require "spec/spec_helper"

describe "Raw page resource at toplevel" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "presents the current raw content of the page" do
    get("/r/file1").body.should == "File *one* text #{@proc}"
  end

  it "produces plain text output" do
    get("/r/file1").headers["CONTENT-TYPE"].should =~ %r{text/plain}
  end

end

describe "Raw page resource in a subirectory" do

  before :each do
    create_good_repo

    Waves << Giraffe
  end

  after :each do
    delete_good_repo

    Waves.applications.clear
  end

  it "presents the current raw content of the page" do
    get("/r/subdir/file5").body.should == "File *five* text #{@proc}"
  end

  it "produces plain text output" do
    get("/r/subdir/file5").headers["CONTENT-TYPE"].should =~ %r{text/plain}
  end

end
