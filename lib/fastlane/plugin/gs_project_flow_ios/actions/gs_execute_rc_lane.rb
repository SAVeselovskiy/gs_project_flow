module Fastlane
  module Actions
    class GsExecuteRcLaneAction < Action
      def self.run(params)
        require 'fastlane/plugin/gs_versioning'
        require 'fastlane/plugin/versioning'

        fastlaneHelper = Fastlane::Helper::GsProjectFlowIosHelper.new
        arg = FastlaneCore::Configuration.create(GsIncrementRcVersionAction.available_options, {path:Helper::GsProjectFlowIosHelper.get_versions_path})
        v = GsIncrementRcVersionAction.run(arg)
        version_name = v.major.to_s + "." + v.minor.to_s + "." + v.build.to_s
        UI.message('version' + version_name)

        Actions::SetInfoPlistValueAction.run(FastlaneCore::Configuration.create(SetInfoPlistValueAction.available_options,{path: plist_path, key: "ITSAppUsesNonExemptEncryption", value: "false"}))

        Actions::IncrementBuildNumberInPlistAction.run(FastlaneCore::Configuration.create(Actions::IncrementBuildNumberInPlistAction.available_options,
                                                                                          {xcodeproj:ENV["xcodeproj"], target:ENV["target"], build_number: v.build.to_s}))

        Actions::IncrementVersionNumberInPlistAction.run(FastlaneCore::Configuration.create(Actions::IncrementVersionNumberInPlistAction.available_options,
                                                                                   {version_number: v.major.to_s + "." + v.minor.to_s + ".0", xcodeproj: ENV["xcodeproj"], target: ENV["target"]}))

        ruText = fastlaneHelper.generateReleaseNotes("fileClosed", params[:alias], version_name, "Ru")
        enText = fastlaneHelper.generateReleaseNotes("fileClosed", params[:alias], version_name, "En")

        # ruText = FileHelper.read(Dir.pwd + "/../../../notes/" + ENV["ALIAS"] + "/" + version_name + "_Ru.txt")
        # enText = FileHelper.read(Dir.pwd + "/../../../notes/" + ENV["ALIAS"] + "/" + version_name + "_En.txt")
        testflight_changelog = ruText + "\n\n" + enText
        UI.message("changelog = " + testflight_changelog)

        appDescription = Helper::FileHelper.read (Dir.pwd + "/metadata/ru/description.txt")



        options = {changelog: testflight_changelog,
                   beta_app_description:appDescription,
                   distribute_external: false,
                   beta_app_feedback_email: "cimobdaemon@gmail.com"}

        Dir.chdir ".." do
          sh "chmod 744 ./DeleteDerrivedData.sh"
          sh Dir.pwd+"/DeleteDerrivedData.sh"
        end
        Actions::GymAction.run(FastlaneCore::Configuration.create(GymAction.available_options,{scheme: ENV["APP_SCHEME"],
                                                                                               export_method:"app-store"})) # Build your app - more options available




        s = Actions::GsGetAppStatusAction.run(FastlaneCore::Configuration.create(GsGetAppStatusAction.available_options,{app_identifier:ENV["BUNDLE_ID"]}))
        if s == "Pending Developer Release"
          Actions::GsRejectLatestVersionAction.run(FastlaneCore::Configuration.create(GsRejectLatestVersionAction.available_options,{app_identifier:ENV["BUNDLE_ID"]}))
        end

        Actions::PilotAction.run(FastlaneCore::Configuration.create(GsRejectLatestVersionAction.available_options,options))
        UI.success("App is released to internal testing")

        Actions::GsSaveRcVersionAction.run(FastlaneCore::Configuration.create(GsSaveRcVersionAction.available_options,{path:Helper::GsProjectFlowIosHelper.get_versions_path}))

        Actions::GsExecuteRcLaneAction.moveToReview(version_name)
        UI.success("✅ App status is changed to Waiting For Review")
        options[:distribute_external] = true
        options[:review_contact_info] = {
            review_first_name: "MyTestAccount",
            review_last_name: "MyTestAccount",
            review_phone_number: "88432000555",
            review_contact_email: "cimobdaemon@gmail.com",
        }
        begin
          Actions::GsMoveRcToBetaReviewAction.run(FastlaneCore::Configuration.create(GsMoveRcToBetaReviewAction.available_options,
                                                                                     options))
          UI.success("App is moved to beta review for external testing")
        rescue Exception => e
          UI.important(e.message)
        end
      end


      def self.moveToReview(version)
        s = Actions::GsGetAppStatusAction.run(FastlaneCore::Configuration.create(GsGetAppStatusAction.available_options,{app_identifier:ENV["BUNDLE_ID"]}))
        arg = FastlaneCore::Configuration.create(GsIncrementReleaseVersionAction.available_options, {path:Helper::GsProjectFlowIosHelper.get_versions_path})
        v = GsIncrementReleaseVersionAction.run(arg)
        # match(type: "appstore")
        # snapshot
        version_name = v.major.to_s + "." + v.minor.to_s

        # generateReleaseNotes("fileClosed", ENV["ALIAS"], version_name, "Ru")
        # generateReleaseNotes("fileClosed", ENV["ALIAS"], version_name, "En")

        ruText = Helper::FileHelper.read(Dir.pwd + "/../../../notes/" + ENV["ALIAS"] + "/" + version_name + "_Ru.txt")
        enText = Helper::FileHelper.read(Dir.pwd + "/../../../notes/" + ENV["ALIAS"] + "/" + version_name + "_En.txt")
        Helper::FileHelper.write(Dir.pwd+'/metadata/ru/release_notes.txt', ruText)
        Helper::FileHelper.write(Dir.pwd+'/metadata/en-US/release_notes.txt', enText)
        # gym(scheme: ENV["APP_SCHEME"]) # Build your app - more options available
        if s == "Waiting For Review" || s == "Pending Developer Release"
          Actions::GsRejectLatestVersionAction.run(FastlaneCore::Configuration.create(GsRejectLatestVersionAction.available_options,{app_identifier:ENV["BUNDLE_ID"]}))
        end
        Actions::DeliverAction.run(FastlaneCore::Configuration.create(DeliverAction.available_options,{force:true,
                                                                                                       submit_for_review: true,
                                                                                                       app_version: version,
                                                                                                       skip_binary_upload:true,
                                                                                                       automatic_release:false,
                                                                                                       submission_information: {
                                                                                                           add_id_info_limits_tracking: false,
                                                                                                           add_id_info_serves_ads: false,
                                                                                                           add_id_info_tracks_action: false,
                                                                                                           add_id_info_tracks_install: false,
                                                                                                           add_id_info_uses_idfa: false,
                                                                                                           content_rights_has_rights: true,
                                                                                                           content_rights_contains_third_party_content: false,
                                                                                                           export_compliance_platform: 'ios',
                                                                                                           export_compliance_compliance_required: false,
                                                                                                           export_compliance_encryption_updated: false,
                                                                                                           export_compliance_app_type: nil,
                                                                                                           export_compliance_uses_encryption: false,
                                                                                                           export_compliance_is_exempt: false,
                                                                                                           export_compliance_contains_third_party_cryptography: false,
                                                                                                           export_compliance_contains_proprietary_cryptography: false,
                                                                                                           export_compliance_available_on_french_store: false
                                                                                                       }}))
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