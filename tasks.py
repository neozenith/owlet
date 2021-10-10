#!/usr/bin/env python3
# Standard Library
import json
import os
import sys
from subprocess import run

__VERSION__ = "0.1.0"

default_scripts = {
    "version": __VERSION__,
    "init": [
        {"sh":"python3 -m venv .venv"},
        {"py":"pip install --upgrade pip setuptools"},
        {"py":"pip list -v --no-index"}
    ]
    # TODO: Implement default tooling config generation
    #  "lint": [
    #      {"sh": "black ."},
    #      {"sh": "flake8 ."},
    #      {"sh": "isort ."},
    #  ],
    #  "test": [
    #      {"py": "pytest"}
    #  ]
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

def _shcmd(command, args=[]):
    return run(command.split(" ") + args)


def _pycmd(command, args=[]):
    py3 = ".venv/bin/python3"
    return run([py3, "-m"] + command.split(" ") + args)

def _run_task(task, steps, args):
    if task == "version":
        print(steps)
        return

    return [
        _run_step(step, args)
        for step in steps
    ]

def _run_step(step, args):
    for step_type, script in step.items():
        if step_type == "sh":
            return _shcmd(script, args)
        elif step_type == "py":
            return _pycmd(script, args)
        else:
            raise ValueError(f"Unknown task step type {step_type} for script {script}")


def _exit_handler(status):
    statuses = status if type(status) == list else [status]
    bad_statuses = [s for s in statuses if hasattr(s, 'returncode') and s.returncode != 0]
    if bad_statuses:
        sys.exit(bad_statuses)


if __name__ == "__main__":
    tasks = _load_config()

    if len(sys.argv) >= 2 and sys.argv[1] in tasks.keys():
        task = sys.argv[1]
        args = sys.argv[2:]
        steps = tasks[task]
        _exit_handler(_run_task(task, steps, args))
    else:
        print(f"Must provide a task from the following: {list(tasks.keys())}")
