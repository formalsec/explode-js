ARG BASE_OS="ubuntu:22.04"
FROM ${BASE_OS}

ENV BASE=/home/explodejs
ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y python3 python3-pip curl ca-certificates gnupg wget unzip libgmp-dev opam graphviz sudo && \
    pip install --upgrade pip setuptools

# Install Node.js
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_21.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt update \
    && apt install nodejs -y

# Install Neo4j
ENV NEO4J_HOME="/var/lib/neo4j"
RUN wget -O - https://debian.neo4j.com/neotechnology.gpg.key | apt-key add - && \
    echo 'deb https://debian.neo4j.com stable 5' | tee -a /etc/apt/sources.list.d/neo4j.list && \
    apt-get update && \
    apt-get install -y neo4j=1:5.9.0 && \
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
RUN cd "${BASE}/explode-js/vendor/graphjs" && sudo ./setup.sh
RUN cd "${BASE}/explode-js/" && opam init --disable-sandboxing --shell-setup -y \
    && opam switch create -y ecma-sl 5.1.1 \
    && eval $(opam env --switch=ecma-sl) \
    && echo "eval \$(opam env --switch=ecma-sl)" >> ~/.bash_profile \
    && opam install -y vendor vendor/ECMA-SL .
