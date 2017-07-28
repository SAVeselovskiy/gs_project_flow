module Fastlane
  module Actions
    class GsExecuteExternalRunnerLaneAction < Action
      def self.run(params)
        require 'fastlane/plugin/gs_deliver'
        Actions::GsStartExternalTestingAction.run(FastlaneCore::Configuration.create(GsStartExternalTestingAction.available_options,{app_identifier:ENV["BUNDLE_ID"]}))
      end

      def self.description
        "Plugin contains project flow code for code sharing between projects"
      end

      def self.authors
        ["Сергей Веселовский"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Plugin contains project flow code for code sharing between GradoService projects"
      end

      def self.available_options
        [
            # FastlaneCore::ConfigItem.new(key: :your_option,
            #                         env_name: "GS_PROJECT_FLOW_IOS_YOUR_OPTION",
            #                      description: "A description of your option",
            #                         optional: false,
            #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end