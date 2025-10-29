from ansible_collections.community.general.plugins.callback.yaml import CallbackModule as CallbackModule_default
import collections

DOCUMENTATION = """
author: Nelson G. & Jean-Christophe Vassort <anatomicjc@open-web.fr>
name: protect_data
type: stdout
short_description: hide sensitive data such as passwords from screen output
description:
    - hide passwords from screen output
    - https://serverfault.com/questions/754860/how-can-i-reduce-the-verbosity-of-certain-ansible-tasks-to-not-leak-passwords-in/809509#809509
extends_documentation_fragment:
  - default_callback
requirements:
  - set as stdout in configuration
options:
  sensitive_keywords:
    description:
        - a list of sensitive keywords to hide separated with a comma
    type: str
    env:
        - name: PROTECT_DATA_SENSITIVE_KEYWORDS
    ini:
        - section: callback_protect_data
          key: sensitive_keywords
    default: vault,pwd,pass
"""

EXAMPLES = r'''
ansible.cfg: >
  # Enable plugin
  [defaults]
  stdout_callback = protect_data

  [callback_protect_data]
  sensitive_keywords = vault,pwd,pass
'''

class CallbackModule(CallbackModule_default):
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = "stdout"
    CALLBACK_NAME = "protect_data"

    def __init__(self):
        super(CallbackModule, self).__init__()
        self.sensitive_keywords = ''

    def set_options(self, task_keys=None, var_options=None, direct=None):

        super(CallbackModule, self).set_options(task_keys=task_keys, var_options=var_options, direct=direct)

        self.sensitive_keywords = self.get_option('sensitive_keywords').split(',')
        
        # Debug info
        #print(self.sensitive_keywords)


    def v2_runner_on_start(self, host, task):
        return True

    def _get_item_label(self, result):
        """retrieves the value to be displayed as a label for an item entry from a result object"""
        result = self.hide_password(result)
        if result.get("_ansible_no_log", False):
            item = "(censored due to no_log)"
        else:
            item = result.get("_ansible_item_label", result.get("item"))
        return item

    def hide_password(self, result):
        ret = {}
        for key, value in result.items():
            sensitive_content = False
            if isinstance(value, (collections.ChainMap, dict)):
                ret[key] = self.hide_password(value)
            else:
                # Each variable containing sensitive_keywords will be hidden from output
                for sensitive_keyword in self.sensitive_keywords:
                    if sensitive_keyword in key:
                        ret[key] = "********"
                        sensitive_content = True
                if not sensitive_content:
                    ret[key] = value
        return ret

    def _dump_results(self, result, indent=None, sort_keys=True, keep_invocation=False):
        return super(CallbackModule, self)._dump_results(
            self.hide_password(result), indent, sort_keys, keep_invocation
        )