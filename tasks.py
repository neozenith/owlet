#!/usr/bin/env python3
# Standard Library
import json
import os
import sys
from pprint import pprint as pp
import shlex
import subprocess
from subprocess import run
from pathlib import Path
import shutil
import os

__VERSION__ = "0.1.0"

default_scripts = {
    "version": __VERSION__,
    "init": [
        {"sh":"python3 -m venv .venv"},
        {"py":"pip install --upgrade pip setuptools"},
        {"py":"pip list -v --no-index"}
    ]
}

def _check_config():
    if not os.path.isfile("tasks.json"):
        with open("tasks.json", "w") as f:
            f.write(json.dumps(default_scripts, indent=2))

def _load_config():
    _check_config()
    with open("tasks.json", "r") as f:
        config = json.load(f)
    return config

def _tasks_from_functions(prefix = "task_"):
    return {k.replace(prefix, ""): v for k, v in globals().items() if k.startswith(prefix)}

def _shcmd(command, args=[], **kwargs):
    if 'shell' in kwargs and kwargs['shell']:
        return run(command, **kwargs)
    else:
        cmd_parts = command if type(command) == list else shlex.split(command)
        cmd_parts = cmd_parts + args
        return run(cmd_parts + args, **kwargs)


def _pycmd(command, args=[]):
    py3 = ".venv/bin/python3"
    cmd_parts = command if type(command) == list else shlex.split(command)
    return run([py3, "-m"] + cmd_parts + args)

def _tfoutput(key_name):
    opts = {"capture_output":True, "text":True}
    return _shcmd(f"terraform -chdir=infra output -raw {key_name}", **opts).stdout

def _run_task(task, steps, args):
    if isinstance(steps, str):
        print(steps)
    elif callable(steps):
        return steps(args)
    else:
        return [_run_step(step, args) for step in steps]

def _run_step(step, args):
    for step_type, script in step.items():
        if step_type == "sh":
            return _shcmd(script, args)
        elif step_type == "sh+":
            return _shcmd(script, args, shell=True)
        elif step_type == "py":
            return _pycmd(script, args)
        else:
            raise ValueError(f"Unknown task step type {step_type} for script {script}")


def _exit_handler(status):
    statuses = status if type(status) == list else [status]
    bad_statuses = [s for s in statuses if hasattr(s, 'returncode') and s.returncode != 0]
    if bad_statuses:
        sys.exit(bad_statuses)

def task_build(*args, **kwargs):
    # Only import on demand to keep the rest of this file dependency free
    import yaml
    with open('data_model.yml', 'r', encoding='utf-8') as stream:
        schemas = yaml.safe_load(stream)

    for target in schemas.keys():
        _build_lambda(target)

    return

def _build_lambda(target):
    print(f"\nBUILD: {target}")
    src_dir = f"backend/{target}"
    out_dir = f"backend/dist/{target}"

    if not Path(src_dir).is_dir():
        raise Error(f"Could not build '{target}' because missing folder '{src_dir}'")

    print(f"CLEAN: {out_dir}")
    if Path(out_dir).is_dir():
        shutil.rmtree(out_dir)

    print(f"COPY: {src_dir} -> {out_dir}")
    shutil.copytree(src_dir, out_dir)

    # install deps
    print(f"DEPS: {src_dir}/requirements.txt -> {out_dir}")
    _pycmd(f"pip install --target {out_dir} -r {src_dir}/requirements.txt --ignore-installed -qq")

def task_uibuild(*args, **kwargs):
    opts = {"cwd":"frontend/"}
    return _shcmd("npm run build", **opts)

def task_uideploy(*args, **kwargs):
    bucket = _tfoutput("website_bucket")
    profile = _tfoutput("aws_profile")
    print({bucket, profile})
    return _shcmd(f"aws s3 cp frontend/build/ s3://{bucket}/ --recursive --profile={profile}")

def task_uidestroy(*args, **kwargs):
    bucket = _tfoutput("website_bucket")
    profile = _tfoutput("aws_profile")
    return _shcmd(f"aws s3 rm s3://{bucket}/ --recursive --profile={profile}")


if __name__ == "__main__":
    tasks = _load_config()
    tasks.update(_tasks_from_functions())

    if len(sys.argv) >= 2 and sys.argv[1] in tasks.keys():
        task = sys.argv[1]
        args = sys.argv[2:]
        steps = tasks[task]
        _exit_handler(_run_task(task, steps, args))
    else:
        task_keys = "\n\t".join(list(tasks.keys()))
        print(f"Must provide a task from the following:\n\t{task_keys}")
