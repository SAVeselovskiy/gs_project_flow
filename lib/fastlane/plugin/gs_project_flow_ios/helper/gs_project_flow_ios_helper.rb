module Fastlane
  module Helper

    class FileHelper
      def self.read(path)
        file = File.open(path, "r+")
        res = file.read
        file.close
        res
      end
      def self.write(path, str)
        if not path.include? "."
          raise "Filepath has incorrect format. You must provide file extension"
        end
        require 'fileutils.rb'
        FileUtils.makedirs(File.dirname(path))
        file = File.open(path, "w+")
        file.write(str)
        file.close
      end
    end



    class GsProjectFlowIosHelper
      # class methods that you define here become available in your action
      # as `Helper::GsProjectFlowIosHelper.your_method`
      #
      def self.get_versions_path
        return Dir.pwd+"/../../versions.json"
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

      def generateReleaseNotes(cmd,  aliasServer, version, lang = nil)
        cmnd = cmd
        if lang != nil
          cmnd = cmnd+lang
        else
          raise "Language is required for release notes generating."
        end
        require 'fastlane/plugin/gs_deliver'
        # params = {cmd:cmnd,
        #           lang: lang,
        #           alias:aliasServer,
        #           displayVersionName:version}
        # text = execute_action('gs_get_release_notes', params)
        text = Actions::GsGetReleaseNotesAction.run(FastlaneCore::Configuration.create(Actions::GsGetReleaseNotesAction.available_options,{cmd:cmnd,
                             lang: lang,
                             alias:aliasServer,
                             displayVersionName:version}))
        # UI.message("Check exist " + Dir.pwd + "/../../../notes/" + aliasServer + "/" + version + "_" + lang + ".txt")
        # if !File.exist?(Dir.pwd + "/../../../notes/" + aliasServer + "/" + version + "_" + lang + ".txt")
        #   raise "Не удалось сгенерировать ReleaseNotes"
        # end
        return text
      end

      def self.version_for_lane(lane, buildState)
        version_name = ""
        if lane == :beta
          if buildState == BuildState::FAILURE
            v = Actions::GsIncrementBetaVersionAction.run(FastlaneCore::Configuration.create(Actions::GsIncrementBetaVersionAction.available_options,{path: GsProjectFlowIosHelper.get_versions_path}))
          else
            v = Actions::GsGetBetaVersionAction.run(FastlaneCore::Configuration.create(Actions::GsGetBetaVersionAction.available_options,{path: GsProjectFlowIosHelper.get_versions_path}))
          end

          version_name = v.major.to_s+ "." + v.minor.to_s + "." + v.build.to_s
        elsif lane == :rc
          if buildState == BuildState::FAILURE
            if ENV['RC_DID_FAILED'] #Если произошла ошибка до успешной отправки в стор
              v = Actions::GsIncrementRcVersionAction.run(FastlaneCore::Configuration.create(Actions::GsIncrementBetaVersionAction.available_options,{path: GsProjectFlowIosHelper.get_versions_path}))
            else
              v = Actions::GsGetRcVersionAction.run(FastlaneCore::Configuration.create(Actions::GsGetBetaVersionAction.available_options,{path: GsProjectFlowIosHelper.get_versions_path}))
            end
          else
            v = Actions::GsGetRcVersionAction.run(FastlaneCore::Configuration.create(Actions::GsGetBetaVersionAction.available_options,{path: GsProjectFlowIosHelper.get_versions_path}))
          end
          # v = gs_get_rc_version(path: GsProjectFlowIosHelper.get_versions_path)
          version_name = v.major.to_s+ "." + v.minor.to_s
        elsif lane == :release
          if buildState == BuildState::FAILURE
            v = Actions::GsIncrementReleaseVersionAction.run(FastlaneCore::Configuration.create(Actions::GsIncrementBetaVersionAction.available_options,{path: GsProjectFlowIosHelper.get_versions_path}))
          else
            v = Actions::GsGetReleaseVersionAction.run(FastlaneCore::Configuration.create(Actions::GsGetBetaVersionAction.available_options,{path: GsProjectFlowIosHelper.get_versions_path}))
          end
          # v = gs_get_release_version(path: GsProjectFlowIosHelper.get_versions_path)
          version_name = v.major.to_s+ "." + v.minor.to_s
        end
        return version_name,v
      end

      module BuildState
        START = "started"
        SUCCESS = "successful"
        FAILURE = "failed"
      end
      def self.send_report(message, buildState, lane, restartBuildURL = nil)
        # Dir.chdir Dir.pwd+"/../../../../" do
        UI.message(Dir.pwd)
        params = Hash.new
        params["state"] = buildState
        params["alias"] = ENV["ALIAS"]

        if buildState == BuildState::FAILURE
          params["message"] = message
        end
        if restartBuildURL != nil
          params["restart_build_url"] = restartBuildURL
        end

        if lane == :beta
          params["cmd"] = "beta"
        elsif lane == :rc
          params["cmd"] = "rc"
        elsif lane == :release
          params["cmd"] = "release"
        end



        paramsJSON = params.to_json


        client = Spaceship::GSBotClient.new
        url = 'jobStates'
        response = client.request(:post) do |req|
          req.url url
          req.body = paramsJSON
          req.headers['Content-Type'] = 'application/json'
        end
        UI.important('body ' + paramsJSON)
        if response.success?
          UI.important('status' + response.status.to_s)
          return response
        else
          raise (client.class.hostname + url + ' ' + response.status.to_s + ' ' + response.body['message'])
        end


          # Actions::ShAction.run(FastlaneCore::Configuration.create(Actions::ShAction.available_options,
          #                                                          {command:"curl -X POST -H \"Content-Type: application/json\" -d '#{paramsJSON}' http://mobile.geo4.io/bot/releaseBuilder/jobStates"}))
          # sh "sh build_reporter.sh " + chat_id.to_s + " " + message
        # end
      end

      def self.show_message
        UI.message("Hello from the gs_project_flow_ios plugin helper!")
      end
    end
  end
end
