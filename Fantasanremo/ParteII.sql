--- Progetto BD 24-25 (6CFU)
--- Numero gruppo  32
--- Nomi e matricole componenti
--Sarah Oliveri 5600355 
--Ana Maria Raducan 5797859
--Andrea Pisano 6204123

--- PARTE 2 
/* il file deve essere file SQL ... cio formato solo testo e apribili ed eseguibili in pgAdmin */

/*************************************************************************************************************************************************************************/
--1a. Schema
/*************************************************************************************************************************************************************************/ 

/* inserire qui i comandi SQL per la creazione dello schema logico della base di dati in accordo allo schema relazionale ottenuto alla fine della fase di progettazione logica, per la porzione necessaria per i punti successivi (cio le tabelle coinvolte dalle interrogazioni nel carico di lavoro, nella definizione della vista, nelle interrogazioni, in funzioni, procedure e trigger). Lo schema dovrˆ essere comprensivo dei vincoli esprimibili con check. */

DROP SCHEMA IF EXISTS fantasanremo CASCADE;
CREATE SCHEMA fantasanremo;
SET search_path TO fantasanremo;


CREATE TABLE utente (
  username           VARCHAR(50)  PRIMARY KEY,
  email              VARCHAR(100) NOT NULL UNIQUE,
  psw                VARCHAR(200) NOT NULL,
  data_nascita       DATE         NOT NULL CHECK (data_nascita <= CURRENT_DATE),
  baudi_disponibili  INTEGER      NOT NULL CHECK (baudi_disponibili BETWEEN 0 AND 100)
);


CREATE TABLE artista (
  cf                      VARCHAR(16)  PRIMARY KEY,
  nome                    VARCHAR(50)  NOT NULL,
  cognome                 VARCHAR(50)  NOT NULL,
  generi_musicali         TEXT[]       NOT NULL CHECK (array_length(generi_musicali,1) >= 1),
  partecipazioni_passate  TEXT[]       NOT NULL DEFAULT '{}'::TEXT[],
  biografia               TEXT         NOT NULL,
  provenienza             VARCHAR(100) NOT NULL,
  prezzo                  INTEGER      NOT NULL CHECK (prezzo >= 0)
);


CREATE TABLE lega (
  nome_lega VARCHAR(100) PRIMARY KEY,
  tipo      VARCHAR(10)  NOT NULL CHECK (tipo IN ('segreta','privata','pubblica')),
  creatore  VARCHAR(50)  NOT NULL
    REFERENCES utente(username) ON DELETE RESTRICT
);


CREATE TABLE squadra (
  cod_squadra       BIGSERIAL PRIMARY KEY,
  nome              VARCHAR(100) NOT NULL,
  punteggio_totale  INTEGER NOT NULL DEFAULT 0 CHECK (punteggio_totale >= 0),
  nome_lega         VARCHAR(100) NOT NULL
    REFERENCES lega(nome_lega) ON DELETE CASCADE,
  artista_cf        VARCHAR(16)
    REFERENCES artista(cf) ON DELETE RESTRICT
);


CREATE TABLE squadra_artista (
  cod_squadra BIGINT      NOT NULL REFERENCES squadra(cod_squadra) ON DELETE CASCADE,
  artista_cf  VARCHAR(16) NOT NULL REFERENCES artista(cf) ON DELETE CASCADE,
  is_capitano BOOLEAN     NOT NULL DEFAULT FALSE,
  PRIMARY KEY (cod_squadra, artista_cf)
);


CREATE TABLE iscritto (
  username  VARCHAR(50)  NOT NULL REFERENCES utente(username) ON DELETE CASCADE,
  nome_lega VARCHAR(100) NOT NULL REFERENCES lega(nome_lega) ON DELETE CASCADE,
  ruolo     VARCHAR(30)  CHECK (ruolo IN ('Amministratore','Amministratore Delegato','inAttesa')),
  PRIMARY KEY (username, nome_lega)
);


CREATE TABLE serata (
  tipo_serata   VARCHAR(30) NOT NULL,
  data          DATE        NOT NULL,
  orario_inizio TIME        NOT NULL,
  orario_fine   TIME        NOT NULL,
  CONSTRAINT pk_serata PRIMARY KEY (tipo_serata, data),
  CONSTRAINT chk_orari_serata CHECK (orario_fine > orario_inizio)
);


