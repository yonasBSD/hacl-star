Our code relies on the following tools, which must be installed before building:

* [Python (version 3.6+)](https://www.python.org/), used by SCons
* [SCons (3.0+)](http://scons.org/), the Python-based build system used by Vale
  * On an Ubuntu system, including Windows Subsystem for Linux, you can install the Python/SCons dependencies with:
    * ```sudo apt install scons```
  * On Mac OS X (tested with El Capitan, 10.11.6), you can install the Python/SCons dependencies with:
    * ```brew install scons```
* The [Vale tool](https://github.com/project-everest/vale)
  * Download the latest [Vale binary release](https://github.com/project-everest/vale/releases) zip file
  * Set the `VALE_HOME` environment variable to the unzipped binaries directory (e.g., `VALE_HOME = vale-release-x.y.z`)
* [F*](https://github.com/FStarLang/FStar) (`master` branch),
  [KreMLin](https://github.com/FStarLang/kremlin) (`master` branch),
  and Z3 (version [4.5.1](https://github.com/FStarLang/binaries/tree/master/z3-tested))
  * Set the `FSTAR_HOME` environment variable to the F* directory (e.g., `FSTAR_HOME = FStar`)
  * Set the `KREMLIN_HOME` environment variable to the KreMLin directory (e.g., `KREMLIN_HOME = kremlin`)
  * (See the [HACL* installation guide](../INSTALL.md) for directions on installing F*, KreMLin, and Z3 and setting environment variables)
* An installed C/C++ compiler, used by SCons to compile C/C++ files

Once these tools are installed, running SCons in the `Vale` directory will
build and verify the Vale cryptographic library:
* To build all sources in the [specs](./specs) and [code](./src) directory:
  * ```python.exe scons.py```
* To build the AES-GCM assembly language files and test executable:
  * On Windows, set the `PLATFORM` environment variable to `X64`
  * ```python.exe scons.py --FSTAR-EXTRACT obj/aesgcm.asm obj/aesgcm-gcc.S obj/aesgcm-linux.S obj/aesgcm-macos.S```
  * ```python.exe scons.py --FSTAR-EXTRACT obj/TestAesGcm.exe```
* To see additional generic and Vale-specific options,
  including options to configure where to find Vale, KreMLin, F*, and Z3:
  * ```python.exe scons.py -h```
