# Kal — Project Context for ChatGPT Project

**Versione:** v0.2  
**Data:** 2026-03-06  
**Owner:** Mattia Picca  
**Progetto:** Kal  
**Dominio identificato:** usekal.app  
**Piattaforma iniziale:** iOS only  
**Metodo di sviluppo:** app costruita con Cursor, usando questo Project ChatGPT come spazio di lavoro strategico e operativo.

---

## 1. Cos'è Kal

Kal è un'app iOS-first pensata per clonare il core value di Cal AI con uno scope iniziale molto stretto.

Per ora Kal deve fare solo due cose:

1. **calcolare macro e fabbisogno calorico giornaliero** necessari per raggiungere un obiettivo di peso
2. **analizzare il cibo tramite AI da una foto** per stimare calorie e macro già consumati

Non stiamo costruendo una wellness suite.  
Non stiamo costruendo una coaching app completa.  
Non stiamo costruendo workout, meal plans, grocery list o companion esteso.

---

## 2. Obiettivo del progetto

L'obiettivo è verificare se riusciamo a costruire bene una app iOS focalizzata su questo loop semplice:

1. l'utente inserisce i suoi dati e il suo obiettivo
2. Kal calcola il target calorico e i macro giornalieri
3. l'utente fotografa i pasti
4. Kal stima calorie e macro del pasto
5. Kal aggiorna il totale giornaliero consumato
6. l'utente vede quanto gli resta per rimanere nel piano

Questo è il prodotto.

---

## 3. Scope attuale

### Incluso
- onboarding base
- raccolta dati fisici e obiettivo peso
- calcolo calorie giornaliere target
- calcolo macro target
- dashboard con consumato vs target
- acquisizione foto del cibo
- analisi AI della foto
- stima calorie e macro del pasto
- conferma o correzione utente
- storico pasti e totale giornaliero
- paywall / subscription base
- analytics prodotto base

### Escluso
- schede di allenamento
- coaching motivazionale complesso
- grocery list
- meal planning settimanale
- chat companion generalista
- integrazioni wearable
- social
- Android
- web app

---

## 4. Posizionamento

Kal è una app iOS che ti aiuta a capire:

- **quante calorie e macro devi mangiare ogni giorno**
- **quante ne hai già mangiate**, usando una foto del pasto

La promessa di prodotto è semplice:

**Scatta una foto al cibo, scopri calorie e macro del pasto, e resta dentro il tuo target giornaliero.**

---

## 5. ICP iniziale

### Utente primario
- adulti 20–40
- utenti iPhone
- obiettivo dimagrimento o controllo peso
- già interessati a calorie e macro
- vogliono ridurre l'attrito del tracking manuale

### Dolore principale
Le persone sanno che per perdere peso devono restare dentro un certo target, ma:
- non sanno calcolarlo bene
- non hanno voglia di loggare manualmente ogni alimento
- mollano quando il tracking è troppo lento

Kal riduce soprattutto l'attrito del logging.

---

## 6. Come useremo questo Project su ChatGPT

Questo Project serve per lavorare solo su Kal.

Qui useremo ChatGPT per:
- chiarire scope e priorità
- progettare UX/UI della v1
- definire specifiche tecniche
- strutturare prompt AI
- creare backlog per Cursor
- definire analytics e monetizzazione
- prendere decisioni di prodotto senza uscire fuori scope

---

## 7. Regole di progetto

### Focus estremo
Ogni discussione deve rimanere dentro le due feature core.

### Clone disciplinato
Per ora il benchmark è Cal AI.
Non dobbiamo “migliorare tutto”.
Dobbiamo riprodurre bene il loop principale.

### No feature creep
Se una feature non aiuta:
- a calcolare il target
- a stimare il cibo da foto
- a mostrare progresso giornaliero

allora è fuori scope.

### iOS only
Niente Android in questa fase.

### AI utile, non decorativa
L'AI deve servire a leggere il cibo dalla foto e a strutturare una stima credibile.

### Trasparenza
Le stime devono essere presentate come stime, con possibilità di correzione utente.

---

## 8. Core loop da validare

1. L'utente completa onboarding
2. Kal genera target calorie e macro
3. L'utente fotografa un pasto
4. Kal restituisce stima calorie e macro
5. L'utente conferma
6. Dashboard aggiornata
7. L'utente torna a tracciare il pasto successivo

---

## 9. Domande guida per tutte le chat future

Quando lavoriamo in questo Project, ogni decisione deve rispondere a una o più di queste domande:

- riduce attrito nel tracking?
- migliora la qualità percepita della stima foto?
- rende più chiaro quanto posso ancora mangiare oggi?
- migliora conversione o retention?
- è davvero necessaria per la v1?

---

## 10. Deliverable attesi

Da questo Project devono uscire:
- specifica UX/UI v1
- specifica tecnica funzionale v1
- prompt AI
- data model
- backlog implementativo per Cursor
- copy in-app essenziale
- paywall logic
- analytics plan

---

## 11. Obiettivo operativo immediato

Definire in modo molto preciso:
1. onboarding e calcolo target
2. flow foto → analisi AI → conferma
3. dashboard giornaliera
4. stack tecnico e struttura dati minima
