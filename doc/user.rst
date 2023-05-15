About
#####

HtChain is a native host toolchain providing multiple tools allowing to build
and assemble software components.

.. important::
   
   Tools chains are meant to run onto **x86_64 GNU/Linux** hosts only.
  
motivation: long term, stable, no dependency on Linux distribution, testing
strategy, available on common debian package based distrib

.. include:: ../generated/packages.rst

Default settings
################

Toolchain default settings are described into the table below [1]_.

.. table:: Default toolchains gcc / glibc settings

   +-------------------------------+------------------------------------+
   | gcc / glibc settings          | Toolchains                         |
   +-------------+-----------------+------------------------------------+
   | Name        | GCC switch      | x86_64 GNU                         |
   +=============+=================+====================================+
   .. | ABI         | -mabi           | aapcs-linux                        |
   .. +-------------+-----------------+------------------------------------+
   .. | TLS model   | -mtls-dialect   | gnu                                |
   .. +-------------+-----------------+------------------------------------+
   .. | Arch        | -march          | armv7-a+mp+sec+simd                |
   .. +-------------+-----------------+------------------------------------+
   .. | float ABI   | -mfloat-abi     | hard                               |
   .. +-------------+-----------------+------------------------------------+
   .. | FPU         | -mfpu           | neon-vfpv3                         |
   .. +-------------+-----------------+------------------------------------+
   .. | Instruction | -mthumb / -marm | ARM  (with no interwork)           |
   .. | state       |                 |                                    |
   .. +-------------+-----------------+------------------------------------+
   .. | CPU         | -mcpu / -mtune  | cortex-a9                          |
   .. +-------------+-----------------+------------------------------------+
   .. | system tuple                  | armv7_a38x-xtchain-linux-gnueabihf |
   .. +-------------------------------+------------------------------------+


Build / install workflow
########################

Prerequisites
*************

Packages listed below are required to build and install cross toolchains onto
your development host :

* coreutils
* tar
* patch
* help2man
* gcc
* g++
* make
* autoconf
* automake
* libtool / libtool-bin
* libncurses5-dev
* git
* ssh
* pkg-config
* flex
* bison
* texinfo
* texlive / texlive-formats-extra / latexmk
* gawk
* rsync
* python3-sphinx / python3-sphinx-rtd-theme
* unzip
* fakeroot

Main Makefile comes with a *prepare* target allowing to install all required
packages (see `Build`_ section).
  
Getting help
************

From HtChain source tree root, enter :

.. code-block:: console

   $ make help

Build
*****

Building toolchain is performed out of source tree like so :

.. code-block:: console

   $ make

Install
*******

Installing toolchain is performed according to the following command :

.. code-block:: console

   $ make install

Installing striped toolchain is performed according to the following command :

.. code-block:: console

   $ make install-strip

If you want to install the toolchain into a system-wide directory, you will most
likely need root priviledge to run the above command.

Debian file
***********

Making deb file is performed according to the following command :

.. code-block:: console

   $ make debian

Install directory hierarchy
***************************

The directory hierarchy installed by the example commands above is show below.

.. code-block:: console

   $ ls -l /opt/htchain/htchain-12/
   total 68
   drwxr-xr-x 11 root root  4096 mai   13 14:30 ./
   drwxr-xr-x  3 root root  4096 mai   13 13:44 ../
   drwxr-xr-x  3 root root 12288 mai   13 15:28 bin/
   drwxr-xr-x  6 root root  4096 mai   13 14:28 etc/
   drwxr-xr-x 38 root root  4096 mai   13 15:28 include/
   drwxr-xr-x 20 root root 20480 mai   13 15:28 lib/
   drwxr-xr-x  2 root root  4096 mai   13 15:28 lib64/
   drwxr-xr-x  3 root root  4096 mai   13 15:28 libexec/
   drwxr-xr-x  2 root root  4096 mai   13 14:11 sbin/
   drwxr-xr-x 32 root root  4096 mai   13 15:28 share/
   drwxr-xr-x  4 root root  4096 mai   13 14:30 x86_64-pc-linux-gnu/

Cross distribution building
***************************

With docker, it's possible to build for other distribution. For exemple to make
debian file for ubuntu jammy use the following command :

.. code-block:: console

   $ make debian DEBDIST=jammy

.. table:: Supported distribution

   +--------------+--------------+--------------+
   | Distribution | Version      | DEBDIST      |
   +==============+==============+==============+
   | ubuntu       | bionic       | bionic       |
   +--------------+--------------+--------------+
   | ubuntu       | focal        | focal        |
   +--------------+--------------+--------------+
   | ubuntu       | jammy        | jammy        |
   +--------------+--------------+--------------+
   | debian       | bullseye     | bullseye     |
   +--------------+--------------+--------------+
   | debian       | buster       | buster       |
   +--------------+--------------+--------------+
   | kali linux   | rolling      | kali-rolling |
   +--------------+--------------+--------------+

Adding a new toolchain
######################

.. todo::
   Complete me !

TODO
####

An unordered list of futur improvements :

* alternative DESTDIR install location
* debian packaging (depends on DESTDIR support)
* additional components ??
* enable glibc libmvec support
* flex / bison
* gawk perl python2/3 cpio fakeroot bc
* make / cmake / gcc / g++ / libc6-dev ?

.. [1] gcc / glibc settings retrieved according to the command :
       :code:`gcc -Q --help=target`
