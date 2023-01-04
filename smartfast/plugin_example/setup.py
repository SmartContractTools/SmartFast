from setuptools import setup, find_packages

setup(
    name="smartfast-my-plugins",
    description="This is an example of detectors and printers to Smartfast.",
    url="https://github.com/trailofbits/smartfast-plugins",
    author="Trail of Bits",
    version="0.0",
    packages=find_packages(),
    python_requires=">=3.6",
    install_requires=["smartfast-analyzer==0.1"],
    entry_points={"smartfast_analyzer.plugin": "smartfast my-plugin=smartfast_my_plugin:make_plugin",},
)
