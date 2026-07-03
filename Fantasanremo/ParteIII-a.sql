--- Progetto BD 24-25 (12 CFU)
--- Numero gruppo  32
--- Nomi e matricole componenti
--Sarah Oliveri 5600355 
--Ana Maria Raducan 5797859
--Andrea Pisano 6204123


--- PARTE III 
/* il file deve essere file SQL ... cio� formato solo testo e apribili ed eseguibili in pgAdmin */



/*************************************************************************************************************************************************************************/ 
--1b. Schema per popolamento in the large
/*************************************************************************************************************************************************************************/ 


/* per ogni relazione R coinvolta nel carico di lavoro, inserire qui i comandi SQL per creare una nuova relazione R_CL con schema equivalente a R ma senza vincoli di chiave primaria, secondaria o esterna e con eventuali attributi dummy */


CREATE SCHEMA IF NOT EXISTS fantasanremo_cl;
SET search_path TO fantasanremo_cl;

-- UTENTE
CREATE UNLOGGED TABLE IF NOT EXISTS utente_cl (
  LIKE fantasanremo.utente INCLUDING DEFAULTS,
  dummy_note TEXT,
  dummy_batch_id BIGINT,
  dummy_loaded_at TIMESTAMP DEFAULT now()
);

-- ARTISTA
CREATE UNLOGGED TABLE IF NOT EXISTS artista_cl (
  LIKE fantasanremo.artista INCLUDING DEFAULTS,
  dummy_note TEXT,
  dummy_batch_id BIGINT,
  dummy_loaded_at TIMESTAMP DEFAULT now()
);

-- LEGA
CREATE UNLOGGED TABLE IF NOT EXISTS lega_cl (
  LIKE fantasanremo.lega INCLUDING DEFAULTS,
  dummy_note TEXT,
  dummy_batch_id BIGINT,
  dummy_loaded_at TIMESTAMP DEFAULT now()
);

-- SQUADRA
CREATE UNLOGGED TABLE IF NOT EXISTS squadra_cl (
  LIKE fantasanremo.squadra INCLUDING DEFAULTS,
  dummy_note TEXT,
  dummy_batch_id BIGINT,
  dummy_loaded_at TIMESTAMP DEFAULT now()
);

-- SQUADRA_ARTISTA
CREATE UNLOGGED TABLE IF NOT EXISTS squadra_artista_cl (
  LIKE fantasanremo.squadra_artista INCLUDING DEFAULTS,
  dummy_note TEXT,
  dummy_batch_id BIGINT,
  dummy_loaded_at TIMESTAMP DEFAULT now()
);

-- ISCRITTO
CREATE UNLOGGED TABLE IF NOT EXISTS iscritto_cl (
  LIKE fantasanremo.iscritto INCLUDING DEFAULTS,
  dummy_note TEXT,
  dummy_batch_id BIGINT,
  dummy_loaded_at TIMESTAMP DEFAULT now()
);

-- SERATA
CREATE UNLOGGED TABLE IF NOT EXISTS serata_cl (
  LIKE fantasanremo.serata INCLUDING DEFAULTS,
  dummy_note TEXT,
  dummy_batch_id BIGINT,
  dummy_loaded_at TIMESTAMP DEFAULT now()
);

-- BRANO
CREATE UNLOGGED TABLE IF NOT EXISTS brano_cl (
  LIKE fantasanremo.brano INCLUDING DEFAULTS,
  dummy_note TEXT,
  dummy_batch_id BIGINT,
  dummy_loaded_at TIMESTAMP DEFAULT now()
);

-- ESIBIZIONE
CREATE UNLOGGED TABLE IF NOT EXISTS esibizione_cl (
  LIKE fantasanremo.esibizione INCLUDING DEFAULTS,
  dummy_note TEXT,
  dummy_batch_id BIGINT,
  dummy_loaded_at TIMESTAMP DEFAULT now()
);

-- EFFETTUA
CREATE UNLOGGED TABLE IF NOT EXISTS effettua_cl (
  LIKE fantasanremo.effettua INCLUDING DEFAULTS,
  dummy_note TEXT,
  dummy_batch_id BIGINT,
  dummy_loaded_at TIMESTAMP DEFAULT now()
);

-- FORMAZIONE
CREATE UNLOGGED TABLE IF NOT EXISTS formazione_cl (
  LIKE fantasanremo.formazione INCLUDING DEFAULTS,
  dummy_note TEXT,
  dummy_batch_id BIGINT,
  dummy_loaded_at TIMESTAMP DEFAULT now()
);
 

/*************************************************************************************************************************************************************************/
--1c. Carico di lavoro
/*************************************************************************************************************************************************************************/ 


/*************************************************************************************************************************************************************************/ 
/* Q1: Query con singola selezione e nessun join */
/*************************************************************************************************************************************************************************/ 


/* inserire qui i comandi SQL per la creazione della query, in modo da visualizzarne piane di esecuzione e tempi di esecuzione */ 
--I 10 artisti pi� costosi (prezzo = 50), ordinati dal pi� caro al meno caro e per ciascuno si restituisce CF, nome, cognome e prezzo. 
-- Piano con esecuzione e tempi reali:
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT cf, nome, cognome, prezzo
FROM artista
WHERE prezzo >= 50
ORDER BY prezzo DESC
LIMIT 10;


/*************************************************************************************************************************************************************************/ 
/* Q2: Query con condizione di selezione complessa e nessun join */
/*************************************************************************************************************************************************************************/ 


