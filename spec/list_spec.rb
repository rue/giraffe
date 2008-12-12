require "spec/spec_helper"


describe "Wiki page list at toplevel" do
  before do
    Waves << Giraffe
  end

  after do
    Waves.applications.clear
  end

  it "contains names of tracked pages" do
    body = get("/list").body
    body.should =~ /\bFile1\b/i
    body.should =~ /\bFile3\b/i
    body.should =~ /\bFile5\b/i
  end

  it "does not contain names of nontracked pages" do
    body = get("/list").body
    body.should.not =~ /\bFile2\b/i
    body.should.not =~ /\bFile4\b/i
    body.should.not =~ /\bFile6\b/i
  end

  it "lists pages inside subdirectories after those directories" do
    body = get("/list").body
    body.should =~ /\bsubdir\/\b.*?\bFile3\b/im
    body.should =~ /\bsubdir\/\b.*?\bsub_subdir\/\b.*?\bFile5\b/im
  end

end

describe "Wiki page list at subdirectory" do
  before do
    Waves << Giraffe
  end

  after do
    Waves.applications.clear
  end

  it "contains names of tracked pages in that subdirectory" do
    body = get("/list/subdir").body
    body.should =~ /\bFile3\b/i
    body.should =~ /\bFile5\b/i
  end

  it "does not contain names of nontracked pages" do
    body = get("/list/subdir").body
    body.should.not =~ /\bFile4\b/i
  end

  it "does not contain pages in higher directories" do
    body = get("/list/subdir").body
    body.should.not =~ /\bFile1\b/i
  end

  it "lists pages inside further subdirectories after those directories" do
    body = get("/list/subdir").body
    body.should =~ /\bsub_subdir\/\b.*?\bFile5\b/im
  end

end
