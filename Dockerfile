FROM ghcr.io/formalsec/ocaml-5.4-z3

# Install Neo4j
ENV NEO4J_HOME="/var/lib/neo4j"

# FIXME: Don't use apt-key. Follow the same approach as Node.js above
RUN wget -O - https://debian.neo4j.com/neotechnology.gpg.key | gpg --dearmor -o /usr/share/keyrings/neo4j.gpg && \
    echo 'deb [signed-by=/usr/share/keyrings/neo4j.gpg] https://debian.neo4j.com stable 5' | tee -a /etc/apt/sources.list.d/neo4j.list && \
    apt-get update && \
    apt-get install -y neo4j=1:5.26.4 && \
    echo dbms.security.auth_enabled=false >> /etc/neo4j/neo4j.conf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R neo4j:neo4j /var/lib/neo4j && \
    chown -R neo4j:neo4j /var/log/neo4j && \
    chmod -R g+rw /var/lib/neo4j && \
    chmod -R g+rw /var/log/neo4j

# Build graphjs and emca-sl
COPY . /explode-js

# Allow python to install things system-wide
RUN python3 -m pip config set global.break-system-packages true

# Install explode-js
RUN sudo apt-get update && cd /explode-js && ./scripts/setup.ml
