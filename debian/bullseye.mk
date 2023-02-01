# Debian 11.x (bullseye)

DEBBINDEPS := latexmk texlive-latex-extra texlive-font-utils ca-certificates

# procps: required by bmake build / check targets
# netbase: required by perl check target
# git: required by hatch-vcs check target
# ca-certificates: required by distlib check target
# latexmk: required by cmake to build documentation
# texlive-font-utils: required by doxygen to build documentation
# texlive-latex-extra: required by doxygen to build documentation
DEBSRCDEPS := lsb-release \
              curl \
              file \
              gpg \
              tar gzip bzip2 xz-utils lzip unzip \
              patch \
              diffutils \
              procps \
              rsync \
              fakeroot \
              grep sed gawk \
              make gcc g++ \
              netbase \
              git \
              ca-certificates \
              rustc \
              latexmk texlive-latex-extra texlive-font-utils

# For testing purposes
#DEBSRCDEPS += dejagnu

#DEBSRCDEPS := lsb-release \
#              curl \
#              gpg \
#              tar gzip bzip2 xz-utils lzip \
#              patch \
#              rsync \
#              fakeroot \
#              make autoconf automake m4 libtool-bin pkg-config \
#              gcc g++ gperf flex bison \
#              gettext intltool \
#              libncurses-dev \
#              libglade2-dev \
#              qtbase5-dev \
#              grep sed perl m4 gawk \
#              coreutils \
#              bash \
#              texinfo \
#              help2man \
#              diffutils \
#              libzstd-dev \
#              dejagnu tcl python3-pytest autogen \
#              \
#              libuv1-dev librhash-dev libjsoncpp-dev libnghttp2-dev \
#              libcurlpp-dev libarchive-dev \
#              python3-sphinx python3-sphinxcontrib.qthelp qhelpgenerator-qt5 \
#              python3-sphinx-rtd-theme latexmk texlive-latex-recommended \
#              texlive-latex-extra \
#              \
#              libreadline-dev \
#              liblzma-dev \
#              libssl-dev \
#              libmpdec-dev \
#              libbz2-dev \
#              libgdbm-dev libgdbm-compat-dev \
#              libsqlite3-dev \
#              tcl-dev \
#              tk-dev \
#              \
#              python3-full \
#              re2c \
#              \
#              procps

DOCKIMG    := debian:bullseye-slim
