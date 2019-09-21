## Purpose

This project permits building Python modules and executables without a Windows VM through the use of Wine.  With this tool you can easily deploy Python wheels and py2xe executables in a reproducible (fully scripted) fashion from the comfort of your own Linux system.

## Installation

Clone this repository into a folder in/nearby your project.  Install xvfb from your Linux distribution and winehq-staging from WineHQ (https://wiki.winehq.org/Download).

## Usage

Call the build script with the project directory to build and the destination folder to place the
build artifacts, for example (from a parent folder):
```
"${PWD}"/build-python-wine/build-python-wine.sh "${PWD}"/python-pcl "${PWD}"/dist
```

Optionally, you can also provide options to setup.py.  For example, in the usual wheel building case (`python setup.py bdist_wheel`), this would become:
```
"${PWD}"/build-python-wine/build-python-wine.sh --setup-arguments "bdist_wheel" "${PWD}"/python-pcl "${PWD}"/dist
```
If no options are provided, the default is to build a wheel (bdist_wheel).

## Advanced Usage

### Callbacks

There are two "callbacks" allowed in the build process that allow customization of the build environment.  The "--install-callback" permits modification of the initial Wine prefix (cached and shared between builds) and the "--build-callback" allows modification of the custom prefix for individual builds.  Please note that modifying the install callback will force a regeneration of the cached Wine prefix, so most customizations should be placed within the build callback.

Several key environment variables are available to these callback scripts, mainly:
  * ${WINEPREFIX}: the temporary Wine prefix for performing the build
  * ${WINE}: the full path to the Wine executable used in building the prefix
  * ${CACHEDIR}: a convenient local directory for caching download files (usually "${HOME}"/.cache/build-python-wine)
  * ${PYTHON_PROJECT}: the directory containing the temporary copy of the Python project

### Python dependencies

Installing additional Python dependencies can be done by using a callback (build callbacks are easiest, since they do not regenerate the prefix).  Simply add a line to the build callback script to request that the dependency/dependencies be installed:
```
"${WINE}" conda install -y -c conda-forge ${DEPENDENCIES}
```
