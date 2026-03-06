# Kal — UX/UI Specification

**Versione:** v0.2  
**Data:** 2026-03-06  
**Piattaforma:** iOS  
**Obiettivo documento:** definire UX e schermate della v1 di Kal con scope strettissimo.

---

## 1. Obiettivo UX

Kal deve far percepire tre cose immediate:

1. **so quante calorie e macro devo mangiare**
2. **posso tracciare un pasto in pochi secondi**
3. **capisco subito quanto mi resta oggi**

La UX deve ruotare tutta attorno a questo.

---

## 2. Principi UX

### Ridurre attrito
Il tracking deve essere più veloce del logging manuale tradizionale.

### Chiarezza
L'utente deve capire sempre:
- target del giorno
- consumato
- rimanente

### Fiducia
L'analisi foto deve sembrare seria, leggibile e correggibile.

### Scope pulito
Nessuna schermata inutile o dispersiva.

---

## 3. Architettura app proposta

### Tab bar minima
- **Today**
- **Scan**
- **History**
- **Profile**

Questa struttura è sufficiente per la v1.

---

## 4. User journey principale

### Fase 1 — Onboarding
L'utente inserisce i dati necessari per calcolare il target.

### Fase 2 — First value
Kal mostra calorie e macro giornalieri target.

### Fase 3 — Primo scan
L'utente scatta o carica una foto di un pasto.

### Fase 4 — Analisi
Kal mostra la stima del pasto.

### Fase 5 — Conferma
L'utente conferma o corregge.

### Fase 6 — Dashboard aggiornata
L'utente vede il totale consumato e quanto gli resta.

---

## 5. Onboarding UX

## 5.1 Dati necessari
- sesso
- età
- altezza
- peso attuale
- peso obiettivo
- velocità desiderata o aggressività del deficit opzionale
- livello di attività

## 5.2 Flow consigliato
1. Welcome screen
2. Goal selection
3. Physical data
4. Activity level
5. Calcolo in corso
6. Risultato iniziale
7. Entrata in app

## 5.3 Output onboarding
Alla fine l'utente deve vedere:
- calorie target giornaliere
- proteine target
- grassi target
- carboidrati target

## 5.4 Tone of voice
- semplice
- sicuro
- non medico
- non giudicante

---

## 6. Today screen

## 6.1 Ruolo
È la schermata più importante.

## 6.2 Blocchi principali
### Header
- saluto
- data

### Daily target card
- calorie target
- calorie consumate
- calorie rimanenti

### Macro progress
- proteine
- carboidrati
- grassi

### Quick action
- pulsante principale “Scansiona pasto”

### Meals today
- lista dei pasti già aggiunti oggi
- calorie e macro sintetici per ciascun pasto

## 6.3 Obiettivo UX
In meno di 3 secondi l'utente deve capire:
- qual è il suo budget oggi
- quanto ha già consumato
- quanto gli resta

---

## 7. Scan flow UX

## 7.1 Entry points
- tab Scan
- CTA dalla Today screen

## 7.2 Flow
1. apertura camera / picker foto
2. scatto o selezione immagine
3. loading analysis
4. schermata risultato
5. conferma o modifica
6. salvataggio
7. ritorno alla Today aggiornata

## 7.3 Requisiti UX
- caricamento percepito rapido
- feedback chiaro durante analisi
- immagine visibile anche nel risultato
- componenti facilmente modificabili

---

## 8. Result screen post-analysis

## 8.1 Cosa mostra
- preview foto
- nome stimato del piatto
- calorie stimate
- proteine
- carboidrati
- grassi
- eventuale lista componenti riconosciuti

## 8.2 Azioni
- conferma
- modifica manuale
- annulla

## 8.3 Fiducia UX
La schermata deve comunicare:
- “questa è una stima”
- “puoi correggerla”
- “hai il controllo finale”

---

## 9. History screen

## 9.1 Contenuto
- lista pasti salvati
- raggruppamento per giorno
- totale giornaliero
- accesso al dettaglio singolo pasto

## 9.2 Obiettivo
Dare all'utente memoria e controllo, senza complicare la v1 con analytics avanzati.

---

## 10. Profile screen

## 10.1 Contenuti
- dati fisici
- obiettivo peso
- attività
- calorie target
- macro target
- subscription
- settings

## 10.2 Funzioni
- modifica dati
- ricalcolo target
- gestione abbonamento

---

## 11. Paywall UX

## 11.1 Possibile logica v1
- onboarding gratuito
- prima esperienza gratuita
- numero limitato di scansioni free
- paywall per scansioni illimitate e tracking continuo

## 11.2 Messaggio principale
Il valore da comunicare è:
- tracking più veloce
- stima immediata da foto
- controllo quotidiano semplice

---

## 12. Stati vuoti

### Today senza pasti
- spiegare che non è stato ancora registrato nulla
- CTA forte verso scan

### History vuota
- invitare a fare la prima scansione

### Nessun target ancora disponibile
- rimandare a completamento profilo

---

## 13. Error states

### Analisi fallita
Messaggio chiaro:
- non siamo riusciti a leggere bene il pasto
- riprova con una foto più chiara
- oppure inserisci a mano

### Foto poco leggibile
Suggerire:
- luce migliore
- inquadratura più vicina
- piatto più centrato

---

## 14. Priorità design v1

Ordine consigliato:
1. onboarding
2. today
3. scan camera / upload
4. result screen
5. history
6. profile
7. paywall

---

## 15. Deliverable UX/UI successivi

- wireframe low fidelity
- user flow dettagliati
- design system base
- copy schermate
- stati errore e loading
- specifiche handoff per sviluppo
