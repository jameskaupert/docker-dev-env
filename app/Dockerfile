FROM debian:stable-slim as DEV

ENV TARGET_ARCH="amd64"
ENV GO_VERSION="1.22.2"
ENV PYTHON_VERSION="3.12.2"

# install tools
RUN apt-get update \ 
&& apt-get install --no-install-recommends -y \
build-essential \
ca-certificates \
curl \
fd-find \
fzf \
git \
libbz2-dev \ 
libffi-dev \
liblzma-dev \
libncurses5-dev \ 
libreadline-dev \
libsqlite3-dev \
libssl-dev \ 
libxml2-dev \ 
libxmlsec1-dev \ 
llvm \
locales \
make \
mecab-ipadic-utf8 \ 
ripgrep \
stow \
sudo \
tar \
tk-dev \ 
unzip \
wget \
xclip \
xz-utils \ 
zip \
zlib1g-dev \ 
zsh \
&& rm -rf /var/lib/apt/lists/*

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && dpkg-reconfigure --frontend=noninteractive locales

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

ENV PATH=$PATH:/usr/local/bin/go/bin
ENV GOPATH=/home/nvim/.local/share/go
ENV PATH=$PATH:$GOPATH/bin
RUN go version

# install pyenv & python
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN set -ex \
    && curl https://pyenv.run | bash \
    && pyenv update \
    && pyenv install $PYTHON_VERSION \
    && pyenv global $PYTHON_VERSION \
    && pyenv rehash

# install rust & tools
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN cargo install watchexec-cli just