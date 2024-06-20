#!/usr/bin/env python3

"""
Script that installs Python packages from PyPI.
Takes in the image distribution as the first argument.
"""

import subprocess
import sys

DISTRO = sys.argv[1]


def install(packages=[]):
    """Installer for pip packages

    Args:
        packages (list(str)): List of package names
    """
    if len(packages) > 0:
        subprocess.check_call(["pip3", "install", " ".join(packages)])


# Shared packages across distributions
shared_packages = []

# Packages specific to distribution
pip_packages = {
    "rstudio": shared_packages + [],
    "rstudio-local": shared_packages
    + [
        "pre-commit",
    ],
    "gcc13": [],
    "gcc14": [],
    "atlas": [],
    "valgrind": [],
    "intel": [],
    "nosuggests": [],
    "mkl": [],
}

# Install packages
install(pip_packages[DISTRO])
