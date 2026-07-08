# 2hire · CarFinder — Dalla demo al prodotto

Analisi di fattibilità e proposta UX per portare la demo al livello successivo:
un sistema che permetta a **qualunque autonoleggio, in qualunque aeroporto**, di
creare il percorso banco consegna chiavi → stallo dell'auto, senza mappature
manuali per ogni cliente.

---

## 1. L'idea di partenza (e cosa ne pensiamo)

Proposta originale: l'operatore registra una volta il percorso con il telefono
(video + traccia GPS), il sistema sovrappone video/GPS alla mappa
dell'aeroporto, e negli ultimi metri il cliente vede una freccia in realtà
aumentata stile AirTag che punta all'auto.

### ✅ Registrazione del percorso da parte dell'operatore: ottima intuizione

È il modo giusto di scalare su N aeroporti senza mappare il mondo:

- Il percorso banco → parcheggio è **fisso** per ogni autonoleggio.
- Cambia solo lo **stallo finale**, che si gestisce con la griglia stalli
  (come già fa la demo).
- Quindi si registra **una volta sola** il percorso banco → ingresso
  parcheggio. Per ogni cliente non serve registrare nulla: si compone
  percorso registrato + stallo del giorno.

### ⚠️ Video usato per "sovrapporre" video+GPS+mappa: trappola tecnica

Usare il video per **localizzare** automaticamente il percorso sulla mappa
(visual SLAM / visual positioning) è tecnologia da laboratorio: i demo di
Google/Apple funzionano perché hanno anni di Street View alle spalle.
Costruirlo in proprio significa mesi di R&D con risultati fragili.

**Però il video ha valore enorme se usato diversamente**: non come sensore,
ma come **contenuto per l'utente**. Foto o brevi clip dei punti di svolta
("esci da questa porta", "gira alla colonna E3") sono la forma di wayfinding
indoor più efficace e provata che esista.

### ⚠️ GPS: funziona solo a metà — e la copertura telefonica non c'entra

Distinzione importante: **copertura telefonica ≠ posizionamento GPS**.

- Il chip GPS ha bisogno della **linea di vista con i satelliti**: il 5G
  perfetto dentro il terminal non aiuta il fix satellitare.
- Indoor il telefono ripiega su WiFi/celle: accuratezza tipica **15–40 m** —
  sufficiente per "sei nella zona arrivi", non per un turn-by-turn preciso.
- È vero che i grandi terminal sono iper-mappati (Google/Apple indoor maps) e
  che vicino alle vetrate il fix spesso arriva: quindi la strategia corretta è
  **usare la posizione quando c'è, senza mai dipenderne**.
- All'aperto (piazzali, passaggi esterni) il GPS va bene: ~3–10 m.
- Nel **multipiano** il GPS muore quasi sempre: lì servono foto, segnaletica
  stallo e il comando lampeggia&suona.

### ❌ Freccia stile AirTag: non replicabile così — ma c'è di meglio

- L'AirTag è preciso perché usa **UWB** (chip dedicato nel telefono E nel
  tag). Le auto non hanno UWB: quella precisione non è replicabile.
- Però abbiamo un asso che AirTag non ha: il **dispositivo telematico 2hire**
  conosce la posizione dell'auto e può farla **lampeggiare e suonare**.
  Per gli ultimi metri batte qualsiasi freccia AR.
- All'aperto si può comunque fare una **freccia a bussola**: GPS del telefono
  + magnetometro + posizione auto dal device 2hire. Non è AR con la camera,
  è una freccia che ruota — molto più robusta, zero dipendenze ARKit/ARCore,
  funziona anche su web.
- Un cliente con i bagagli vuole istruzioni chiare, non tenere il telefono
  alzato a inquadrare l'aeroporto: l'AR è "wow" in demo, attrito nella realtà.

---

## 2. UX consigliata

### Lato operatore — "Registra il percorso" (una volta per aeroporto/noleggio)

1. Parte dal banco, preme **Registra**.
2. Il telefono logga i **breadcrumb GPS** in automatico (tratto esterno).
3. A ogni punto di decisione tocca un bottone: **scatta una foto + istruzione
   breve** (scritta o dettata: "Uscita 4, poi a sinistra"). Copre l'indoor
   dove il GPS non è affidabile.
