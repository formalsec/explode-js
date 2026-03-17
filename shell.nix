{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python313
    python313Packages.pip
    python313Packages.virtualenv
    neo4j
    nodejs_24
    zstd
    gmp
    sqlite
    ncurses
  ];

  shellHook = ''
    export NEO4J_HOME=$PWD/.neo4j

    # Force Neo4j to use the local project folder for everything
    export NEO4J_CONF=$NEO4J_HOME/conf
    export NEO4J_DATA=$NEO4J_HOME/data
    export NEO4J_LOGS=$NEO4J_HOME/logs
    export NEO4J_PLUGINS=$NEO4J_HOME/plugins
    export NEO4J_IMPORT=$NEO4J_HOME/import
    export NEO4J_RUN=$NEO4J_HOME/run

    # Create all necessary directories
    mkdir -p $NEO4J_HOME/{data,logs,conf,plugins,import,run}

    if [ ! -f $NEO4J_HOME/conf/neo4j.conf ]; then
      # Use the absolute path from the nix package
      cp -r ${pkgs.neo4j}/share/neo4j/conf/* $NEO4J_HOME/conf/
      chmod +w $NEO4J_HOME/conf/neo4j.conf
      echo "dbms.security.auth_enabled=false" >> $NEO4J_HOME/conf/neo4j.conf

      # Optional: Hardcode paths into the config file as a fallback
      echo "server.directories.data=$NEO4J_DATA" >> $NEO4J_HOME/conf/neo4j.conf
      echo "server.directories.logs=$NEO4J_LOGS" >> $NEO4J_HOME/conf/neo4j.conf
    fi

    if [ ! -d .venv ]; then
      virtualenv .venv
    fi
    source .venv/bin/activate

    echo "Neo4j environment localized to $NEO4J_HOME"
  '';
}
