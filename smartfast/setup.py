from setuptools import setup, find_packages

setup(
    name="smartfast-analyzer",
    description="Smartfast is a Solidity static analysis framework written in Python 3.",
    url="https://github.com/smartfast",
    author="Smart Analysis",
    version="0.0.4",
    packages=find_packages(),
    python_requires=">=3.6",
    install_requires=[
        "prettytable>=0.7.2",
        "pysha3>=1.0.2",
        "crytic-compile>=0.1.12",
        # "crytic-compile",
    ],
    # dependency_links=["git+https://github.com/crytic/crytic-compile.git@master#egg=crytic-compile"],
    license="AGPL-3.0",
    long_description=open("README.md").read(),
    entry_points={
        "console_scripts": [
            "smartfast = smartfast.__main__:main",
            "smartfast-check-upgradeability = smartfast.tools.upgradeability.__main__:main",
            "smartfast-find-paths = smartfast.tools.possible_paths.__main__:main",
            "smartfast-simil = smartfast.tools.similarity.__main__:main",
            "smartfast-flat = smartfast.tools.flattening.__main__:main",
            "smartfast-format = smartfast.tools.smartfast_format.__main__:main",
            "smartfast-check-erc = smartfast.tools.erc_conformance.__main__:main",
            "smartfast-check-kspec = smartfast.tools.kspec_coverage.__main__:main",
            "smartfast-prop = smartfast.tools.properties.__main__:main",
            "smartfast-mutate = smartfast.tools.mutator.__main__:main",
        ]
    },
)
