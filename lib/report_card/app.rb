module ReportCard
  class App < Sinatra::Base
    set     :root, File.expand_path("../../..", __FILE__)
    enable  :methodoverride, :static, :sessions
    helpers ReportCard::Helpers

    before do
      # The browser only sends http auth data for requests that are explicitly
      # required to do so. This way we get the real values of +#logged_in?+ and
      # +#current_user+
      login_required if session[:user]
    end

    not_found do
      status 404
      show :not_found, :title => "lost, are we?"
    end

    get '/?' do
      @projects = Integrity::Project.all
      show :index, :title => "projects"
    end

    get "/login" do
      login_required

      session[:user] = current_user
      redirect root_url.to_s
    end

    get "/:project/?" do
      project = Integrity::Project.first(:name => params[:project])

      if project.nil?
        status 404
        return show :not_found, :title => "project not found"
      end

      # Check output directory
      priv = project.public ? "" : "private"
      dir  = File.join(options.public, priv, project.name, "output")

      if File.directory?(dir)
        if File.file?(File.join(dir, "index.html"))
          return redirect project_output_path(project), 301
        else
          return show :grading, :title => "grading in process"
        end
      end

      show :not_graded, :title => "not graded"
    end

    post "/:project/grade" do
      login_required
      project = Integrity::Project.first(:name => params[:project])

      unless project
        status 404
        return show :not_found, :title => "project not found"
      end

      @grader = Grader.new(project, ReportCard.config)
      @grader.grade
    end
  end
end