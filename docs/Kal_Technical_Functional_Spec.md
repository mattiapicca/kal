# Kal — Technical & Functional Specification

**Versione:** v0.2  
**Data:** 2026-03-06  
**Piattaforma:** iOS-first  
**Obiettivo documento:** descrivere le funzionalità tecniche minime della v1 di Kal.

---

## 1. Scope funzionale v1

Kal deve fare solo questo:

1. **calcolare target calorico e macro giornalieri** per un obiettivo di peso
2. **analizzare un pasto da foto** per stimare calorie e macro
3. **aggiornare il consumo giornaliero** e mostrare quanto resta

Tutto il resto è fuori scope.

---

## 2. Moduli inclusi

- autenticazione
- onboarding
- profilo utente
- motore calcolo calorie e macro
- dashboard giornaliera
- acquisizione foto
- upload immagine
- analisi AI del cibo
- schermata risultato e conferma
- salvataggio meal log
- storico pasti
- paywall / subscription
- analytics base

---

## 3. Moduli esclusi

- workout
- coaching chat estesa
- grocery list
- meal plans
- wearable integrations
- social features
- advanced health data
- Android
- web platform

---

## 4. Stack suggerito

## 4.1 iOS
- Swift
- SwiftUI
- async/await
- architettura MVVM semplice

## 4.2 Backend
Per velocità:
- Supabase
  - Auth
  - Postgres
  - Storage per immagini
  - Edge Functions / API leggere

## 4.3 AI / Vision
- modello multimodale via API per analisi immagine cibo
- output strutturato JSON
- eventuale secondo passaggio di normalizzazione se necessario

## 4.4 Subscription
- RevenueCat + StoreKit

## 4.5 Analytics
- PostHog o Firebase Analytics

---

## 5. Authentication

## Requisiti
- Sign in with Apple
- eventualmente email/password
- persistenza sessione
- logout
- gestione onboarding completato / incompleto

---

## 6. Data model minimo

## 6.1 users
- id
- email opzionale
- created_at
- updated_at

## 6.2 user_profiles
- user_id
- sex
- age
- height_cm
- current_weight_kg
- goal_weight_kg
- activity_level
- deficit_mode opzionale
- calorie_target
- protein_target_g
- carbs_target_g
- fat_target_g
- onboarding_completed
- created_at
- updated_at

## 6.3 meal_logs
- id
- user_id
- eaten_at
- image_url opzionale
- estimated_title
- calories
- protein_g
- carbs_g
- fat_g
- ai_confidence opzionale
- status (pending, confirmed, edited)
- created_at
- updated_at

## 6.4 meal_items opzionale
Se vogliamo salvare il dettaglio degli ingredienti riconosciuti:
- id
- meal_log_id
- name
- estimated_quantity
- calories
- protein_g
- carbs_g
- fat_g

## 6.5 subscriptions opzionale / derivata
- user_id
- plan
- status
- trial_started_at
- expires_at

---

## 7. Onboarding & target calculation

## 7.1 Input richiesti
- sesso
- età
- altezza
- peso attuale
- peso obiettivo
- livello attività
- intensità deficit opzionale

## 7.2 Output richiesti
- calorie target giornaliere
- proteine target
- grassi target
- carboidrati target

## 7.3 Requisiti logici
- formule isolate in un modulo dedicato
- calcolo deterministico
- output sempre spiegabile
- ricalcolo quando l'utente modifica i dati

## 7.4 Funzioni tecniche
Esempi di funzioni:
- calculateBMR(profile)
- calculateTDEE(profile)
- calculateCalorieTarget(profile)
- calculateMacroTargets(profile)

---

## 8. Daily summary logic

Per ogni giorno il sistema deve calcolare:
- calorie_consumed
- protein_consumed
- carbs_consumed
- fat_consumed
- calories_remaining
- protein_remaining
- carbs_remaining
- fat_remaining

Questi valori devono essere disponibili rapidamente per la Today screen.

Possibile approccio:
- query aggregata per data locale utente
- cache locale minimale lato app

---

## 9. Food photo analysis flow

