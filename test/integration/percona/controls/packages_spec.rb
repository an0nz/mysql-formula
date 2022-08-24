# frozen_string_literal: true

control 'mysql package' do
  title 'should be installed'

  describe package('percona-xtradb-cluster') do
    it { should be_installed }
  end
end
