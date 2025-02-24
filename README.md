# yorick_setup

My full personal setup for the Yorick programming language. I use this setup
to be able to run the [MiRA](https://github.com/emmt/MiRA) and [PNDRS](http://www-static-2019.jmmc.fr/data_processing_pionier.htm)
software packages for optical interferometry image reconstruction and data reduction.

Note that this directory contains shared objects compiled against Ubuntu 22.04.5 with an x86-64
CPU architecture. I picked [GCC](https://gcc.gnu.org/) for any compilation steps for which
the compiler could be chosen. This setup might thus work out of the box for you if
you have a similar system. In this case you need only clone this directory into some
superdirectory of your choice `$YORICK_SUPDIR`. After that, add `$YORICK_SUPDIR/bin/`
and `$YORICK_SUPDIR/yorick/bin/` to your path in your `.bashrc` file.

You might still have to install the necessary NFFT C library for MiRA called [nfft3](https://github.com/NFFT/nfft).
On Debian-like systems like Ubuntu this is simply done using `sudo apt install libnfft3-dev`.