4. Arrivato al parcheggio, marca l'**ingresso** e definisce la **griglia
   stalli** (una volta sola).

Risultato: un "percorso" = sequenza di passi georeferenziati dove possibile,
fotografici dove serve. Salvato per (aeroporto, autonoleggio, parcheggio).

### Lato cliente

1. Riceve il **link personalizzato** (come oggi): targa, modello, stallo.
2. Guida **passo-passo con le foto reali** dei punti di svolta:
   - indoor: avanzamento manuale ("Avanti ✓") — nessuna dipendenza dalla
     posizione;
   - all'aperto: **avanzamento automatico** via GPS (soglie di prossimità sui
     breadcrumb), con fallback manuale sempre disponibile.
3. Tratto esterno: **mappa reale** (OpenStreetMap/Mapbox) con la traccia
   registrata + puntino "tu sei qui".
4. Zona parcheggio:
   - all'aperto: **freccia bussola** che punta all'auto + distanza;
   - multipiano: foto rampa/piano + numero stallo ben visibile;
   - colpo finale ovunque: **«Trova l'auto» → lampeggia e suona** (già oggi
     il differenziatore del prodotto).

Principio guida: **niente localizzazione dove non è affidabile** — lì
comandano le foto e l'auto-avanzamento manuale. La tecnologia "fancy" si
aggiunge solo dove dà valore misurabile.

---

## 3. Fattibilità dei componenti

| Componente | Fattibilità | Note |
|---|---|---|
| Recorder GPS + foto (PWA nel browser) | ✅ Alta | Geolocation API + camera input; niente app store |
| Guida passo-passo con foto | ✅ Alta | Pattern indoor più provato al mondo |
| Mappa reale + traccia outdoor | ✅ Alta | OSM/Mapbox; la traccia registrata è già georeferenziata |
| Freccia bussola verso l'auto | ✅ Media-alta | DeviceOrientation API; su iOS richiede un tap di consenso |
| Auto-avanzamento outdoor via GPS | ✅ Media | Soglie di prossimità sui breadcrumb; fallback manuale |
| Posizione indoor "opportunistica" | ⚠️ Media | WiFi/celle, 15–40 m: ok per macro-zone, mai per svolte |
| Sovrapposizione automatica video↔mappa | ❌ Bassa | Visual SLAM/VPS in proprio = R&D pesante: da evitare |
| Freccia AR con camera (ARKit/ARCore) | ⚠️ Bassa-media | Solo outdoor, solo app nativa: fase 3, se mai |

---

## 4. Roadmap proposta

### Fase 1 — Recorder + percorsi riusabili
- Vista `#/record` nella web-app: breadcrumb GPS + foto ai waypoint.
- Salvataggio percorso per (aeroporto, autonoleggio).
- Vista cliente che compone: percorso registrato + stallo + dati veicolo.
- Test reale a Fiumicino col telefono.

### Fase 2 — Navigazione attiva
- Avanzamento automatico dei passi nel tratto outdoor (prossimità GPS).
- Freccia bussola verso l'auto nella zona parcheggio all'aperto.
- Mappa reale (OSM/Mapbox) al posto delle planimetrie stilizzate per
  il tratto esterno.

### Fase 3 — Solo se i dati lo giustificano
- Posizionamento indoor assistito (beacon BLE nei punti critici).
- AR outdoor (ARCore Geospatial / ARKit GeoAnchors) dove la copertura
  Street View lo permette.

---

## 5. In sintesi

L'architettura proposta (registrazione dell'operatore → riuso per tutti i
clienti) è **quella giusta**. Le due correzioni che la rendono costruibile in
settimane invece che anni:

1. **Video come istruzioni, non come sensore**: foto dei punti di svolta al
   posto della sovrapposizione automatica video/mappa.
2. **Freccia bussola + lampeggia&suona al posto della freccia AR**: più
   robusta, funziona su web, e copre anche il multipiano dove l'AR
   fallirebbe.

---
Documento redatto durante lo sviluppo della demo — Hart Studio per 2hire.
