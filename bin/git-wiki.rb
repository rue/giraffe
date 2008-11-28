#!/usr/bin/env ruby

libdir = File.join File.dirname(__FILE__), "..", "lib"
$LOAD_PATH.unshift(File.dirname(__FILE__), "..")
$LOAD_PATH.unshift libdir if File.directory? libdir


require "git-wiki/environment"

require "sinatra/lib/sinatra"

require "git-wiki/extensions"
require "git-wiki/page"

require "rubygems"
  require "rdiscount"
  require "rubypants"


# Authentication.
#
before do
  authenticate {|user, pass| GitWiki.users[user] == pass } if GitWiki.users
end


  # Resource mapping


# Default page.
#
get('/') { redirect GitWiki.home }


# Pages handled at bottom due to wildcarding


# Page editor.
#
get "/e/*:page" do
  @page = Page.new(params[:splats].first + params[:page])
  show :edit, "Editing #{@page.name}"
end

# Process edit.
#
post "/e/*:page" do
  @page = Page.new(params[:splats].first + params[:page])
  @page.update(params[:body], params[:message])

  redirect '/' + @page.name
end

# In-place edit.
#
post '/eip/*/:page' do
  @page = Page.new(params[:splats].first + params[:page])

  @page.update params[:body]
  @page.body
end

# Show page history.
#
get '/h/*:page' do
  @page = Page.new(params[:splats].first + params[:page])
  show :page_history, "History of #{@page.name}"
end

# Show page history for given revision.
#
get '/h/*:page/:rev' do
  @page = Page.new(params[:splats].first + params[:page])
  show :show, "#{@page.name} (version #{params[:rev]})"
end

# Raw history for given revision.
#
get '/h/*:page/:rev.txt' do
  @page = Page.new(params[:splats].first + params[:page])
  send_data @page.raw_body, :type => 'text/plain', :disposition => 'inline'
end

# Show diff of page revisions
#
get '/d/*:page/:rev' do
  @page = Page.new(params[:splats].first + params[:page])
  show :delta, "Diff of #{@page.name}"
end

# Wiki history
#
get '/a/history' do
  @history = GitWiki.repo.log.path GitWiki.relative
  show :history, "Wiki History"
end

# Page listing
#
get '/a/list' do
  #
  # We keep the path prefix by hand and ensure that no extra slashes get in
  # This produces a structure like:
  #
  # [#<Page "foo">, ["subdir", [#<Page "subdir/bar">, ...]], #<Page "baz">, ...]
  #
  recursor =  lambda {|tree, path, continuation|
                tree.children.sort.map {|name, obj|
                  if obj.kind_of? Git::Object::Tree
                    a = [File.join(path + [name]), continuation.call(obj, (path + [name]), continuation)]
                    puts "Dir > #{a.first} : #{a.last.inspect}"
                    a
                  elsif name =~ /#{Regexp.escape GitWiki.extension}\Z/
                    pg = Page.new File.join(path + [name])
                    puts "Pg  > #{pg.name}"
                    pg
                  end
                }.compact
              }

  @pages = recursor.call GitWiki.repo.working, [], recursor
  show :list, 'Listing Pages'
end

# Search
#
get '/a/search' do
  @search = params[:search]
  @grep = GitWiki.repo.object("HEAD").grep @search, nil, :ignore_case => true
  show :search, 'Search Results'
end

# Generate patchfile for diff
#
get "/a/patch/*:page/:rev" do
  header "Content-Type"         => "text/x-diff"
  header "Content-Disposition"  => "filename=patch.diff"

  Page.new(params[:splats].first + params[:page]).delta params[:rev]
end

# Generate a .tgz of wiki pages for user
#
get "/a/tarball" do
  header "Content-Type"         => "application/x-gzip"
  header "Content-Disposition"  => "filename=archive.tgz"

  File.read GitWiki.repo.archive("HEAD", nil, :format => "tgz", :prefix => "wiki/")
end


# file upload attachments

get '/a/file/upload/*:page' do
  @page = Page.new(params[:splats].first + params[:page])
  show :attach, 'Attach File for ' + @page.name
end

post '/a/file/upload/*:page' do
  @page = Page.new(params[:splats].first + params[:page])
  @page.save_file(params[:file], params[:name])

  redirect '/e/' + @page.name
end

get '/a/file/delete/*:page/:file.:ext' do
  @page = Page.new(params[:splats].first + params[:page])
  @page.delete_file(CGI::unescape(params[:file]) + '.' + params[:ext])

  redirect '/e/' + @page.name
end

get '/_attachment/*:page/:file.:ext' do
  @page = Page.new(params[:splats].first + params[:page])
  send_file(File.join(@page.attach_dir, CGI::unescape(params[:file]) + '.' + params[:ext]))
end

  # These come last since they could match anything

# Show page in or send to create.
#
get "/*:page" do
  @page = Page.new(params[:splats].first + params[:page])
  if @page.tracked? then show :show, @page.name else redirect "/e/" + @page.name end
end

# Give user the raw source text of the page.
#
get "/*:page/raw" do
  headers 'Content-Type' => 'text/plain;charset=utf-8'

  @page = Page.new(params[:splats].first + params[:page])
  send_data @page.raw_body, :type => 'text/plain', :disposition => 'inline'
end


# support methods

def page_url(page)
  "#{request.env["rack.url_scheme"]}://#{request.env["HTTP_HOST"]}/#{page}"
end


private

  def show(template, title)
    @title = title
    erb(template)
  end

