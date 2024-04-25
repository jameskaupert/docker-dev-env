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
FROM debian:stable-slim as DEV

ENV GO_VERSION="1.22.2"
ENV TARGET_ARCH="amd64"

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

# dotfiles management
RUN apt-get update \ 
&& apt-get install --no-install-recommends -y \
build-essential \
ca-certificates \
curl \
fd-find \
fzf \
git \
ripgrep \
stow \
sudo \
tar \
unzip \
wget \
xclip \
zip \
zsh \
&& rm -rf /var/lib/apt/lists/*

RUN cd ~ && git clone https://github.com/jameskaupert/dotfiles.git && cd dotfiles && chmod +x ./install.sh && ./install.sh
RUN chsh -s $(which zsh) 
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install nvm / node / npm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
&& export NVM_DIR="$HOME/.nvm" \
&& [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
&& [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
&& nvm install --lts \
&& node -v \
&& npm -v

# install go
RUN curl -sLo go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${TARGET_ARCH}.tar.gz" \
&& tar -C /usr/local/bin -xzf go.tar.gz \
&& rm go.tar.gz

ENV PATH=$PATH:/usr/local/bin/go/bin/
ENV GOPATH=/home/nvim/.local/share/go
ENV PATH=$PATH:$GOPATH/bin
RUN go version
