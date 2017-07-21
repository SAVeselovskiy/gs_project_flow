module Fastlane
  module Helper
    class GsProjectFlowIosHelper
      # class methods that you define here become available in your action
      # as `Helper::GsProjectFlowIosHelper.your_method`
      #
      def self.get_verssions_path
        return Dir.pwd+"/../../../versions.json"
      end

      def self.show_message
        UI.message("Hello from the gs_project_flow_ios plugin helper!")
      end
    end
  end
end
