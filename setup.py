from setuptools import setup, find_packages

setup(
    name='lovebrew',
    version='0.1.1',
    url='',
    author='TurtleP',
    license='MIT',
    description='Löve Potion Game Helper',
    install_requires=["toml>=0.10"],
    packages=find_packages(),
    package_data={"lovebrew": ["data/icons/*"]},
    entry_points={'console_scripts': ['lovebrew=lovebrew.__main__:main']}
)
