FROM ubuntu:latest

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV TZ=America/Chicago

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install curl fzf git tzdata zip unzip ninja-build gettext cmake build-essential

# Install Neovim from source.
RUN mkdir -p /root/TMP
RUN cd /root/TMP && git clone https://github.com/neovim/neovim
RUN cd /root/TMP/neovim && git checkout stable && make -j4 && make install
RUN rm -rf /root/TMP

CMD ["tail", "-f", "/dev/null"]