require 'spec_helper_acceptance'

broker_pp = <<-EOS
class { 'druid::broker':
  processing_buffer_size_bytes => 134217728,
  jvm_max_mem_allocation_pool  => '512m',
  jvm_min_mem_allocation_pool  => '512m',
  processing_num_threads       => 1, 
}
EOS

describe 'druid::broker' do
  describe 'running puppet code' do
    it 'should run without errors' do
      apply_manifest(broker_pp, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(broker_pp, :catch_changes => true)
    end

    it 'should have a working druid CLI' do
      druid_cli('version') do |r|
        expect(r.stdout).to match(/Druid version - \d\.\d\.\d/)
      end
    end

    describe port(8082) do
      it { should be_listening }
    end

    describe service('druid-broker') do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
