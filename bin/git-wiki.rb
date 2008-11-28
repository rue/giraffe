#!/usr/bin/env ruby

libdir = File.join File.dirname(__FILE__), "..", "lib"
$LOAD_PATH.unshift libdir if File.directory? libdir


require "git-wiki/environment"

require "sinatra/lib/sinatra"

require "git-wiki/extensions"
require "git-wiki/page"

require "rubygems"
  require "rdiscount"
  require "rubypants"


before do
  authenticate {|user, pass| GitWiki.users[user] == pass } if GitWiki.users
end

# Resource mapping


# Default
get('/') { redirect GitWiki.home }


# Pages
get '/:page' do
  @page = Page.new(params[:page])
  @page.tracked? ? show(:show, @page.name) : redirect('/e/' + @page.name)
end

# Raw page text
get('/:page/raw') { redirect "/#{params[:page]}.txt" }

get "/:page.txt" do
  headers 'Content-Type' => 'text/plain;charset=utf-8'
  @page = Page.new(params[:page])
  send_data @page.raw_body, :type => 'text/plain', :disposition => 'inline'
end

get '/:page/append' do
  @page = Page.new(params[:page])
  @page.update(@page.raw_body + "\n\n" + params[:text], params[:message])
  redirect '/' + @page.name
end

# Page editing
get '/e/:page' do
  @page = Page.new(params[:page])
  show :edit, "Editing #{@page.name}"
end

post '/e/:page' do
  @page = Page.new(params[:page])
  @page.update(params[:body], params[:message])
  redirect '/' + @page.name
end

post '/eip/:page' do
  @page = Page.new(params[:page])
  @page.update(params[:body])
  @page.body
end

get '/h/:page' do
  @page = Page.new(params[:page])
  show :history, "History of #{@page.name}"
end

get '/h/:page/:rev' do
  @page = Page.new(params[:page], params[:rev])
  show :show, "#{@page.name} (version #{params[:rev]})"
end

get '/h/:page/:rev.txt' do
  @page = Page.new(params[:page], params[:rev])
  send_data @page.raw_body, :type => 'text/plain', :disposition => 'inline'
end

get '/d/:page/:rev' do
  @page = Page.new(params[:page])
  show :delta, "Diff of #{@page.name}"
end

# application paths (/a/ namespace)

get '/a/list' do
  @pages = GitWiki.repo.working.children.sort.map {|name, data| Page.new name } rescue []
  show :list, 'Listing pages'
end

get '/a/patch/:page/:rev' do
  @page = Page.new(params[:page])
  header 'Content-Type' => 'text/x-diff'
  header 'Content-Disposition' => 'filename=patch.diff'
  @page.delta(params[:rev])
end

get '/a/tarball' do
  header 'Content-Type' => 'application/x-gzip'
  header 'Content-Disposition' => 'filename=archive.tgz'
  archive = GitWiki.repo.archive('HEAD', nil, :format => 'tgz', :prefix => 'wiki/')
  File.open(archive).read
end

get '/a/search' do
  @search = params[:search]
  @grep = GitWiki.repo.object("HEAD").grep @search, nil, :ignore_case => true
  show :search, 'Search Results'
end

# file upload attachments

get '/a/file/upload/:page' do
  @page = Page.new(params[:page])
  show :attach, 'Attach File for ' + @page.name
end

post '/a/file/upload/:page' do
  @page = Page.new(params[:page])
  @page.save_file(params[:file], params[:name])
  redirect '/e/' + @page.name
end

get '/a/file/delete/:page/:file.:ext' do
  @page = Page.new(params[:page])
  @page.delete_file(CGI::unescape(params[:file]) + '.' + params[:ext])
  redirect '/e/' + @page.name
end

get '/_attachment/:page/:file.:ext' do
  @page = Page.new(params[:page])
  send_file(File.join(@page.attach_dir, CGI::unescape(params[:file]) + '.' + params[:ext]))
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

