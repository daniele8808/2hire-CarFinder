# To Hire · CarFinder — Demo

Prototipo dimostrativo del servizio di **wayfinding per autonoleggi**: al momento della
consegna chiavi il cliente riceve un link che lo guida sulla planimetria del parcheggio
fino allo stallo esatto della sua auto. Negli ultimi metri è l'auto stessa a farsi
trovare — lampeggiando e suonando su comando — grazie al dispositivo telematico
To Hire già installato a bordo.

## Come si usa

È un **unico file statico** (`index.html`), senza backend né dipendenze: basta aprirlo
in un browser o servirlo da qualunque hosting statico (GitHub Pages, Apache, ecc.).

| Vista | URL | Cosa fa |
|---|---|---|
| Landing | `index.html#/` | Presentazione della demo e accessi rapidi |
| Pannello operatore | `index.html#/admin` | Scegli la planimetria, posiziona il pin dell'auto e del cliente, genera il link |
| Vista cliente | `index.html#/find?d=…` | Percorso guidato passo-passo + pulsante «Trova l'auto» |

### Pannello operatore
1. Scegli una planimetria integrata (Fiumicino T3 multipiano, Ciampino P1) oppure
   carica un'immagine (es. le planimetrie ufficiali ADR esportate come PNG/JPG).
2. Compila i dati del veicolo (targa, modello, colore, stallo).
3. Clicca sulla mappa per posizionare **auto** e **cliente**. Sulle mappe integrate il
   percorso viene calcolato automaticamente lungo i corridoi (Dijkstra su un grafo dei
   camminamenti); sulla planimetria caricata si traccia a mano con i waypoint.
4. Copia il link generato: tutti i dati viaggiano codificati nell'URL, quindi la demo
   non richiede alcun server.

### Vista cliente
Mobile-first, bilingue IT/EN. Mostra scheda veicolo con targa, percorso animato sulla
mappa con indicazioni passo-passo, simulazione del cammino con camera che segue, e il
pulsante **«Trova l'auto»** che fa lampeggiare e suonare il pin dell'auto.

## Note sulla demo
- Le planimetrie integrate sono stilizzate a scopo dimostrativo.
- La posizione del cliente è simulata: nel prodotto reale arriverebbe dal GPS del
  telefono all'aperto e da beacon/BLE al chiuso.
- La posizione dell'auto, nel prodotto reale, arriva dal dispositivo telematico To Hire.
- Il comando «lampeggia e suona» è simulato: nel prodotto reale viaggia dal cloud
  To Hire al dispositivo di bordo (interfaccia CAN del veicolo).
- Le planimetrie caricate dall'admin restano nel `localStorage` del browser: il link
  cliente con mappa personalizzata funziona solo sullo stesso dispositivo. Con le mappe
  integrate il link funziona ovunque.

---
Demo realizzata da Hart Studio per To Hire.
