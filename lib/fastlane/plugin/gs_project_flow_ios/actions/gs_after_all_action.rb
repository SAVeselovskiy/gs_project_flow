module Fastlane
  module Actions
    class GsAfterAllAction < Action
      def self.run(params)
        version_name, v = Helper::GsProjectFlowIosHelper.version_for_lane(params[:lane],Helper::GsProjectFlowIosHelper::BuildState::SUCCESS)
        message = ENV["PROJECT_NAME"] + " " + version_name + "<pre> build successful.</pre>"
        Helper::GsProjectFlowIosHelper.send_report(message,Helper::GsProjectFlowIosHelper::BuildState::SUCCESS,params[:lane])
        cmd = ""
        options = {}
        if params[:lane] == :beta
          cmd = "beta"
          options = {cmd:cmd,
                     displayVersionName:version_name,
                     request: "cmd",
                     alias: ENV["ALIAS"]
          }
        elsif params[:lane] == :rc
          # cmd = "mv2rc"
          # options = {
          #     cmd:cmd,
          #     displayVersionName:version_name,
          #     buildNumber:v.build,
          #     request: "cmd",
          #     alias: ENV["ALIAS"]
          # }
        elsif params[:lane] == :release
          cmd = "rc2release"
          options = {cmd:cmd,
                     displayVersionName:version_name,
                     buildNumber:v.build,
                     request: "cmd",
                     alias: ENV["ALIAS"]
          }

        end
        if cmd != ""
          Actions::GsExecuteCommandAction.run(FastlaneCore::Configuration.create(GsExecuteCommandAction.available_options,options))
        end
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
            FastlaneCore::ConfigItem.new(key: :lane,
                                         description: "A description of your option",
                                         optional: false,
                                         type: Symbol)
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
