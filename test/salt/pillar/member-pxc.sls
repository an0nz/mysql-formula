# -*- coding: utf-8 -*-
# vim: ft=yaml
---
mysql:
  serverpkg: percona-xtradb-cluster
  service: mysql
  
  percona:
    # Used with percona-release setup to configure which percona release repository to use
    # Refer to https://docs.percona.com/percona-software-repositories/repository-location.html
    # Default is pxc-80 (Percona XtraDB Cluster 8.0)
    repo: pxc-80
    {%- if grains['os_family'] == 'Debian' %}
    releasepkg: https://repo.percona.com/apt/percona-release_latest.{{ grains['oscodename'] }}_all.deb
    {%- else %}
    releasepkg: https://repo.percona.com/yum/percona-release-latest.noarch.rpm
    {%- endif %}

  server_config:
    file: mysqld.cnf
    sections:
      mysqld_safe:
        log_error: /var/log/mariadb/mariadb.log
        pid_file: /var/lib/mysql/mysql.pid
      mysqld:
        socket: /var/lib/mysql/mysql.sock
        bind-address: 0.0.0.0
        binlog_format: ROW
        default-storage-engine: innodb
        innodb_autoinc_lock_mode: 2

  server:
    # Use this account for database admin (defaults to root)
    # root_user: 'admin'
    # root_password: '' - to have root@localhost without password
    root_password: 'somepass'
    root_password_hash: '*13883BDDBE566ECECC0501CDE9B293303116521A'
    user: mysql
    # If you only manage the dbs and users and the server is on
    # another host
    # host: 123.123.123.123
    # my.cnf sections changes
    mysqld:
      # you can use either underscore or hyphen in param names
      bind-address: 0.0.0.0
      # log_bin: /var/log/mysql/mysql-bin.log
      datadir: /var/lib/mysql
      # port: 3307
      # plugin-load-add: auth_socket.so
      binlog_do_db: foo
      auto_increment_increment: 5
      binlog-ignore-db:
        - mysql
        - sys
        - information_schema
        - performance_schema
      binlog_format: ROW
      default-storage-engine: innodb
      innodb_autoinc_lock_mode: 2
      pxc_strict_mode: ENFORCING
      pxc-encrypt-cluster-traffic: 'OFF'
      wsrep_cluster_address: gcomm://master-pxc,member-pxc
      wsrep_cluster_name: "my_wsrep_cluster"
      wsrep_slave_threads: 8
      wsrep_certify_nonPK: 1
      wsrep_max_ws_rows: 131072
      wsrep_max_ws_size: 1073741824
      wsrep_debug: 0
      wsrep_retry_autocommit: 1
      wsrep_auto_increment_control: 1
      wsrep_causal_reads: 0
      wsrep_sst_method: xtrabackup-v2
    mysql:
      # my.cnf param that not require value
      no-auto-rehash: noarg_present
  
  galera_config:
    enabled: true
    sections:
      mysqld:
        pxc_strict_mode: ENFORCING
        pxc-encrypt-cluster-traffic: 'OFF'
        wsrep_cluster_address: gcomm://master-pxc,member-pxc
        wsrep_provider: /usr/lib/galera4/libgalera_smm.so
        wsrep_cluster_name: "my_wsrep_cluster"
        wsrep_slave_threads: 8
        wsrep_certify_nonPK: 1
        wsrep_max_ws_rows: 131072
        wsrep_max_ws_size: 1073741824
        wsrep_debug: 0
        wsrep_retry_autocommit: 1
        wsrep_auto_increment_control: 1
        wsrep_causal_reads: 0
        wsrep_sst_method: xtrabackup-v2
