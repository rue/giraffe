
require "giraffe/git"
require "giraffe/environment"
require "giraffe/hacks"
require "giraffe/page"
require "rubygems"
require "rdiscount"
require "rubypants"

# # Authentication.
#
before do
  authenticate Giraffe.authenticator if Giraffe.authenticator
end


  # Resource mapping


# Default page.
#
get('/') { redirect Giraffe.home }


# Pages handled at bottom due to wildcarding


# Page editor.
#
get "/e/(.+)" do
  @page = Page.from_uri *File.split(params[:matches][1])
  show :edit, "Editing #{@page.pretty_name.last}"
end

# Process edit.
#
post "/e/(.+)" do
  @page = Page.from_uri *File.split(params[:matches][1])
  @page.make! unless @page.exists?

  @page.update(params[:body], params[:message])

  redirect '/' + @page.uri
end

# Show page as it was in given revision.
#
get '/h/(.+)/(.+)' do
  Giraffe.wiki = Giraffe.wiki.at params[:matches][2]
  @page = Page.from_uri *File.split(params[:matches][1])

  show :show, "#{@page.pretty_name.last} (in #{params[:matches][2]})"
end

# Show page history.
#
get '/h/(.+)' do
  @page = Page.from_uri *File.split(params[:matches][1])
  @commits = @page.object.commits 30

  show :page_history, "History of #{@page.pretty_name.last}"
end

# Show diff of page revision to HEAD
#
get '/d/(.+)/(.+)' do
  path, name = *File.split(params[:matches][1])
  commit = params[:matches][2]

  @page = Page.from_uri path, name
  @diff = @page.object.diff commit

  @commit = commit[0..7] + "..."

  show :delta, "Diff of #{@page.pretty_name.last} against #{commit}"
end

# Wiki history
#
get '/a/history' do
  @history = Giraffe.wiki.commits 30
  show :history, "Wiki History"
end

# Toplevel page listing
#
get "/a/list" do
  @objects = Giraffe.wiki.objects
  show :list, "All pages"
end

# Subdirectory page listing
#
get "/a/list/(.+)" do
  @subdir = params[:matches][1]
  @objects = Giraffe.wiki.object_for(@subdir).objects

  show :list, "Pages Under #{@subdir}/"
end

# Raw, unrendered text from the file.
#
get "/a/raw/(.+)" do
  path, name = File.split(params[:matches][1])
  @page = Page.from_uri path, name

  headers 'Content-Type' => 'text/plain;charset=utf-8'
  send_data @page.raw_body, :type => 'text/plain', :disposition => 'inline'
end

# Search
#
get '/a/search' do
  @search = params[:search]
  @matches = Giraffe.wiki.grep @search

  show :search, 'Search Results'
end

# Generate patchfile for diff
#
get "/a/patch/(.+)/(.+)" do
  path, name = File.split(params[:matches][1])
  commit = params[:matches][2]

  diff = Page.from_uri(path, name).object.diff commit

  header "Content-Type"         => "text/x-diff"
  header "Content-Disposition"  => "filename=patch.diff"

  send_data diff, :type => "text/x-diff", :disposition => "inline"
end

  # These come last since they could match anything


# Resource pages have an extension.
#
get "/(.+\\..+)" do
  path, name = File.split(params[:matches][1])
  info = Giraffe.resource_filter.call(path + name)

  if info
    @resource = Resource.from_uri path, name, info
    send_file @resource.object.full_path, :type => @resource.mime, :disposition => "inline"
  end
end

# Regular pages do not have an extension.
#
get "/(.+)" do
  @page = Page.from_uri *File.split(params[:matches][1])

  redirect "/a/list/#{@page.uri}" if @page.directory?

  if @page.exists? then show :show, @page.name else redirect "/e/" + @page.uri end
end

# Slightly simplify generating the output.
#
def show(template, title)
  @title = title
  erb template
end

private :show
