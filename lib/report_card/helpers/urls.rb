module ReportCard
  module Helpers
    module Urls
      def root_url
        @root_url ||= Addressable::URI.parse(url_for("/", :full))
      end

      def root_path
        @root_path ||= Addressable::URI.parse(url_for("/", :path_only))
      end

      def project_url(project)
        Addressable::URI.parse(url_for(project.name, :full))
      end

      def project_path(project)
        Addressable::URI.parse(url_for(project.name, :path_only))
      end

      def project_output_path(project)
        priv = project.public ? "" : "private/"
        Addressable::URI.parse(url_for("#{priv}#{project.name}/output/index.html"))
      end

      def url(*path)
        root_url.join(path.join("/"))
      end

      def path(*path)
        root_path.join(path.join("/"))
      end

      # Copyright (MIT) Eric Kidd -- http://github.com/emk/sinatra-url-for
      #
      # Construct a link to +url_fragment+, which should be given relative to
      # the base of this Sinatra app.  The mode should be either
      # <code>:path_only</code>, which will generate an absolute path within
      # the current domain (the default), or <code>:full</code>, which will
      # include the site name and port number.  (The latter is typically
      # necessary for links in RSS feeds.)  Example usage:
      #
      #   url_for "/"            # Returns "/myapp/"
      #   url_for "/foo"         # Returns "/myapp/foo"
      #   url_for "/foo", :full  # Returns "http://example.com/myapp/foo"
      #--
      # See README.rdoc for a list of some of the people who helped me clean
      # up earlier versions of this code.
      def url_for url_fragment, mode=:path_only
        case mode
        when :path_only
          base = request.script_name
        when :full
          scheme = request.scheme
          if (scheme == 'http' && request.port == 80 ||
              scheme == 'https' && request.port == 443)
            port = ""
          else
            port = ":#{request.port}"
          end
          base = "#{scheme}://#{request.host}#{port}#{request.script_name}"
        else
          raise TypeError, "Unknown url_for mode #{mode}"
        end
        "#{base}#{url_fragment}"
      end
    end
  end
end