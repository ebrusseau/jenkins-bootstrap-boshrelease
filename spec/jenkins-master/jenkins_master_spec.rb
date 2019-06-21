require 'rspec'
require 'json'
require 'yaml'
require 'bosh/template/test'
require 'bosh/template/evaluation_context'

describe 'jenkins-master job' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../..')) }
  let(:job) { release.job('jenkins-master') }

  describe 'data/properties.sh' do
    let(:template) { job.template('data/properties.sh') }

    it 'raises error if given port is < 1024' do
      expect {
        template.render("port" => 1023)
      }.to raise_error "Ports lower than 1024 or higher than 4000 are not allowed"
    end
  end

  describe 'config/jenkins_config.yml' do
    let(:template) { job.template('config/jenkins_config.yml') }
    let(:deployment_manifest_fragment) do
      {
        'labels' => 'some-label',
        'mode' => 'normal',
        'executors' => 5,
        'port' => '8000',
      }
    end

      # let(:erb_yaml) { File.read(File.join(File.dirname(__FILE__), '../jobs/registry/templates/config/jenkins_config.yml.erb')) }
    subject(:default_yaml) do
      binding = Bosh::Template::EvaluationContext.new({}, nil).get_binding
      YAML.safe_load(template.render({}))
    end

    subject(:merged_yaml) do
      binding = Bosh::Template::EvaluationContext.new(deployment_manifest_fragment, nil).get_binding
      YAML.safe_load(template.render(deployment_manifest_fragment))
    end

    it 'renders with defaults' do
      expect(default_yaml['jenkins'].key?('labels')).to be_falsey
      expect(default_yaml['jenkins']['mode']).to eq('EXCLUSIVE')
      expect(default_yaml['jenkins']['numExecutors']).to eq(0)
      expect(default_yaml['unclassified']['location']['url']).to eq('http://192.168.0.0:8080')
    end

    it 'renders with provided manifest properties' do
      expect(merged_yaml['jenkins']['labelString']).to eq('some-label')
      expect(merged_yaml['jenkins']['mode']).to eq('NORMAL')
      expect(merged_yaml['jenkins']['numExecutors']).to eq(5)
      expect(merged_yaml['unclassified']['location']['url']).to eq('http://192.168.0.0:8000')
    end
  end
end
