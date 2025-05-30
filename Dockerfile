ARG BASE_OS="ubuntu:24.04"
FROM ${BASE_OS}

ENV BASE=/home/explodejs
ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y wget curl git unzip python3 python3-pip ca-certificates gnupg libgmp-dev graphviz sudo neovim && \
    echo "/usr/local/bin" | bash -c "sh <(curl -fsSL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)" && \
    pip install --break-system-packages --upgrade setuptools

# Install Node.js
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_23.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt update \
    && apt install nodejs -y

# Install Neo4j
ENV NEO4J_HOME="/var/lib/neo4j"
# FIXME: Don't use apt-key. Follow the same approach as Node.js above
RUN wget -O - https://debian.neo4j.com/neotechnology.gpg.key | apt-key add - && \
    echo 'deb https://debian.neo4j.com stable 5' | tee -a /etc/apt/sources.list.d/neo4j.list && \
    apt-get update && \
    apt-get install -y neo4j=1:5.26.4 && \
    echo dbms.security.auth_enabled=false >> /etc/neo4j/neo4j.conf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R neo4j:neo4j /var/lib/neo4j && \
    chown -R neo4j:neo4j /var/log/neo4j && \
    chmod -R g+rw /var/lib/neo4j && \
    chmod -R g+rw /var/log/neo4j

# Configure 'explodejs' user
RUN useradd -ms /bin/bash explodejs && \
    usermod -aG neo4j explodejs && \
    echo explodejs:explodejs | chpasswd && \
    cp /etc/sudoers /etc/sudoers.bak && \
    echo "explodejs ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "umask 000" >> ${BASE}/.bash_profile && \
    echo "source ${BASE}/.bash_profile" >> ${BASE}/.bashrc && \
    chown explodejs:explodejs ${BASE}/.bash_profile && \
    chown explodejs:explodejs ${BASE}/.bashrc

USER explodejs
WORKDIR /home/explodejs

# Build graphjs and emca-sl
COPY --chown=explodejs:explodejs . /home/explodejs/explode-js

# Remove .git dirs to free some space
RUN rm -rf /home/explodejs/explode-js/.git \
    &&  rm -rf /home/explodejs/explode-js/vendor/graphjs/.git \
    &&  rm -rf /home/explodejs/explode-js/vendor/ECMA-SL/.git \
    &&  rm -rf /home/explodejs/explode-js/bench/datasets/.git \
    &&  rm -rf /home/explodejs/explode-js/bench/fast/.git \
    &&  rm -rf /home/explodejs/explode-js/bench/NodeMedic/.git

RUN cd "${BASE}/explode-js/vendor/graphjs" \
    && sudo pip install --break-system-packages -r ./requirements.txt \
    && cd ./parser && sudo npm install && npm exec tsc

RUN opam init --bare --disable-sandboxing --shell-setup -y \
    && sudo apt update \
    && opam switch create -y ecma-sl 5.3.0 \
    && eval $(opam env --switch=ecma-sl) \
    && opam update \
    && echo "eval \$(opam env --switch=ecma-sl)" >> ~/.bash_profile

RUN cd "${BASE}/explode-js/" && eval $(opam env --switch=ecma-sl) \
  && ./setup.ml --skip-graphjs

# Cleanup unavailable resources
RUN cd "${BASE}/explode-js/" && \
  rm -rf /home/explodejs/explode-js/vendor/ECMA-SL/_build/default/JS-Interpreters/{ecmaref5,ecmaref6} && \
  rm -rf /home/explodejs/explode-js/vendor/ECMA-SL/JS-Interpreters/{ecmaref5,ecmaref6}
