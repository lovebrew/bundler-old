from setuptools import setup, find_packages

setup(
    name='lovebrew',
    version='0.2.1',
    author='TurtleP',
    author_email='jpostelnek@outlook.com',
    license='MIT',
    url='https://github.com/TurtleP/lovebrew',
    description='Löve Potion Game Helper',
    install_requires=["toml>=0.10"],
    packages=find_packages(),
    package_data={'lovebrew': ['data/meta/*']},
    entry_points={'console_scripts': ['lovebrew=lovebrew.__main__:main']},
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Operating System :: POSIX :: Linux'
    ]
)
