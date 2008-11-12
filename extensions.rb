def require_gem_with_feedback(gem)
  begin
    require gem
  rescue LoadError
    puts "You need to 'sudo gem install #{gem}' before we can proceed"
  end
end

class String
  def wiki_linked
    # matches [Page] or [[Page]] or even [[a page]]
    self.gsub!(/\[{1,2}(\w*?)\]{1,2}/, '<a href="/\1">\1</a>')
    # matches WikiWords, e.g. LaLa, FooBar but not Foo, FBar or FB
    self.gsub!(/\b[^\[]((?:[A-Z]\w+){2,})/, '<a href="/\1">\1</a>')
    self
  end
end

class Time
  def for_time_ago_in_words
    "#{(self.to_i * 1000)}"
  end
end
