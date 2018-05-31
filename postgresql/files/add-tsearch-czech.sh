#!/bin/bash
set -e

POSTGRES_DB=${POSTGRES_DB:=$POSTGRES_USER}

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  create text search dictionary czech_ispell
    (template=ispell, dictfile=czech, afffile=czech, stopwords=czech);
    
  create text search dictionary czech_snowball
    (template=snowball, language=czech, stopwords=czech);
    

  create text search configuration czech (copy=english);

  alter text search configuration czech
    alter mapping for word, asciiword with czech_ispell, czech_snowball;
EOSQL
