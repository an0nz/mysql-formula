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
        expire_logs_days: 7
        max_binlog_size: 1024M
        log-bin: binlog

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
      auto_increment_increment: 5
      binlog_format: ROW
      default-storage-engine: innodb
      innodb_autoinc_lock_mode: 2
      expire_logs_days: 7
      max_binlog_size: 1024M
      log-bin: binlog
      server-id: 1
      log_replica_updates: 1
      pxc_strict_mode: ENFORCING
      pxc-encrypt-cluster-traffic: 'OFF'
      wsrep_cluster_address: gcomm://master-pxc,member-pxc
      wsrep_provider: /usr/lib/galera4/libgalera_smm.so
      wsrep_cluster_name: "my_wsrep_cluster"
      wsrep_applier_threads: 8
      wsrep_certify_nonPK: 1
      wsrep_max_ws_rows: 131072
      wsrep_max_ws_size: 1073741824
      wsrep_debug: 0
      wsrep_log_conflicts: noarg_present
      wsrep_retry_autocommit: 1
      wsrep_auto_increment_control: 1
      wsrep_causal_reads: 0
      wsrep_sst_method: xtrabackup-v2
    mysql:
      # my.cnf param that not require value
      no-auto-rehash: noarg_present

  galera_cluster:
    # bootstrap MUST only be set to true for 1 member of the cluster, that member MUST
    # be configured first so the others can join
    bootstrap: true

  galera_config:
    enabled: true
    sections:
      mysqld:
        server-id: 1
        log_replica_updates: 1
        pxc_strict_mode: ENFORCING
        pxc-encrypt-cluster-traffic: 'OFF'
        wsrep_cluster_address: gcomm://master-pxc,member-pxc
        wsrep_provider: /usr/lib/galera4/libgalera_smm.so
        wsrep_cluster_name: "my_wsrep_cluster"
        wsrep_applier_threads: 8
        wsrep_certify_nonPK: 1
        wsrep_max_ws_rows: 131072
        wsrep_max_ws_size: 1073741824
        wsrep_debug: 0
        wsrep_log_conflicts: noarg_present
        wsrep_retry_autocommit: 1
        wsrep_auto_increment_control: 1
        wsrep_causal_reads: 0
        wsrep_sst_method: xtrabackup-v2

  # salt_user:
  #   salt_user_name: 'salt'
  #   salt_user_password: 'someotherpass'
  #   grants:
  #     - 'all privileges'

  # Manage databases
  database:
    # Simple definition using default charset and collate
    - foo
    # Detailed definition
    - name: bar
      character_set: utf8
      collate: utf8_general_ci
    # Delete DB
    - name: obsolete_db
      present: false
  schema:
    foo:
      load: false
    bar:
      load: false
    baz:
      load: true
      source: salt://{{ tpldir }}/files/baz.schema.tmpl
      template: jinja
    qux:
      load: true
      source: salt://{{ tpldir }}/files/qux.schema.tmpl
      template: jinja
      context:
        encabulator: Turbo
        girdlespring: differential
    quux:
      load: true
      source: salt://{{ tpldir }}/files/qux.schema.tmpl
      template: jinja
      context:
        encabulator: Retro
        girdlespring: integral

  # Manage users
  # you can get pillar for existing server using scripts/import_users.py script
  user:
    frank:
      password: 'somepass'
      host: localhost
      databases:
        - database: foo
          grants: ['select', 'insert', 'update']
          escape: true
    # bob:
    #   password_hash: '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4'
    #   host: '%' # Any host
    #   ssl: true
    #   ssl-X509: true
    #   ssl-SUBJECT: Subject
    #   ssl-ISSUER: Name
    #   ssl-CIPHER: Cipher
    #   databases:
    #     # https://github.com/saltstack/salt/issues/41178
    #     # If you want to refer to databases using wildcards, turn off escape so
    #     # the renderer does not escape them, enclose the string in '`' and
    #     # use two '%'
    #     - database: '`foo\_%%`'
    #       grants: ['all privileges']
    #       grant_option: true
    #       escape: false
    #     - database: bar
    #       table: foobar
    #       grants: ['select', 'insert', 'update', 'delete']
    nopassuser:
      password: ~
      # host: localhost  # requires unix_socket plugin
      databases: []
    application:
      password: 'somepass'
      mine_hosts:
        target: "G@role:database and *.example.com"
        function: "network.get_hostname"
        expr_form: compound
      databases:
        - database: foo
          grants: ['select', 'insert', 'update']

    # Remove a user
    obsoleteuser:
      host: localhost
      # defaults to true
      present: false

  # Override any names defined in map.jinja
  # serverpkg: mysql-server
  # clientpkg: mysql-client
  # service: mysql
  # pythonpkg: python-mysqldb
  # devpkg: mysql-devel
  # debconf_utils: debconf-utils

  # Install MySQL headers
  dev:
    # Install dev package - defaults to false
    install: false
