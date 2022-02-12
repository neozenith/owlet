#!/usr/bin/env python3
# Standard Library
import os
import shlex
import shutil
import sys
from pathlib import Path
from subprocess import run

# NOTE:
# 1. python ./tasks.py
#    - Bootstrap venv and install invoke and create dummy decorator in interim
# 2. invoke <name of task>
#    - This should successfully import invoke and task decorator
try:
    # Third Party
    from invoke import task
except ImportError:
    task = lambda *args, **kwargs: lambda x: x  # noqa: E731

DEFAULT_PYPROJECT_CONFIG = """
[tool.black]
line-length = 120

[tool.isort]
profile = "black"
multi_line_output = 3
import_heading_stdlib = "Standard Library"
import_heading_firstparty = "Our Libraries"
import_heading_thirdparty = "Third Party"

[tool.pytest.ini_options]
minversion = "6.0"
addopts = "-v --color=yes"

"""

DEFAULT_FLAKE8_CONFIG = """
[flake8]
max-line-length=120
max-complexity = 10
exclude =
    # No need to traverse our git directory
    .git,
    # There's no value in checking cache directories
    __pycache__,
    # Ignore virtual environment folders
    .venv
"""

DEFAULT_REQUIREMENTS_DEV = """
invoke
flake8
isort
black
pytest
"""


def _check_deps(filename):
    if os.path.isfile(filename):
        print(f"Installing deps from {filename}")
        _shcmd(f".venv/bin/python3 -m pip install -qq --upgrade -r {filename}")


def _check_config(filename, content):
    if not os.path.isfile(filename):
        print(f"Generating {filename} ...")
        with open(filename, "w+") as f:
            f.write(content)


def _shcmd(command, args=[], **kwargs):
    if "shell" in kwargs and kwargs["shell"]:
        return run(command, **kwargs)
    else:
        cmd_parts = command if type(command) == list else shlex.split(command)
        cmd_parts = cmd_parts + args
        return run(cmd_parts + args, **kwargs)


def _tfoutput(key_name):
    opts = {"capture_output": True, "text": True}
    return _shcmd(f"terraform -chdir=infra output -raw {key_name}", **opts).stdout


@task
def format(c):
    """Autoformat code and sort imports."""
    c.run("black .")
    c.run("isort .")


@task
def lint(c):
    """Run linting and formatting checks."""
    c.run("black --check .")
    c.run("isort --check .")
    c.run("flake8 .")


@task(pre=[lint])
def test(c):
    """Run pytest."""
    c.run("python3 -m pytest")


@task
def build(c):
    """For each model in data_model.yml build backend lambda artifacts."""
    # Only import on demand to keep the rest of this file dependency free
    # Third Party
    import yaml

    with open("data_model.yml", "r", encoding="utf-8") as stream:
        schemas = yaml.safe_load(stream)

    for target in schemas.keys():
        _build_lambda(target)

    return


def _build_lambda(target):
    print(f"\nBUILD: {target}")
    src_dir = f"backend/{target}"
    out_dir = f"backend/dist/{target}"

    if not Path(src_dir).is_dir():
        raise ValueError(f"Could not build '{target}' because missing folder '{src_dir}'")

    print(f"CLEAN: {out_dir}")
    if Path(out_dir).is_dir():
        shutil.rmtree(out_dir)

    print(f"COPY: {src_dir} -> {out_dir}")
    shutil.copytree(src_dir, out_dir)

    # install deps
    print(f"DEPS: {src_dir}/requirements.txt -> {out_dir}")
    _shcmd(f"python3 -m pip install --target {out_dir} -r {src_dir}/requirements.txt --ignore-installed -qq")


@task
def uibuild(c):
    """Build UI Frontend artifacts locally."""
    opts = {"cwd": "frontend/"}
    return _shcmd("npm run build", **opts)


@task
def uideploy(c):
    """Upload built UI frontend components."""
    bucket = _tfoutput("website_bucket")
    profile = _tfoutput("aws_profile")
    print({bucket, profile})
    return _shcmd(f"aws s3 cp frontend/build/ s3://{bucket}/ --recursive --profile={profile}")


@task
def uidestroy(c):
    """Tear down deployed frontend artifacts."""
    bucket = _tfoutput("website_bucket")
    profile = _tfoutput("aws_profile")
    return _shcmd(f"aws s3 rm s3://{bucket}/ --recursive --profile={profile}")


@task
def tffmt(c):
    """Format and validate terraform code."""
    _shcmd("terraform -chdir=infra fmt")
    _shcmd("terraform -chdir=infra validate")


@task
def tfup(c):
    """Apply terraform modules to deploy updated state."""
    _shcmd("terraform -chdir=infra init -upgrade"),
    _shcmd("terraform -chdir=infra fmt"),
    _shcmd("terraform -chdir=infra validate"),
    _shcmd("terraform -chdir=infra apply -auto-approve")


@task
def tfdn(c):
    """Tear down terraform described state."""
    _shcmd("terraform -chdir=infra destroy -auto-approve")


@task
def uicreate(c):
    """Initialise UI Frontedn from scratch."""
    _shcmd("npx create-react-app --template cra-template-pwa-typescript --use-npm frontend")


@task
def uiserve(c):
    """Locally serve frontend UI for development purposes."""
    _shcmd("python3 -m http.server --directory frontend/build")


@task
def clean(c):
    """Clean local build artifacts."""
    _shcmd("rm -rfv backend/dist/")
    _shcmd("rm -rfv backend/*.zip", shell=True)
    _shcmd("rm -rf frontend/build/")


@task(pre=[build, tfup])
def devup(c):
    """Setup dev environment for local UI develpoment."""
    ...


@task(pre=[tfdn, clean])
def devdn(c):
    """Tear down dev environment."""
    ...


if __name__ == "__main__":

    if len(sys.argv) >= 2 and sys.argv[1] in ["init"]:
        _shcmd("rm -rf .venv")
        _shcmd("python3 -m venv .venv")
        _shcmd(".venv/bin/python3 -m pip install --upgrade pip")

        _check_config("requirements-dev.txt", DEFAULT_REQUIREMENTS_DEV)
        _check_config("pyproject.toml", DEFAULT_PYPROJECT_CONFIG)
        _check_config(".flake8", DEFAULT_FLAKE8_CONFIG)

        _check_deps("requirements.txt")
        _check_deps("requirements-dev.txt")

    else:
        print("This script should be run as:\n\n./tasks.py init\n\n")
        print("This will self bootstrap a virtual environment but then use:\n\n")
        print(". ./.venv/bin/activate")
        print("invoke --list")
