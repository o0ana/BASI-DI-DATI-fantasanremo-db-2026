# FantaSanremo DB

Progetto di Basi di Dati (12 CFU) — Università di Genova, DIBRIS.

Realizzazione di una base di dati relazionale in PostgreSQL per la gestione
del gioco FantaSanremo (squadre, artisti, bonus/malus, classifiche).

## Dominio e regolamento di riferimento

Lo schema è stato progettato sulla base del regolamento ufficiale FantaSanremo 2025:
https://fantasanremo.com/regolamento

In breve: ogni utente crea una squadra di 7 artisti (5 titolari + 2 riserve) con 100 baudi
a disposizione, nomina un capitano, e durante le 5 serate del Festival gli artisti
guadagnano o perdono punti in base a bonus e malus. Vince chi totalizza più punti.

## Cosa chiedeva la consegna

Il progetto (assegnato dal corso di Basi di Dati) richiedeva tre parti:

1. **Progettazione logica** — schema E-R, schema logico, normalizzazione (BCNF/3FN)
2. **Realizzazione** — schema in PostgreSQL con vincoli, popolamento, una vista,
   tre query (con operazione insiemistica, divisione, sotto-query correlata),
   due funzioni/procedure e due trigger
3. **Progettazione fisica e controllo accessi** — carico di lavoro, indici, analisi
   dei piani di esecuzione prima/dopo l'ottimizzazione, definizione di ruoli e privilegi

## Struttura del progetto

- `docs/ParteI.pdf` — Progettazione logica: schema E-R, schema logico, normalizzazione
- `docs/ParteIII.pdf` — Progettazione fisica, ottimizzazione query, controllo degli accessi
- `sql/ParteII.sql` — Schema, popolamento, viste, query, funzioni e trigger
- `sql/ParteIII-a.sql` — Schema fisico e analisi dei piani di esecuzione
- `sql/ParteIII-b.sql` — Inserimento dati su larga scala

## Tecnologie

- PostgreSQL
- IntelliJ (sviluppo e gestione del database)
