module Fastlane
  module Actions
    class GsExecuteRcLaneAction < Action
      def self.run(params)
        require 'fastlane/plugin/gs_versioning'
        require 'fastlane/plugin/versioning'
        ENV['RC_DID_FAILED'] = 'true'

        fastlaneHelper = Fastlane::Helper::GsProjectFlowIosHelper.new
        arg = FastlaneCore::Configuration.create(GsIncrementRcVersionAction.available_options, {path: Helper::GsProjectFlowIosHelper.get_versions_path})
        v = GsIncrementRcVersionAction.run(arg)
        version_name = v.major.to_s + "." + v.minor.to_s + "." + v.build.to_s
        UI.message('version' + version_name)

        plist_path = Actions::GetInfoPlistPathAction.run(FastlaneCore::Configuration.create(GetInfoPlistPathAction.available_options, {xcodeproj: ENV["xcodeproj"],
                                                                                                                                       target: ENV["target"]}))
        Actions::SetInfoPlistValueAction.run(FastlaneCore::Configuration.create(SetInfoPlistValueAction.available_options, {path: plist_path, key: "ITSAppUsesNonExemptEncryption", value: "false"}))

        Actions::IncrementBuildNumberInPlistAction.run(FastlaneCore::Configuration.create(Actions::IncrementBuildNumberInPlistAction.available_options,
                                                                                          {xcodeproj: ENV["xcodeproj"], target: ENV["target"], build_number: v.build.to_s}))

        Actions::IncrementVersionNumberInPlistAction.run(FastlaneCore::Configuration.create(Actions::IncrementVersionNumberInPlistAction.available_options,
                                                                                            {version_number: v.major.to_s + "." + v.minor.to_s, xcodeproj: ENV["xcodeproj"], target: ENV["target"]}))

        ruText = fastlaneHelper.generateReleaseNotes("fileClosed", params[:alias], v.major.to_s + "." + v.minor.to_s, "Ru")
        enText = fastlaneHelper.generateReleaseNotes("fileClosed", params[:alias], v.major.to_s + "." + v.minor.to_s, "En")

        # ruText = FileHelper.read(Dir.pwd + "/../../../notes/" + ENV["ALIAS"] + "/" + version_name + "_Ru.txt")
        # enText = FileHelper.read(Dir.pwd + "/../../../notes/" + ENV["ALIAS"] + "/" + version_name + "_En.txt")
        testflight_changelog = ruText + "\n\n" + enText
        UI.message("changelog = " + testflight_changelog)

        appDescription = Helper::FileHelper.read (Dir.pwd + "/fastlane/metadata/ru/description.txt")


        options = {changelog: testflight_changelog,
                   beta_app_description: appDescription,
                   distribute_external: false,
                   beta_app_feedback_email: "cimobdaemon@gmail.com"}

        # Dir.chdir ".." do
        sh "chmod 744 ./DeleteDerrivedData.sh"
        sh Dir.pwd+"/DeleteDerrivedData.sh"
        # end
        Actions::GymAction.run(FastlaneCore::Configuration.create(GymAction.available_options, {silent: true,
                                                                                                scheme: ENV["APP_SCHEME"],
                                                                                                export_method: "app-store",
                                                                                                export_options: {provisioningProfiles: {ENV["BUNDLE_ID"] => "AppStore "+ENV["ALIAS"]}},
                                                                                                clean: true,
                                                                                                suppress_xcode_output: true
        })) # Build your app - more options available
        s = Actions::GsGetAppStatusAction.run(FastlaneCore::Configuration.create(GsGetAppStatusAction.available_options, {app_identifier: ENV["BUNDLE_ID"]}))
        if s == "Pending Developer Release"
          Actions::GsRejectLatestVersionAction.run(FastlaneCore::Configuration.create(GsRejectLatestVersionAction.available_options, {app_identifier: ENV["BUNDLE_ID"]}))
        end
        cmd = "mv2rc"
        version_for_back = v.major.to_s + "." + v.minor.to_s
        bot_options = {
            cmd:cmd,
            displayVersionName:version_for_back,
            buildNumber:v.build,
            request: "cmd",
            alias: ENV["ALIAS"]
        }
        Actions::GsExecuteCommandAction.run(FastlaneCore::Configuration.create(GsExecuteCommandAction.available_options,bot_options))
        Actions::PilotAction.run(FastlaneCore::Configuration.create(PilotAction.available_options, options))
        UI.success("App is released to internal testing")

        Actions::GsSaveRcVersionAction.run(FastlaneCore::Configuration.create(GsSaveRcVersionAction.available_options, {version: v, path: Helper::GsProjectFlowIosHelper.get_versions_path}))
        ENV['RC_DID_FAILED'] = 'false'

        # version_name = "3" + "." + "5" + "." + "5"

        Actions::GsExecuteRcLaneAction.moveToReview(version_name)
        UI.success("✅ App status is changed to Waiting For Review")
        options[:distribute_external] = true
        # options[:review_contact_info] = {
        #     review_first_name: "MyTestAccount",
        #     review_last_name: "MyTestAccount",
        #     review_phone_number: "88432000555",
        #     review_contact_email: "cimobdaemon@gmail.com",
        # }
        begin
          Actions::GsMoveRcToBetaReviewAction.run(FastlaneCore::Configuration.create(GsMoveRcToBetaReviewAction.available_options,
                                                                                     options))
          UI.success("App is moved to beta review for external testing")
        rescue Exception => e
          UI.important(e.message)
        end
      end


      def self.moveToReview(version)
        s = Actions::GsGetAppStatusAction.run(FastlaneCore::Configuration.create(GsGetAppStatusAction.available_options, {app_identifier: ENV["BUNDLE_ID"]}))
        arg = FastlaneCore::Configuration.create(GsIncrementReleaseVersionAction.available_options, {path: Helper::GsProjectFlowIosHelper.get_versions_path})
        v = GsIncrementReleaseVersionAction.run(arg)
        # match(type: "appstore")
        # snapshot
        version_name = v.major.to_s + "." + v.minor.to_s

        # generateReleaseNotes("fileClosed", ENV["ALIAS"], version_name, "Ru")
        # generateReleaseNotes("fileClosed", ENV["ALIAS"], version_name, "En")

        ruText = Helper::FileHelper.read(Dir.pwd + "/../../notes/" + ENV["ALIAS"] + "/" + version_name + "_Ru.txt")
        enText = Helper::FileHelper.read(Dir.pwd + "/../../notes/" + ENV["ALIAS"] + "/" + version_name + "_En.txt")
        Helper::FileHelper.write(Dir.pwd+'/fastlane/metadata/ru/release_notes.txt', ruText)
        Helper::FileHelper.write(Dir.pwd+'/fastlane/metadata/en-US/release_notes.txt', enText)
        # gym(scheme: ENV["APP_SCHEME"]) # Build your app - more options available
        if s == "Waiting For Review" || s == "Pending Developer Release"
          Actions::GsRejectLatestVersionAction.run(FastlaneCore::Configuration.create(GsRejectLatestVersionAction.available_options, {app_identifier: ENV["BUNDLE_ID"]}))
        end
        Actions::DeliverAction.run(FastlaneCore::Configuration.create(DeliverAction.available_options, {force: true,
                                                                                                        submit_for_review: true,
                                                                                                        app_version: version,
                                                                                                        skip_binary_upload: true,
                                                                                                        automatic_release: false,
                                                                                                        submission_information: {
                                                                                                            add_id_info_limits_tracking: ENV["LIMITS_TRACKING"], #в данном приложении, а также в любом связанном с ним стороннем сервисе используется проверка рекламного идентификатора и применяются пользовательские настройки ограничения трекинга рекламы в iOS.
                                                                                                            add_id_info_serves_ads: ENV["IS_ADS_IN_APP_IDFA"], #Размещение рекламы в приложении
                                                                                                            add_id_info_tracks_action: ENV["TRACKS_USER_ACTIONS_IDFA"], # определения связи между действиями пользователя внутри приложения и ранее размещенной рекламой.
                                                                                                            add_id_info_tracks_install: ENV["TRACKS_INSTALL_IDFA"], # определения связи между установкой приложения и ранее размещенной рекламой;
                                                                                                            add_id_info_uses_idfa: ENV["USES_IDFA"], #В приложении используется рекламный идентификатор (IDFA)?
                                                                                                            content_rights_has_rights: true,
                                                                                                            content_rights_contains_third_party_content: false,
                                                                                                            export_compliance_platform: 'ios',
                                                                                                            export_compliance_compliance_required: false,
                                                                                                            export_compliance_encryption_updated: false,
                                                                                                            export_compliance_uses_encryption: ENV["USES_ENCRYPTION"],
                                                                                                            export_compliance_is_exempt: false,
                                                                                                            export_compliance_contains_third_party_cryptography: false,
                                                                                                            export_compliance_contains_proprietary_cryptography: false,
                                                                                                            export_compliance_available_on_french_store: true
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