CREATE TABLE brano (
  id_brano     BIGSERIAL    PRIMARY KEY,
  titolo       VARCHAR(200) NOT NULL,
  autore       TEXT[]       NOT NULL CHECK (array_length(autore,1) >= 1),
  compositore  TEXT[]       NOT NULL CHECK (array_length(compositore,1) >= 1),
  durata       TIME         NOT NULL,
  genere       TEXT[]       NOT NULL CHECK (array_length(genere,1) >= 1),
  cf_artista   VARCHAR(16)  NOT NULL REFERENCES artista(cf) ON DELETE RESTRICT,
  tipo_serata  VARCHAR(30)  NOT NULL,
  data_serata  DATE         NOT NULL,
  CONSTRAINT fk_brano_serata
    FOREIGN KEY (tipo_serata, data_serata)
    REFERENCES serata(tipo_serata, data)
    ON DELETE CASCADE
);


CREATE TABLE esibizione (
  cod_esibizione BIGSERIAL PRIMARY KEY,
  tipo_serata    VARCHAR(30) NOT NULL,
  data           DATE        NOT NULL,
  orario         TIME        NOT NULL,
  CONSTRAINT fk_esibizione_serata
    FOREIGN KEY (tipo_serata, data)
    REFERENCES serata(tipo_serata, data) ON DELETE CASCADE
);


CREATE TABLE effettua (
  cf             VARCHAR(16) NOT NULL REFERENCES artista(cf) ON DELETE CASCADE,
  cod_esibizione BIGINT      NOT NULL REFERENCES esibizione(cod_esibizione) ON DELETE CASCADE,
  ordine         INTEGER     NOT NULL CHECK (ordine > 0),
  PRIMARY KEY (cf, cod_esibizione)
);


CREATE TABLE formazione (
  cod_formazione BIGSERIAL  PRIMARY KEY,
  cod_squadra    BIGINT      NOT NULL REFERENCES squadra(cod_squadra) ON DELETE CASCADE,
  tipo_serata    VARCHAR(30) NOT NULL,
  data           DATE        NOT NULL,
  titolari       VARCHAR(16)[] NOT NULL CHECK (array_length(titolari,1) = 5),
  riserve        VARCHAR(16)[] NOT NULL CHECK (array_length(riserve,1) = 2),
  capitano       VARCHAR(16)   NOT NULL,
  CONSTRAINT fk_formazione_serata
    FOREIGN KEY (tipo_serata, data) REFERENCES serata(tipo_serata, data) ON DELETE CASCADE,
  CONSTRAINT chk_capo_in_titolari CHECK (capitano = ANY(titolari))
);

/*************************************************************************************************************************************************************************/ 
--1b. Popolamento 
/*************************************************************************************************************************************************************************/ 


/* inserire qui i comandi SQL per il popolamento 'in piccolo' di tale base di dati (utile per il test dei vincoli e delle operazioni in parte 2.) */
-- UTENTI
INSERT INTO utente (username, email, psw, data_nascita, baudi_disponibili) VALUES
('mario', 'mario@example.com', 'pwd123', '1990-05-12', 50),
('anna', 'anna@example.com', 'pwd456', '1995-03-20', 80);

-- ARTISTI
INSERT INTO artista (cf, nome, cognome, generi_musicali, partecipazioni_passate, biografia, provenienza, prezzo) VALUES
('RSSMRA90A12H501X', 'Marco', 'Rossi', ARRAY['Pop'], ARRAY['2022'], 'Cantante pop', 'Roma', 50),
('BNCLRA95C60F205Y', 'Laura', 'Bianchi', ARRAY['Rock'], ARRAY[]::TEXT[], 'Cantante rock', 'Milano', 70);

-- LEGHE
INSERT INTO lega (nome_lega, tipo, creatore) VALUES
('SuperLega', 'pubblica', 'mario');

-- SQUADRE
INSERT INTO squadra (nome, punteggio_totale, nome_lega, artista_cf) VALUES
('I Vincitori', 0, 'SuperLega', 'RSSMRA90A12H501X'),
('Rockers', 0, 'SuperLega', 'BNCLRA95C60F205Y');

-- SQUADRA
INSERT INTO squadra_artista (cod_squadra, artista_cf, is_capitano) VALUES
(1, 'RSSMRA90A12H501X', TRUE),
(2, 'BNCLRA95C60F205Y', TRUE);

