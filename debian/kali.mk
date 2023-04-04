# Kali rolling

DEBBINDEPS := latexmk texlive-latex-extra texlive-font-utils ca-certificates \
              graphviz 

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

DOCKIMG    := kalilinux/kali-rolling
