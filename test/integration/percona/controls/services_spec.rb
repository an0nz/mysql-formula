# frozen_string_literal: true

control 'mysql@bootstrap service' do
  title 'should be running'
  only_if { sys_info.hostname == 'master-pxc' }

  describe service('mysql@bootstrap') do
    it { should be_installed }
    it { should_not be_enabled }
    it { should be_running }
  end

  describe service('mysql') do
    it { should be_installed }
    it { should be_enabled }
    it { should_not be_running }
  end
end

control 'mysql service' do
  title 'should be running'
  only_if { sys_info.hostname == 'member-pxc' }

  describe service('mysql') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end
