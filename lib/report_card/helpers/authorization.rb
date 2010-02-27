module ReportCard
  module Helpers
    module Authorization
      include Sinatra::Authorization

      def authorization_realm
        "ReportCard"
      end

      def authorized?
        !!request.env["REMOTE_USER"]
      end

      def authorize(user, password)
        ReportCard.config["user"] == user && ReportCard.config["pass"] == password
      end

      def unauthorized!(realm=authorization_realm)
        response["WWW-Authenticate"] = %(Basic realm="#{realm}")
        throw :halt, [401, show(:unauthorized, :title => "incorrect credentials")]
      end
    end
  end
end