-- ISCRITTI
INSERT INTO iscritto (username, nome_lega, ruolo) VALUES
('mario', 'SuperLega', 'Amministratore'),
('anna', 'SuperLega', 'inAttesa');

-- SERATE
INSERT INTO serata (tipo_serata, data, orario_inizio, orario_fine) VALUES
('Qualificazioni', '2025-02-01', '20:30', '23:00'),
('Finale', '2025-02-05', '21:00', '23:30');

-- BRANI 
INSERT INTO brano (titolo, autore, compositore, durata, genere, cf_artista, tipo_serata, data_serata) VALUES
('Canzone Pop', ARRAY['Marco Rossi'], ARRAY['Marco Rossi'], '00:03:30', ARRAY['Pop'], 'RSSMRA90A12H501X', 'Qualificazioni', '2025-02-01'),
('Canzone Rock', ARRAY['Laura Bianchi'], ARRAY['Laura Bianchi'], '00:04:00', ARRAY['Rock'], 'BNCLRA95C60F205Y', 'Finale', '2025-02-05');

-- ESIBIZIONI INSERT INTO esibizione (tipo_serata, data, orario) VALUES
('Qualificazioni', '2025-02-01', '21:00'),
('Finale', '2025-02-05', '21:30');

-- EFFETTUA 
INSERT INTO effettua (cf, cod_esibizione, ordine) VALUES
('RSSMRA90A12H501X', 1, 1),
('BNCLRA95C60F205Y', 2, 1);

-- FORMAZIONI
INSERT INTO formazione (cod_squadra, tipo_serata, data, titolari, riserve, capitano) VALUES
(1, 'Qualificazioni', '2025-02-01', ARRAY['RSSMRA90A12H501X','BNCLRA95C60F205Y','X3','X4','X5'], ARRAY['R1','R2'], 'RSSMRA90A12H501X');



/*************************************************************************************************************************************************************************/ 
--2. Vista
/* Inserire qui la specifica il linguaggio naturale di una vista che si ritiene utile per visualizzare alcune informazioni aggregate di interesse per il dominio, che
include accesso ad informazioni contenute in almeno tre tabelle diverse, unÕoperazione di raggruppamento e il calcolo di almeno tre diverse informazioni aggregate       */
--Creare una vista che mostri, per ogni lega, il numero di squadre iscritte, il punteggio medio delle squadre e il prezzo totale complessivo degli artisti schierati in quelle squadre.
--Le informazioni devono essere aggregate per lega e devono provenire da almeno tre tabelle diverse:
--lega (per il nome della lega)
--squadra (per il punteggio delle squadre e l’associazione con la lega)
--squadra_artista + artista (per il prezzo degli artisti associati alle squadre)
/*************************************************************************************************************************************************************************/ 

/* inserire qui i comandi SQL per la creazione della vista corrispondente alla specifica indicata nel commento precedente */ 
CREATE OR REPLACE VIEW vista_statistiche_leghe AS
SELECT
    l.nome_lega,
    COUNT(DISTINCT s.cod_squadra) AS numero_squadre,
    ROUND(AVG(s.punteggio_totale), 2) AS punteggio_medio_squadre,
    SUM(a.prezzo) AS somma_prezzi_artisti
FROM lega l
JOIN squadra s
    ON l.nome_lega = s.nome_lega
JOIN squadra_artista sa
    ON s.cod_squadra = sa.cod_squadra
JOIN artista a
    ON sa.artista_cf = a.cf
GROUP BY l.nome_lega;

/*************************************************************************************************************************************************************************/ 
--3. Interrogazioni
/*************************************************************************************************************************************************************************/ 

/*************************************************************************************************************************************************************************/ 
/* 3a (interrogazione con operazione insiemistica)															 */
/* Inserire qui la specifica in linguaggio naturale di un'interrogazione che si ritiene significativa                                                                    */
--Elencare tutti gli artisti che o hanno partecipato alla serata “Finale” del 5 febbraio 2025 o fanno parte di squadre iscritte alla lega SuperLega*************************************************************************************************************************************************************************/ 


