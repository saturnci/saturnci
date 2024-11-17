# frozen_string_literal: true

require_relative '../helpers/authentication_helper'
require_relative '../helpers/api_helper'
require_relative '../../../lib/saturncicli/client'

describe 'ssh' do
  before do
    AuthenticationHelper.stub_authentication_request
    allow_any_instance_of(SaturnCICLI::SSHSession).to receive(:connect)
  end

  let!(:client) do
    SaturnCICLI::Client.new(
      username: 'valid_username',
      password: 'valid_password'
    )
  end

  context 'remote machine has an IP address' do
    let!(:body) do
      {
        'job_machine_rsa_key_path' => '/tmp/saturnci/job-abc123',
        'ip_address' => '111.11.11.1'
      }
    end

    before { APIHelper.stub_body('api/v1/jobs/abc123', body) }

    it 'outputs the job id' do
      expect do
        command = '--job abc123 ssh'
        client.execute(command)
      end.to output("ssh -o StrictHostKeyChecking=no -i /tmp/saturnci/job-abc123 root@111.11.11.1\n").to_stdout
    end
  end

  context 'remote machine does not yet have an IP address' do
    before do
      APIHelper.stub_body('api/v1/jobs/abc123', {})
      stub_const('ConnectionDetails::WAIT_INTERVAL_IN_SECONDS', 0)
      allow_any_instance_of(SaturnCICLI::ConnectionDetails).to receive(:ip_address).and_return(nil, '111.11.11.1')
      allow_any_instance_of(SaturnCICLI::ConnectionDetails).to receive(:rsa_key_path).and_return('/tmp/saturnci/job-abc123')
    end

    it 'outputs a dot' do
      expect do
        command = '--job abc123 ssh'
        client.execute(command)
      end.to output(".ssh -o StrictHostKeyChecking=no -i /tmp/saturnci/job-abc123 root@111.11.11.1\n").to_stdout
    end
  end
end
