# builder image for nvim install only
FROM debian:stable-slim as builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \ 
&& apt-get install --no-install-recommends -y \
ca-certificates \
cmake \
curl \
fzf \
g++ \
gettext \
git \
make \
ninja-build \
ripgrep \
tzdata \
unzip \
zip

# install nvim from source
RUN mkdir -p /root/TMP
RUN cd /root/TMP && git clone https://github.com/neovim/neovim
RUN cd /root/TMP/neovim && git checkout stable && make CMAKE_BUILD_TYPE=RelWithDebInfo && make install
RUN rm -rf /root/TMP

# build final image without build deps
FROM debian:stable-slim

# set locale so :checkhealth is happy
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

RUN apt-get update \
&& apt-get install --no-install-recommends -y \
locales \
&& sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && dpkg-reconfigure --frontend=noninteractive locales \
&& rm -rf /var/lib/apt/lists/*

# copy nvim from builder image
RUN mkdir -p /usr/local/share/nvim
COPY --from=builder /usr/local/bin/nvim /usr/local/bin
COPY --from=builder /usr/local/lib/nvim /usr/local/lib
COPY --from=builder /usr/local/share/nvim/ /usr/local/share/nvim

# set up dummy init.lua file until dotfiles are set up
COPY init.lua  /root/.config/nvim/init.lua

ENTRYPOINT ["/bin/bash", "-c", "nvim"]