/* inserire qui i comandi SQL per la creazione della query corrispondente alla specifica indicata nel commento precedente */ 
-- Artisti con almeno un voto in giuria = 8
(
   
    SELECT a.cf, a.nome, a.cognome
    FROM effettua e
    JOIN esibizione es
      ON e.cod_esibizione = es.cod_esibizione
    JOIN serata se
      ON es.tipo_serata = se.tipo_serata
     AND es.data = se.data
    JOIN artista a
      ON e.cf = a.cf
    WHERE se.tipo_serata = 'Finale'
      AND se.data = '2025-02-05'
)
UNION
(
    SELECT a.cf, a.nome, a.cognome
    FROM squadra_artista sa
    JOIN squadra s
      ON sa.cod_squadra = s.cod_squadra
    JOIN lega l
      ON s.nome_lega = l.nome_lega
    JOIN artista a
      ON sa.artista_cf = a.cf
    WHERE l.nome_lega = 'SuperLega'
);



/*************************************************************************************************************************************************************************/ 
/* 3b (interrogazione di divisione)                                                                                                                                      */
/* Inserire qui la specifica in linguaggio naturale di un'interrogazione che si ritiene significativa                                                                    */
--Trovare le squadre che hanno in formazione tutti gli artisti che si sono esibiti nella serata "Finale" del 5 febbraio 2025.

/*************************************************************************************************************************************************************************/ 

/* inserire qui i comandi SQL per la creazione della query corrispondente alla specifica indicata nel commento precedente */ 
SELECT s.cod_squadra, s.nome
FROM squadra s
WHERE NOT EXISTS (
    SELECT a.cf
    FROM effettua e
    JOIN esibizione es
      ON e.cod_esibizione = es.cod_esibizione
    JOIN serata se
      ON es.tipo_serata = se.tipo_serata
     AND es.data = se.data
    JOIN artista a
      ON e.cf = a.cf
    WHERE se.tipo_serata = 'Finale'
      AND se.data = '2025-02-05'
    EXCEPT
    SELECT sa.artista_cf
    FROM squadra_artista sa
    WHERE sa.cod_squadra = s.cod_squadra
);



/*************************************************************************************************************************************************************************/ 
/* 3b (interrogazione con sottointerrogazione correlata)                                                                                                                 */
/* Inserire qui la specifica in linguaggio naturale di un'interrogazione che si ritiene significativa                                                                    */
--Per ogni squadra, mostrare il nome della squadra, il punteggio totale e il nome della lega solo se il punteggio totale della squadra è maggiore della media dei punteggi di tutte le squadre nella stessa lega.
/*************************************************************************************************************************************************************************/ 


/* inserire qui i comandi SQL per la creazione della query corrispondente alla specifica indicata nel commento precedente */ 
SELECT
    s.nome AS nome_squadra,
    s.punteggio_totale,
    l.nome_lega
FROM squadra s
JOIN lega l
  ON s.nome_lega = l.nome_lega
WHERE s.punteggio_totale >
(
    SELECT AVG(s2.punteggio_totale)
    FROM squadra s2
    WHERE s2.nome_lega = s.nome_lega
);

/*************************************************************************************************************************************************************************/ 
--4. Funzioni
/*************************************************************************************************************************************************************************/ 

/*************************************************************************************************************************************************************************/ 
/* 4a: operazione di inserimento non banale, effettuando tutti gli opportuni controlli e calcoli di dati derivati.                                                       */
/* Inserire qui la specifica in linguaggio naturale di un'operazione che si ritiene significativa                                                                        */
--Inserire un nuovo brano nel database.
--Prima di inserirlo bisogna controllare che l’artista a cui appartiene esista.
--La durata del brano viene calcolata automaticamente in base ai minuti e secondi passati come due numeri separati.
/*************************************************************************************************************************************************************************/ 
/* inserire qui i comandi SQL per la creazione della funzione corrispondente alla specifica indicata nel commento precedente */ 
DO $$
DECLARE
    v_artista_esiste BOOLEAN;
    v_durata TIME;
BEGIN
    
    SELECT EXISTS (
        SELECT 1 FROM artista WHERE cf = 'RSSMRA90A12H501X'
    ) INTO v_artista_esiste;

    IF NOT v_artista_esiste THEN
        RAISE EXCEPTION 'L''artista con CF % non esiste', 'RSSMRA90A12H501X';
    END IF;

       v_durata := make_time(0, 3, 45); -- 3 minuti e 45 secondi

    
    INSERT INTO brano (titolo, autore, compositore, durata, genere, cf_artista, tipo_serata, data_serata)
    VALUES (
        'Nuovo Brano',
        ARRAY['Marco Rossi'],
        ARRAY['Marco Rossi'],
        v_durata,
        ARRAY['Pop'],
        'RSSMRA90A12H501X',
        'Finale',
        '2025-02-05'
    );

    RAISE NOTICE 'Brano inserito correttamente';
