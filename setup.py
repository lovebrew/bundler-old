from setuptools import setup, find_packages

with open('README.md', 'r', encoding='utf-8') as f:
    readme = f.read()

setup(
    name='lovebrew',
    version='0.2.7',
    author='TurtleP',
    author_email='jpostelnek@outlook.com',
    license='MIT',
    url='https://github.com/TurtleP/lovebrew',
    python_requires='>=3.8.0',
    description='Löve Potion Game Helper',
    long_description=readme,
    long_description_content_type='text/markdown',
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
