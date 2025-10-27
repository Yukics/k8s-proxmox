#!/bin/bash

if ! [[ -d ".venv"  ]]; then
    python3 -m venv .venv
fi

/bin/bash -c ' \
    source .venv/bin/activate; \
    export PYTHONWARNINGS="ignore"; \
    export ANSIBLE_CONFIG=ansible.cfg; \
    echo "[INFO] pass "withdeps" as args to install dependencies from requirements.txt"; \
    if [ "$1" == "withdeps" ]; then pip3 install -r requirements.txt; fi; \
    exec /bin/bash -i; \
    ansible-galaxy install -r collections/requirements.yml -p roles/; \
    ansible-playbook playbooks/install.yml -i inventory/inventory.yml -b --ask-become-pass'



