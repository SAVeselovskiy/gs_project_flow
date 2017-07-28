module Fastlane
  module Actions
    class GsExecuteBetaLaneAction < Action
      def self.run(params)
        require 'fastlane/plugin/gs_versioning'
        require 'fastlane/plugin/versioning'
        # match(type: "appstore") # more information: https://codesigning.guide
        # Increment the build number (not the version number)
        UI.message("alias = " + params[:alias])
        fastlaneHelper = Fastlane::Helper::GsProjectFlowIosHelper.new
        # v = Helper::GsProjectFlowIosHelper.new.execute_action('gs_increment_beta_version', {path:Helper::GsProjectFlowIosHelper.get_versions_path})
        arg = FastlaneCore::Configuration.create(GsIncrementBetaVersionAction.available_options, {path:Helper::GsProjectFlowIosHelper.get_versions_path})
        v = GsIncrementBetaVersionAction.run(arg)
        version_name = v.major.to_s + "." + v.minor.to_s + "." + v.build.to_s
        UI.message('version' + version_name)
        # Helper::GsProjectFlowIosHelper.new.execute_action('increment_build_number_in_plist', {xcodeproj:ENV["xcodeproj"], target:ENV["target"], build_number: v.build.to_s})
        Actions::IncrementBuildNumberInPlistAction.run(FastlaneCore::Configuration.create(Actions::IncrementBuildNumberInPlistAction.available_options, {xcodeproj:ENV["xcodeproj"], target:ENV["target"], build_number: v.build.to_s}))

        # Helper::GsProjectFlowIosHelper.new.execute_action('increment_build_version_in_plist', {version_number: v.major.to_s + "." + v.minor.to_s + ".0",
        #                                                                                                                                                                                                      xcodeproj: ENV["xcodeproj"],
        #                                                                                                                                                                                                      target: ENV["target"]})
        IncrementVersionNumberInPlistAction.run(FastlaneCore::Configuration.create(IncrementVersionNumberInPlistAction.available_options, {version_number: v.major.to_s + "." + v.minor.to_s + ".0", xcodeproj: ENV["xcodeproj"], target: ENV["target"]}))

        ruText = fastlaneHelper.generateReleaseNotes("fileBeta", params[:alias], version_name, "Ru")
        enText = fastlaneHelper.generateReleaseNotes("fileBeta", params[:alias], version_name, "En")

        # ruText = FileHelper.read(Dir.pwd + "/../../../notes/" + ENV["ALIAS"] + "/" + version_name + "_Ru.txt")
        # enText = FileHelper.read(Dir.pwd + "/../../../notes/" + ENV["ALIAS"] + "/" + version_name + "_En.txt")

        require 'date'
        current_time = DateTime.now
        time_string = current_time.strftime "%d.%m.%Y %H-%M"
        crashlytics_changelog = time_string + "\n" + ruText + "\n\n" + enText
        Dir.chdir ".." do
          UI.message(Dir.pwd)
          sh "chmod 744 ./DeleteDerrivedData.sh"
          sh Dir.pwd+"/DeleteDerrivedData.sh"
        end

        Actions::GymAction.run(FastlaneCore::Configuration.create(GymAction.available_options,{scheme: ENV["APP_SCHEME"],
            export_method:"ad-hoc"})) # Build your app - more options available

        Actions::CrashlyticsAction.run(FastlaneCore::Configuration.create(GymAction.available_options,{notes: crashlytics_changelog,
                                                                                                       groups: ENV["CRASHLYTICS_GROUPS"]}))


        Actions::GsSaveBetaVersionAction.run(FastlaneCore::Configuration.create(GsSaveBetaVersionAction.available_options,{path:Helper::GsProjectFlowIosHelper.get_versions_path}))
        UI.success("✅ App is released to Crashlytics")
        # # You can also use other beta testing services here (run fastlane actions)
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
            FastlaneCore::ConfigItem.new(key: :alias,
                                    env_name: "ALIAS",
                                 description: "project system alias",
                                    optional: false,
                                        type: String)
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
