describe Fastlane::Actions::GsProjectFlowIosAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The gs_project_flow_ios plugin is working!")

      Fastlane::Actions::GsProjectFlowIosAction.run(nil)
    end
  end
end
