#!/usr/bin/env bash
# Final validation for the Ansible lab
cd "$HOME/ansible-lab" || exit 1
# shellcheck disable=SC1091
source "$HOME/ansible-venv/bin/activate"
PASS=0; FAIL=0

check() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    printf 'PASS  %s\n' "$desc"; PASS=$((PASS+1))
  else
    printf 'FAIL  %s\n' "$desc"; FAIL=$((FAIL+1))
  fi
}

t1_nodes()   { [ "$(docker inspect -f '{{.State.Running}}' web1 web2 db1 | grep -c true)" -eq 3 ]; }
t1_ping()    { ansible all -m ansible.builtin.ping; }
t1_groups()  { ansible-inventory --graph | grep -q '@webservers' && ansible-inventory --graph | grep -q '@dbservers'; }
t2_users()   { [ "$(ansible all -m ansible.builtin.command -a 'id -nG alice' | grep -c devops)" -eq 3 ]; }
t2_sshd()    { [ "$(ansible all -b -m ansible.builtin.shell -a 'sshd -T | grep -i ^permitrootlogin' | grep -ci 'permitrootlogin no')" -eq 3 ]; }
t3_facts()   { [ "$(ansible all -m ansible.builtin.setup -a 'filter=ansible_local' | grep -c '"team": "platform"')" -eq 3 ]; }
t3_prec()    { ansible-inventory --host web2 | grep -q '"app_env": "canary"'; }
t4_page()    { curl -fs http://127.0.0.1:8081/ | grep -q 'Acme Shop' && curl -fs http://127.0.0.1:8082/ | grep -q 'canary'; }
t4_health()  { curl -fs http://127.0.0.1:8082/healthz | grep -q ok; }
t5_vault()   { head -1 inventory/group_vars/dbservers/vault.yml | grep -q 'ANSIBLE_VAULT;1.1;AES256'; }
t5_db()      { ansible web1 -m ansible.builtin.command \
                 -a "mysql -h db1 -u appuser -p{{ hostvars['db1']['db_password'] }} -e 'SHOW DATABASES;'" | grep -q appdb; }
t6_status()  { curl -fs http://127.0.0.1:8081/status/ | grep -q 'status=ok'; }
t6_lint()    { ansible-lint -q playbooks/broken.yml; }
t7_rollback(){ ansible webservers -m ansible.builtin.command -a 'cat /var/www/app/VERSION' \
                 | grep -c '1.1.0' | grep -q '^2$'; }
t7_serial()  { grep -q '^  serial: 1' playbooks/deploy.yml; }
t8_site()    { ansible-playbook site.yml --list-tags | grep -q 'TAGS: \[baseline\]'; }
t8_idem()    { ansible-playbook site.yml | grep -cE 'changed=0 +unreachable=0 +failed=0' | grep -q '^3$'; }
t8_lint()    { ansible-lint -q; }
t8_report()  { grep -q '^| db1 |' reports/inventory.md; }

echo "========== Ansible lab validation =========="
check "T1  three nodes running"            t1_nodes
check "T1  ping all hosts"                 t1_ping
check "T1  inventory has webservers/dbservers groups" t1_groups
check "T2  alice in devops on all 3 hosts" t2_users
check "T2  sshd PermitRootLogin no on all 3 hosts" t2_sshd
check "T3  custom fact team=platform on all 3 hosts" t3_facts
check "T3  web2 precedence: app_env=canary" t3_prec
check "T4  web1 serves Acme Shop, web2 serves canary" t4_page
check "T4  healthz responds ok on web2"    t4_health
check "T5  vault.yml is encrypted"         t5_vault
check "T5  db reachable from web1 with vaulted password" t5_db
check "T6  /status/ returns status=ok"     t6_status
check "T6  broken.yml passes ansible-lint" t6_lint
check "T7  both webservers on 1.1.0 (rollback worked)" t7_rollback
check "T7  deploy.yml uses serial: 1"      t7_serial
check "T8  site.yml exposes tags"          t8_site
check "T8  site.yml idempotent (changed=0 on 3 hosts)" t8_idem
check "T8  whole project lint-clean"       t8_lint
check "T8  inventory report exists"        t8_report

echo "--------------------------------------------"
echo "PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