## 9.1 Flusso
1. utente scatta o carica una foto
2. immagine caricata in storage o inviata a endpoint
3. backend / edge function chiama il modello multimodale
4. il modello restituisce una stima strutturata
5. app mostra la result screen
6. utente conferma o modifica
7. meal log salvato
8. daily summary aggiornata

## 9.2 Output AI desiderato
Formato JSON rigido, ad esempio:
- estimated_title
- calories
- protein_g
- carbs_g
- fat_g
- confidence
- recognized_items array

## 9.3 Requisiti forti
- niente output testuale non strutturato
- validazione server-side del JSON
- fallback in caso di risposta incompleta
- limiti di range per evitare numeri assurdi

## 9.4 Prompting requirements
Il prompt deve chiedere al modello di:
- identificare il piatto principale
- stimare porzione visibile
- dare macro del pasto intero
- esplicitare che si tratta di stima
- evitare finta precisione assoluta

---

## 10. Confirm / edit flow

Dopo l'analisi l'utente deve poter:
- confermare i valori
- correggere manualmente calorie e macro
- cambiare titolo del pasto
- annullare

Solo dopo la conferma il log entra nel totale giornaliero definitivo.
In alternativa, lo stato può essere salvato come `pending` prima della conferma.

---

## 11. Storage immagini

## Requisiti minimi
- salvataggio sicuro
- naming consistente
- associazione al meal log
- possibilità futura di cleanup

## Considerazioni
- comprimere lato client prima upload
- limitare dimensione massima
- mantenere qualità sufficiente per analisi

---

## 12. Today screen data requirements

La schermata Today deve ricevere:
- calorie_target
- calories_consumed_today
- calories_remaining_today
- protein_target
- protein_consumed_today
- carbs_target
- carbs_consumed_today
- fat_target
- fat_consumed_today
- meals_today list

Serve un endpoint o query layer semplice che restituisca tutto in modo aggregato.

---

## 13. History requirements

Lo storico deve permettere:
- lista pasti per giorno
- apertura dettaglio singolo pasto
- eventuale eliminazione o modifica

Per la v1 basta una vista cronologica semplice.

---

## 14. Paywall logic

Possibile logica iniziale:
- onboarding gratuito
- 3 scansioni gratuite oppure trial breve
- scansioni illimitate solo premium

Requisiti:
- gate chiaro lato client
- stato subscription affidabile
- restore purchases
- gestione trial scaduto

---

## 15. Analytics plan minimo

Eventi essenziali:
- app_opened
- onboarding_started
- onboarding_completed
- target_calculated
- scan_started
- photo_uploaded
- analysis_completed
- analysis_failed
- meal_confirmed
- meal_edited
- paywall_viewed
- trial_started
- subscription_started

Metriche chiave:
- onboarding completion rate
- first scan completion rate
- scans per user
- confirm rate post analysis
- edit rate post analysis
- paywall conversion

---

## 16. Error handling

## Errori principali da gestire
- upload immagine fallito
- analisi AI timeout
- output JSON invalido
- risultato troppo incerto
- mancanza connessione
- subscription state non disponibile

## UX fallback
- retry
- insert manual values
- salva immagine e riprova
- messaggio semplice e non tecnico

---

## 17. Sicurezza e affidabilità

- non presentare mai i risultati come perfetti o medici
- limitare output estremi con controlli server-side
- loggare errori e anomalie
- proteggere immagini utente e dati profilo
- rispettare privacy e consenso

---

## 18. Roadmap tecnica v1

## Sprint 1
- auth
- onboarding
- target calculation
- schema database
- today basic

## Sprint 2
- camera / photo picker
- upload image
- AI analysis endpoint
- result screen

## Sprint 3
- confirm/edit flow
- history
- daily totals
- analytics

## Sprint 4
- paywall
- polish
- error handling
- testflight prep

---

## 19. Deliverable tecnici successivi

Dopo questo documento conviene produrre:
- schema SQL iniziale
- API / edge function spec
- JSON schema per output AI
- prompt di analisi foto
- backlog task-by-task per Cursor
- architettura cartelle iOS app