/* inserire qui i comandi SQL per la creazione della query, in modo da visualizzarne piane di esecuzione e tempi di esecuzion */ 
-- Mostra artisti con prezzo > 50 oppure con almeno 2 generi musicali escludendo quelli la cui provenienza � 'Roma'
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT cf, nome, cognome, prezzo, generi_musicali, provenienza
FROM artista
WHERE
    (
        prezzo > 50
        OR array_length(generi_musicali, 1) >= 2
    )
    AND NOT (provenienza = 'Roma')
    AND nome LIKE 'M%';

/*************************************************************************************************************************************************************************/ 
/* Q3: Query con almeno un join e almeno una condizione di selezione */
/*************************************************************************************************************************************************************************/ 


/* inserire qui i comandi SQL per la creazione della query, in modo da visualizzarne piane di esecuzione e tempi di esecuzione */ 
-- Mostra tutte le squadre con il nome della lega e dell'artista capitano
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT
    s.cod_squadra,
    s.nome AS nome_squadra,
    l.nome_lega,
    a.nome AS nome_artista,
    a.cognome AS cognome_artista,
    s.punteggio_totale
FROM squadra s
JOIN lega l
    ON s.nome_lega = l.nome_lega
JOIN artista a
    ON s.artista_cf = a.cf
WHERE s.punteggio_totale > 100
ORDER BY s.punteggio_totale DESC;




/*************************************************************************************************************************************************************************/
--1e. Schema fisico
/*************************************************************************************************************************************************************************/ 


/* inserire qui i comandi SQL per cancellare tutti gli indici gi� esistenti per le tabelle coinvolte nel carico di lavoro */
DO $$
DECLARE r RECORD;
BEGIN
  FOR r IN
    SELECT i.relname AS idx, n.nspname AS sch
    FROM pg_class t
    JOIN pg_namespace n ON n.oid = t.relnamespace
    JOIN pg_index ix     ON ix.indrelid = t.oid
    JOIN pg_class i      ON i.oid = ix.indexrelid
    WHERE n.nspname = 'fantasanremo'
      AND t.relname IN ('artista','squadra','lega')
      AND ix.indisprimary = FALSE
      AND ix.indisunique  = FALSE
      AND NOT EXISTS (SELECT 1 FROM pg_constraint c WHERE c.conindid = i.oid)
  LOOP
    EXECUTE format('DROP INDEX IF EXISTS %I.%I;', r.sch, r.idx);
  END LOOP;
END $$;

/* inserire qui i comandi SQL perla creazione dello schema fisico della base di dati in accordo al risultato della fase di progettazione fisica per il carico di lavoro. */
/**************************************************************************************************
-- 1e. Schema fisico (versione minimale: non avevo indici extra da cancellare)
-- Creo gli indici decisi in 1d e aggiorno le statistiche.
**************************************************************************************************/

CREATE INDEX IF NOT EXISTS ix_artista_prezzo_desc
  ON fantasanremo.artista (prezzo DESC);

CREATE INDEX IF NOT EXISTS ix_artista_lower_nome_pat
  ON fantasanremo.artista (lower(nome) text_pattern_ops);

CREATE INDEX IF NOT EXISTS ix_squadra_punteggio_desc
  ON fantasanremo.squadra (punteggio_totale DESC);

ANALYZE fantasanremo.artista;
ANALYZE fantasanremo.squadra;


/*************************************************************************************************************************************************************************/ 
--2. Controllo dell'accesso 
/*************************************************************************************************************************************************************************/ 

/* inserire qui i comandi SQL per la definizione della politica di controllo dell'accesso della base di dati  
(definizione ruoli, gerarchia, definizione utenti, assegnazione privilegi) in modo che, dopo l'esecuzione di questi comandi, 
le operazioni corrispondenti ai privilegi delegati ai ruoli e agli utenti sia correttamente eseguibili. */

--non � stato testato 

-- ruoli 
CREATE ROLE r_utente_premium       NOLOGIN INHERIT;
CREATE ROLE r_amministratore_lega  NOLOGIN INHERIT;
CREATE ROLE r_proprietario_lega    NOLOGIN INHERIT;
CREATE ROLE r_admin_fantasanremo   NOLOGIN INHERIT;

-- gerarchia
GRANT r_utente_premium      TO r_amministratore_lega;
GRANT r_amministratore_lega TO r_proprietario_lega;
GRANT r_proprietario_lega   TO r_admin_fantasanremo;

-- accesso schema e lettura base
GRANT USAGE ON SCHEMA fantasanremo TO
  r_utente_premium, r_amministratore_lega, r_proprietario_lega, r_admin_fantasanremo;

GRANT SELECT ON ALL TABLES IN SCHEMA fantasanremo TO
  r_utente_premium, r_amministratore_lega, r_proprietario_lega, r_admin_fantasanremo;

-- scritture 
GRANT INSERT ON TABLE
  squadra, squadra_artista, formazione, iscritto
TO r_utente_premium;

GRANT INSERT, UPDATE, DELETE ON TABLE
  squadra, squadra_artista, formazione, iscritto
TO r_amministratore_lega;

GRANT INSERT, UPDATE, DELETE ON TABLE
  lega
TO r_proprietario_lega;

-- admin
GRANT ALL PRIVILEGES ON ALL TABLES    IN SCHEMA fantasanremo TO r_admin_fantasanremo;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA fantasanremo TO r_admin_fantasanremo;
GRANT CREATE ON SCHEMA fantasanremo TO r_admin_fantasanremo;






