require 'spec_helper'

describe 'druid::indexing::middle_manager', :type => 'class' do
  context 'On system with 10 GB RAM and defaults for all parameters' do
    let(:facts) do
      {
        :memorysize => '10 GB',
      }
    end

    it {
      should compile.with_all_deps
      should contain_class('druid::indexing::middle_manager')
      should contain_druid__service('middle_manager')
      should contain_file('/etc/druid/middle_manager')
      should contain_file('/etc/druid/middle_manager/common.runtime.properties')
      should contain_file('/etc/druid/middle_manager/runtime.properties')
      should contain_file('/etc/systemd/system/druid-middle_manager.service')
      should contain_exec('Reload systemd daemon for new middle_manager service file')
      should contain_service('druid-middle_manager')
    }
  end

  context 'On base system with custom JVM parameters ' do
    let(:params) do
      {
        :jvm_opts => [
          '-server',
          '-Xmx4g',
          '-Xms4g',
          '-XX:NewSize=256m',
          '-XX:MaxNewSize=256m',
          '-XX:MaxDirectMemorySize=2g',
          '-Duser.timezone=PDT',
          '-Dfile.encoding=latin-1',
          '-Djava.util.logging.manager=custom.LogManager',
          '-Djava.io.tmpdir=/mnt/tmp',
        ]
      }
    end

    it {
      should contain_file('/etc/systemd/system/druid-middle_manager.service').with_content("[Unit]\nDescription=Druid Middle Manager Node\n\n[Service]\nType=simple\nWorkingDirectory=/etc/druid/middle_manager/\nExecStart=/usr/bin/java -server -Xmx4g -Xms4g -XX:NewSize=256m -XX:MaxNewSize=256m -XX:MaxDirectMemorySize=2g -Duser.timezone=PDT -Dfile.encoding=latin-1 -Djava.util.logging.manager=custom.LogManager -Djava.io.tmpdir=/mnt/tmp -classpath .:/usr/local/lib/druid/lib/* io.druid.cli.Main server middleManager\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target\n")
    }
  end

  context 'On system with 10 GB RAM and custom druid configs' do
    let(:facts) do
      {
        :memorysize => '10 GB',
      }
    end

    let(:params) do
      {
      }
    end 
    
    it {
      should contain_file('/etc/druid/middle_manager/runtime.properties').with_content("# Node Configs\ndruid.host=\ndruid.port=8090\ndruid.service=druid/middlemanager\n\n# Task Logging\ndruid.indexer.logs.type=file\ndruid.indexer.logs.directory=/var/log\n")

    }
  end
end