END $$;

/*************************************************************************************************************************************************************************/ 
/* 4b: calcolo di unÕinformazione derivata rilevante e non banale, che richieda lÕaccesso a diverse tabelle e unÕaggregazione                                            */
/* Inserire qui la specifica in linguaggio naturale di un'operazione che si ritiene significativa                                                                        */
--Calcolare, per ogni lega, il punteggio medio per artista considerando tutte le squadre della lega, sommando i punteggi totali delle squadre e dividendo per il numero totale di artisti presenti in quelle squadre.
/*************************************************************************************************************************************************************************/ 


/* inserire qui i comandi SQL per la creazione della funzione corrispondente alla specifica indicata nel commento precedente */ 
SELECT
    l.nome_lega,
    ROUND(
        SUM(s.punteggio_totale)::NUMERIC / COUNT(sa.artista_cf),
        2
    ) AS punteggio_medio_per_artista
FROM lega l
JOIN squadra s
    ON l.nome_lega = s.nome_lega
JOIN squadra_artista sa
    ON s.cod_squadra = sa.cod_squadra
GROUP BY l.nome_lega;


/*************************************************************************************************************************************************************************/ 
--5. Trigger
/*************************************************************************************************************************************************************************/ 

/*************************************************************************************************************************************************************************/ 
/* 5a: trigger per la verifica di un vincolo che non sia implementabile come vincolo CHECK                                                                               */                                                                          
/* Inserire qui la specifica in linguaggio naturale di un vincolo che si ritiene significativo                                                                           */
--Impedire che un artista possa essere inserito in più di due squadre contemporaneamente.
/*************************************************************************************************************************************************************************/ 


/* inserire qui i comandi SQL per la creazione del trigger corrispondente alla specifica indicata nel commento precedente */ 
--Funzione del trigger
CREATE OR REPLACE FUNCTION check_max_due_squadre()
RETURNS TRIGGER AS $$
DECLARE
    v_count INT;
BEGIN
    -- Conta in quante squadre è già presente l'artista
    SELECT COUNT(*)
    INTO v_count
    FROM squadra_artista
    WHERE artista_cf = NEW.artista_cf;

    IF v_count >= 2 THEN
        RAISE EXCEPTION 'L''artista % è già presente in % squadre: limite massimo raggiunto',
            NEW.artista_cf, v_count;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Creazione del trigger
CREATE TRIGGER trg_check_max_due_squadre
BEFORE INSERT ON squadra_artista
FOR EACH ROW
EXECUTE FUNCTION check_max_due_squadre();

/*************************************************************************************************************************************************************************/ 
/* 5b: trigger per il mantenimento di informazione derivata o per l'implementazione di una regola di dominio                                                             */                                                                          
/* Inserire qui la specifica in linguaggio naturale del trigger                                                                                                          */
--Mantenere aggiornato automaticamente il punteggio_totale di una squadra in base alla somma dei prezzi degli artisti che la compongono.
/*************************************************************************************************************************************************************************/ 



/* inserire qui i comandi SQL per la creazione del trigger corrispondente alla specifica indicata nel commento precedente */ 
-- Funzione per aggiornare il punteggio
CREATE OR REPLACE FUNCTION aggiorna_punteggio_squadra()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE squadra
    SET punteggio_totale = (
        SELECT COALESCE(SUM(a.prezzo), 0)
        FROM squadra_artista sa
        JOIN artista a ON sa.artista_cf = a.cf
        WHERE sa.cod_squadra = NEW.cod_squadra
    )
    WHERE cod_squadra = NEW.cod_squadra;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger dopo inserimento artista nella squadra
CREATE TRIGGER trg_update_punteggio_after_insert
AFTER INSERT ON squadra_artista
FOR EACH ROW
EXECUTE FUNCTION aggiorna_punteggio_squadra();

-- Trigger dopo rimozione artista dalla squadra
CREATE TRIGGER trg_update_punteggio_after_delete
AFTER DELETE ON squadra_artista
FOR EACH ROW
EXECUTE FUNCTION aggiorna_punteggio_squadra();