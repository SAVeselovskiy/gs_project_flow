module Fastlane
  module Actions
    class GsErrorAction < Action
      def self.run(params)
        begin
          version_name, v = Helper::GsProjectFlowIosHelper.version_for_lane(params[:lane], Helper::GsProjectFlowIosHelper::BuildState::FAILURE)
          # ENV["PROJECT_NAME"] - переменка окружения, используемая в iOS, как читаемое название проекта + ключ в json файлике версий
          message = ENV["PROJECT_NAME"] + " " + version_name + " build has failed. Reason:\n " + params[:exception].message

          UI.important(message)
          Helper::GsProjectFlowIosHelper.send_report(message,Helper::GsProjectFlowIosHelper::BuildState::FAILURE, params[:lane])
        rescue => ex
          message = "Build has failed on error lane. Reason main lane failed:\n " + params[:exception].message + " \n Reason error lane failed:\n" + ex.message
          Helper::GsProjectFlowIosHelper.send_report(message,Helper::GsProjectFlowIosHelper::BuildState::FAILURE, params[:lane])
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
                                        type: Symbol),
            FastlaneCore::ConfigItem.new(key: :exception,
                                         description: "A description of your option",
                                         optional: false,
                                         is_string: false)
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
