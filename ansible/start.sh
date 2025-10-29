#!/bin/bash
set -e

export PYTHONWARNINGS="ignore"
export ANSIBLE_CONFIG="ansible.cfg"

if ! [[ -d ".venv"  ]]; then python3 -m venv .venv; fi
source .venv/bin/activate
pip3 install -r requirements.txt
ansible-galaxy install -r collections/requirements.yml -p roles/
ansible-playbook playbooks/install.yml -i inventory/inventory.yml -b --ask-become-pass
