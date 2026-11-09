Scenario. You are a junior platform engineer at Acme Shop. The team is replacing hand-configured servers with Ansible. You have three Ubuntu 22.04 managed nodes: two web servers and one database server. They run as systemd-enabled Docker containers on your lab server and are reached over SSH, the same way real hosts are. Your job is to bring them under configuration management, secure them, deploy the application stack, and run a safe rolling release.

What you will build:

A control node: Ansible in a Python virtual environment, a project ansible.cfg, and a YAML inventory with nested groups, group_vars and host_vars.
A baseline playbook that installs packages, creates users and sudo rules, deploys a templated MOTD and hardens sshd with validation and handlers.
Custom facts, registered variables and a hands-on demonstration of variable precedence.
Two roles: webserver (nginx) and database (MariaDB). The database credentials are protected with Ansible Vault.
A deliberately broken playbook that you diagnose and repair with --syntax-check, -v, ansible-doc and ansible-lint.
A rolling deployment (serial: 1) with health checks, delegation and an automatic rollback using block/rescue.
A top-level site.yml with tags, limits, check mode, an idempotency proof, a lint gate and a generated inventory report.
