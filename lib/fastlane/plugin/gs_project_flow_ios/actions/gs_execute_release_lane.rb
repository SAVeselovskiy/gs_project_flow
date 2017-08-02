module Fastlane
  module Actions
    class GsExecuteReleaseLaneAction < Action
      def self.run(params)
        require 'fastlane/plugin/gs_versioning'
        require 'fastlane/plugin/versioning'
        require 'fastlane/plugin/gs_deliver'

        test = ENV["LIMITS_TRACKING"]

        UI.important("test = " + test.to_s)
        raise "error"

        # s = Actions::GsGetAppStatusAction.run(FastlaneCore::Configuration.create(GsGetAppStatusAction.available_options,{app_identifier:ENV["BUNDLE_ID"]}))
        # UI.success("App Status = " + s)
        #
        # arg = FastlaneCore::Configuration.create(GsIncrementReleaseVersionAction.available_options, {path:Helper::GsProjectFlowIosHelper.get_versions_path})
        # v = GsIncrementReleaseVersionAction.run(arg)
        # version_name = v.major.to_s + "." + v.minor.to_s
        # ruText = Helper::GsProjectFlowIosHelper.new.generateReleaseNotes("fileClosed", ENV["ALIAS"], version_name, "Ru")
        # enText = Helper::GsProjectFlowIosHelper.new.generateReleaseNotes("fileClosed", ENV["ALIAS"], version_name, "En")
        # # generateReleaseNotes("fileClosed", ENV["ALIAS"], version_name, "En")
        #
        # Helper::FileHelper.write(Dir.pwd+'/metadata/ru/release_notes.txt', ruText)
        # Helper::FileHelper.write(Dir.pwd+'/metadata/en-US/release_notes.txt', enText)
        #
        # if s == "Waiting For Review"
        #   Actions::DeliverAction.run(FastlaneCore::Configuration.create(DeliverAction.available_options,{
        #       force:true,
        #       app_version: version_name,
        #       skip_binary_upload:true,
        #       skip_screenshots: true,
        #       #skip_metadata: true,
        #       automatic_release:true,
        #       submission_information: {
        #           add_id_info_limits_tracking: ENV["LIMITS_TRACKING"], #в данном приложении, а также в любом связанном с ним стороннем сервисе используется проверка рекламного идентификатора и применяются пользовательские настройки ограничения трекинга рекламы в iOS.
        #           add_id_info_serves_ads: ENV["IS_ADS_IN_APP_IDFA"],  #Размещение рекламы в приложении
        #           add_id_info_tracks_action: ENV["TRACKS_USER_ACTIONS_IDFA"],  # определения связи между действиями пользователя внутри приложения и ранее размещенной рекламой.
        #           add_id_info_tracks_install: ENV["TRACKS_INSTALL_IDFA"],  # определения связи между установкой приложения и ранее размещенной рекламой;
        #           add_id_info_uses_idfa: ENV["USES_IDFA"],  #В приложении используется рекламный идентификатор (IDFA)?
        #           content_rights_has_rights: true,
        #           content_rights_contains_third_party_content: false,
        #           export_compliance_platform: 'ios',
        #           export_compliance_compliance_required: false,
        #           export_compliance_encryption_updated: false,
        #           export_compliance_app_type: nil,
        #           export_compliance_uses_encryption: ENV["USES_ENCRYPTION"],
        #           export_compliance_is_exempt: false,
        #           export_compliance_contains_third_party_cryptography: false,
        #           export_compliance_contains_proprietary_cryptography: false,
        #           export_compliance_available_on_french_store: true
        #       }}))
        #   UI.success("✅ Automatic release is set. App will be released in store after AppReview")
        # elsif s == "Pending Developer Release"
        #   Actions::GsMoveToReadyForSaleAction.run(FastlaneCore::Configuration.create(GsMoveToReadyForSaleAction.available_options,{app_identifier:ENV["BUNDLE_ID"]}))
        #   UI.success("✅ App is released to store")
        # else
        #   raise "App has got unexpected status. Expected statuses: waitingForReview or PendingDeveloperRelease. Current status: "+s
        # end
        # Actions::GsSaveReleaseVersionAction.run(FastlaneCore::Configuration.create(GsSaveReleaseVersionAction.available_options,{version:v, path:Helper::GsProjectFlowIosHelper.get_versions_path}))


        # s = gs_get_app_status(app_identifier:ENV["BUNDLE_ID"])
        # UI.success("App Status = " + s)
        # version_name = v.major.to_s + "." + v.minor.to_s

        # generateReleaseNotes("fileClosed", ENV["ALIAS"], version_name, "Ru")
        # generateReleaseNotes("fileClosed", ENV["ALIAS"], version_name, "En")
        # ruText = FileHelper.read(Dir.pwd + "/../../../notes/" + ENV["ALIAS"] + "/" + version_name + "_Ru.txt")
        # enText = FileHelper.read(Dir.pwd + "/../../../notes/" + ENV["ALIAS"] + "/" + version_name + "_En.txt")
        # FileHelper.write(Dir.pwd+'/metadata/ru/release_notes.txt', ruText)
        # FileHelper.write(Dir.pwd+'/metadata/en-US/release_notes.txt', enText)
        # if s == "Waiting For Review"
        #   deliver(#submit_for_review: true,
        #       force:true,
        #       app_version: version_name,
        #       skip_binary_upload:true,
        #       skip_screenshots: true,
        #       #skip_metadata: true,
        #       automatic_release:true,
        #       submission_information: {
        #           add_id_info_limits_tracking: false,
        #           add_id_info_serves_ads: false,
        #           add_id_info_tracks_action: false,
        #           add_id_info_tracks_install: false,
        #           add_id_info_uses_idfa: false,
        #           content_rights_has_rights: true,
        #           content_rights_contains_third_party_content: false,
        #           export_compliance_platform: 'ios',
        #           export_compliance_compliance_required: false,
        #           export_compliance_encryption_updated: false,
        #           export_compliance_app_type: nil,
        #           export_compliance_uses_encryption: false,
        #           export_compliance_is_exempt: false,
        #           export_compliance_contains_third_party_cryptography: false,
        #           export_compliance_contains_proprietary_cryptography: false,
        #           export_compliance_available_on_french_store: false
        #       })
        #   UI.success("✅ Automatic release is set. App will be released in store after AppReview")
        # elsif s == "Pending Developer Release"
        #   gs_move_to_ready_for_sale(app_identifier:ENV["BUNDLE_ID"])
        #   UI.success("✅ App is released to store")
        # else
        #   raise "App has got unexpected status. Expected statuses: waitingForReview or PendingDeveloperRelease. Current status: "+s
        #   return
        # end
        # gs_save_release_version(path: ENV["path_to_versions"], version: v)

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
