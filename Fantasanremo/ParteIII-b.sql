--- Progetto BD 24-25 (12 CFU)
--- Numero gruppo  32
--- Nomi e matricole componenti
--Sarah Oliveri 5600355 
--Ana Maria Raducan 5797859
--Andrea Pisano 6204123


--- PARTE III 
/* il file deve essere file SQL ... cio� formato solo testo e apribili ed eseguibili in pgAdmin */

/*************************************************************************************************************************************************************************/ 
--1f. Popolamento in the large
/*************************************************************************************************************************************************************************/ 


/* inserire qui i comandi SQL per il popolamento 'in the large' delle relazioni coinvolte nel carico di lavoro  */

-- ARTISTA (3.000 righe) 
INSERT INTO fantasanremo.artista (cf, nome, cognome, generi_musicali, biografia, provenienza, prezzo)
SELECT
  'CF' || g,                
  'Nome' || g,
  'Cognome' || g,
  ARRAY['Pop'],
  'Bio ' || g,
  'Roma',
  (g % 101)                 
FROM generate_series(1, 3000) g
ON CONFLICT (cf) DO NOTHING;

-- LEGA (200 righe) 
INSERT INTO fantasanremo.lega (nome_lega, tipo, creatore)
SELECT
  'Lega_' || g,
  'pubblica',
  'mario'
FROM generate_series(1, 200) g
ON CONFLICT (nome_lega) DO NOTHING;

-- SQUADRA (2.000 righe) 
INSERT INTO fantasanremo.squadra (nome, punteggio_totale, nome_lega, artista_cf)
SELECT
  'Squadra_' || g,
  (g % 2001),                              
  'Lega_' || (((g-1) % 200) + 1),
  'CF' || (((g-1) % 3000) + 1)
FROM generate_series(1, 2000) g;

-- Aggiorna statistiche
ANALYZE fantasanremo.artista;
ANALYZE fantasanremo.squadra;

