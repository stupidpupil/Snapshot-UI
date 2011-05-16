module SPSnapshot
  class UIAppFactory
    attr_reader :helper

    def initialize(helper)
      @helper = helper
    end
    
    def aboutApp
      return proc do |env|
        return [200,  {"Content-Type" => "application/json"}, [{:name => "#{Socket.gethostname} - #{helper.startingPath}" , :startingPath => helper.startingPath, :startingSnapshot => helper.snapshotsForPath(helper.startingPath)[0].snapId}.to_json, ]]
      end
    end
  end
end