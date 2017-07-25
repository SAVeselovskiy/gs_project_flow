module Fastlane
  module Actions
    class GsBeforeAllAction < Action
      def self.run(params)
        require 'cocoapods'
# if custom meta directory specified in .env file rename it to 'metadata'. It will delete default 'metadata' dir
        unless ENV["ITC_META_DIR"].nil?
          system ("rm -rf metadata")
          system ("mv " + ENV["ITC_META_DIR"] + " metadata")
          UI.important("Use custom ITC metadata.")
        end

        unless ENV["ITC_SCREENSHOTS_DIR"].nil?
          system ("rm -rf screenshots")
          system ("mv " + ENV["ITC_SCREENSHOTS_DIR"]+ " screenshots")
          UI.important("Use custom ITC screenshots.")
        end

        # cocoapods(use_bundle_exec: false)
        # CocoapodsAction.run(use_bundle_exec: false) #, clean: true, integrate: true, ansi: true)
        action = 'cocoapods'
        parameters = {:use_bundle_exec => false}

        Fastlane::GsProjectFlowIosHelper.new.execute_action(action,parameters)

        # class_ref = Actions.action_class_ref(action)
        # UI.message("class ref = " + Dir.pwd)
        # r = Runner.new
        #
        # r.execute_action(action, class_ref, [parameters], custom_dir: '.')
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
