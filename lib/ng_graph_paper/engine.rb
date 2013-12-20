module NgGraphPaper
  class Engine < ::Rails::Engine
    initializer "ng_graph_paper.assets.precompile" do |app|
      app.config.assets.precompile += %w(ng_graph_paper.js)
    end
  end
end