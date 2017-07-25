module Fastlane
  module Actions
    class GsExecuteBetaLaneAction < Action
      def self.run(params)
        require 'fastlane/plugin/gs_versioning'
        require 'fastlane/plugin/versioning'
        # match(type: "appstore") # more information: https://codesigning.guide
        # Increment the build number (not the version number)
        v = GsIncrementBetaVersionAction.run(path:Fastlane::Helper::GsProjectFlowIosHelper.get_versions_path)
        version_name = v.major.to_s + "." + v.minor.to_s + "." + v.build.to_s
        IncrementBuildNumberInPlist.run(xcodeproj:ENV["xcodeproj"],
          target:ENV["target"],
          build_number: v.build.to_s
        )
        IncrementVersionNumberInPlist.run(
          version_number: v.major.to_s + "." + v.minor.to_s + ".0",
          xcodeproj: ENV["xcodeproj"],
          target: ENV["target"]
        )
        #
        # generateReleaseNotes("fileBeta", ENV["ALIAS"], version_name, "Ru")
        # generateReleaseNotes("fileBeta", ENV["ALIAS"], version_name, "En")
        #
        # ruText = FileHelper.read(Dir.pwd + "/../../../notes/" + ENV["ALIAS"] + "/" + version_name + "_Ru.txt")
        # enText = FileHelper.read(Dir.pwd + "/../../../notes/" + ENV["ALIAS"] + "/" + version_name + "_En.txt")
        #
        # require 'date'
        # current_time = DateTime.now
        # time_string = current_time.strftime "%d.%m.%Y %H-%M"
        # crashlytics_changelog = time_string + "\n" + ruText + "\n\n" + enText
        # Dir.chdir ".." do
        #   UI.message(Dir.pwd)
        #   sh "chmod 744 ./DeleteDerrivedData.sh"
        #   sh Dir.pwd+"/DeleteDerrivedData.sh"
        # end
        # gym(scheme: ENV["APP_SCHEME"],
        #   export_method:"ad-hoc") # Build your app - more options available
        # crashlytics(notes: crashlytics_changelog,
        #   groups: ENV["CRASHLYTICS_GROUPS"]
        #   )
        # #
        # # sh "your_script.sh"
        # gs_save_beta_version(path:ENV["path_to_versions"], version: v)
        # UI.success("✅ App is released to Crashlytics")
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
