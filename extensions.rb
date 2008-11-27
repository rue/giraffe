
class String
  def wiki_linked
    self.gsub!(/(?!<nowiki>)(?>\b((?:[A-Z]\w+){2,}))(?!<\/nowiki>)/) { |m| "<a href=\"/#{m}\">#{m}</a>" }
    self.gsub!(/<\/?nowiki>/,'')
    # matches [Page] or [[Page]] or even [[a page]]
    self.gsub!(/\[{1,2}(\w*?)\]{1,2}/, '<a href="/\1">\1</a>')
    # matches WikiWords, e.g. LaLa, FooBar but not Foo, FBar or FB
    self.gsub!(%r#((?:[A-Z][a-z_]+){2,})(?=(?:(?!</a>).)*(?:<a|$))#, '<a href="/\1">\1</a>')
    self
  end
end

class Time
  def for_time_ago_in_words
    "#{(self.to_i * 1000)}"
  end
end

module HttpAuthentication
  module Basic

    def authenticate(&login_procedure)
      authenticate_or_request_with_http_basic "git-wiki", &login_procedure
    end

    def authenticate_or_request_with_http_basic(realm = "Application", &login_procedure)
      authenticate_with_http_basic(&login_procedure) || request_http_basic_authentication(realm)
    end

    def authenticate_with_http_basic(&login_procedure)
      authenticate(&login_procedure)
    end

    def request_http_basic_authentication(realm = "Application")
      authentication_request(realm)
    end

    private

      def authenticate(&login_procedure)
        if authorization
          login_procedure.call(*user_name_and_password)
        end
      end

      def user_name_and_password
        decode_credentials.split(/:/, 2)
      end

      def authorization
        request.env['HTTP_AUTHORIZATION']   ||
        request.env['X-HTTP_AUTHORIZATION'] ||
        request.env['X_HTTP_AUTHORIZATION'] ||
        request.env['REDIRECT_X_HTTP_AUTHORIZATION']
      end

      # Base64
      def decode_credentials
        (authorization.split.last || '').unpack("m").first
      end

      def authentication_request(realm)
        status(401)
        header("WWW-Authenticate" => %(Basic realm="#{realm.gsub(/"/, "")}"))
        throw :halt, "HTTP Basic: Access denied.\n"
      end

  end
end

module Sinatra
  class EventContext
    include HttpAuthentication::Basic
  end
end

# Work around stupid directory handling
def (GitWiki.repo).working()
  unless GitWiki.relative.empty?
    self.gtree("HEAD").trees[GitWiki.relative]
  else
    self.gtree "HEAD"
  end
end

