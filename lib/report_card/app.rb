module ReportCard
  class App < Sinatra::Base
    set     :root, File.expand_path("../../..", __FILE__)
    enable  :methodoverride, :static, :sessions
    helpers ReportCard::Helpers

    not_found do
      status 404
      show :not_found, :title => "lost, are we?"
    end

    get '/?' do
      @projects = Integrity::Project.all
      show :index, :title => "projects"
    end

    get '/:project/output/?' do
      # Check directory (eww)
      # and index?
      if File.directory?(File.join(File.expand_path("../../../public/#{params[:project]}/output", __FILE__)))
        return redirect "/#{params[:project]}/output/", 301
      end

      # Check project
      if Integrity::Project.first(:name => params[:project])
        return show :not_graded, :title => "not graded"
      end

      status 404
      show :not_found, :title => "project not found"
    end
  end
end