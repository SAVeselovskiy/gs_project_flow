module Fastlane
  module Helper
    class GsProjectFlowIosHelper
      # class methods that you define here become available in your action
      # as `Helper::GsProjectFlowIosHelper.your_method`
      #
      def self.get_verssions_path
        return Dir.pwd+"/../../../versions.json"
      end

      def execute_action(action, parameters, class_ref: nil, custom_dir: '.', from_action: false)
        if class_ref.nil?
          local_class_ref = Actions.action_class_ref(action)
        else
          local_class_ref = class_ref
        end
        r = Runner.new
        r.execute_action(action, local_class_ref, [parameters], custom_dir: custom_dir, from_action: from_action)
      end

      def self.show_message
        UI.message("Hello from the gs_project_flow_ios plugin helper!")
      end
    end
  end
end
