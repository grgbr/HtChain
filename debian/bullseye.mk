# Debian 11.x (bullseye)

DEBBINDEPS := libarchive13 libcrypt1 libcurl4 libexpat1 libfl2 \
              libgdbm-compat4 libglade2-0 libjsoncpp24 libmpdec3 \
              libncurses6 libncursesw6 libnsl2 libqt5widgets5 \
              libreadline8 librhash0 libsqlite3-0 libtk8.6 libuuid1 libuv1

DEBSRCDEPS := lsb-release \
              curl \
              gpg \
              tar gzip bzip2 xz-utils lzip \
              patch \
              rsync \
              fakeroot \
              make autoconf automake m4 libtool-bin pkg-config \
              gcc g++ gperf flex bison \
              gettext intltool \
              libncurses-dev \
              libglade2-dev \
              qtbase5-dev \
              grep sed perl m4 gawk \
              coreutils \
              bash \
              texinfo \
              help2man \
              diffutils \
              libzstd-dev \
              dejagnu tcl python3-pytest autogen \
              \
              libuv1-dev librhash-dev libjsoncpp-dev libnghttp2-dev \
              libcurlpp-dev libarchive-dev \
              python3-sphinx python3-sphinxcontrib.qthelp qhelpgenerator-qt5 \
              python3-sphinx-rtd-theme latexmk texlive-latex-recommended \
              texlive-latex-extra \
              \
              libreadline-dev \
              liblzma-dev \
              libssl-dev \
              libmpdec-dev \
              libbz2-dev \
              libgdbm-dev libgdbm-compat-dev \
              libsqlite3-dev \
              tcl-dev \
              tk-dev \
              \
              python3-full \
              re2c

DOCKIMG    := debian:bullseye-slim
