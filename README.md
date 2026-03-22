# 🏆 Masterclass MQL5 :  Bot de Scalping Or (XAUUSD) M1

## 🔥 Vous n'avez pas le temps d'apprendre le MQL5 ?

Avant de plonger dans les centaines de lignes de code de ce tutoriel, sachez qu'il existe une voie beaucoup plus rapide si votre objectif est d'avoir un robot fonctionnel *aujourd'hui* :

### 👉 [**EA Creator : Le Générateur d'EA Sans Coder**](https://autoea.online/generate) 👈

- ✅ **Création Visuelle** : Assemblez vos conditions sans taper une ligne de code.
- ✅ **Sécurités Prop Firm Incluses** : Filtre de News, Daily Drawdown, Trailing Stop.
- ✅ **Livraison Instantanée** : Votre `.ex5` compilé et prêt à trader en 2 minutes.

> 🌐 **Testez gratuitement sur :** [https://autoea.online](https://autoea.online)

---

[![MetaTrader 5](https://img.shields.io/badge/MetaTrader_5-Expert_Advisor-blue?style=for-the-badge)](https://www.metatrader5.com)
[![MQL5](https://img.shields.io/badge/MQL5-Language-orange?style=for-the-badge)](https://www.mql5.com/fr/docs)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

> 💡 **Le Guide Définitif** : Le scalping de l'Or (XAUUSD) en M1 (1 minute) est le Saint Graal des traders algorithmiques. Mais 95% des robots échouent. Pourquoi ? Pcq'ils manquent de structure, de gestion des risques adaptative et de filtres logiques stricts. 
>
> Ce tutoriel n'est pas un simple script "copier-coller". C'est une **véritable Masterclass** de programmation MQL5. Nous allons déconstruire la création d'un Expert Advisor professionnel en utilisant une architecture par "Briques" (Modules). Ce dépôt Github est votre bible pour comprendre comment coder un bot de qualité Prop Firm.

---

## 📖 Sommaire Détaillé de la Masterclass

1. [Le Cauchemar du XAUUSD : Pourquoi l'Or est Différent](#1-le-cauchemar-du-xauusd--pourquoi-lor-est-différent)
2. [L'Architecture Professionnelle : La Méthode des Briques](#2-larchitecture-professionnelle--la-méthode-des-briques)
3. [Disséquer la Brique 1 : Le LotManager Sûreté Maximum](#3-disséquer-la-brique-1--le-lotmanager-sûreté-maximum)
    - *La différence vitale entre Balance et Equity*
    - *La mathématique occulte du Tick Value*
4. [Disséquer la Brique 2 : Le Sniper M1 (EMA + RSI)](#4-disséquer-la-brique-2--le-sniper-m1-ema--rsi)
    - *Pourquoi filtrer la tendance en scalping ?*
    - *Le piège de la bougie zéro [0] expliqué*
5. [Disséquer la Brique 3 : Le Kill Switch Prop Firm](#5-disséquer-la-brique-3--le-kill-switch-prop-firm)
    - *Comprendre le Max Daily Drawdown*
    - *La boucle de suppression inversée (L'astuce anti-crash MT5)*
6. [L'Assembleur : Analyse d'une structure OnTick Parfaite](#6-lassembleur--analyse-dune-structure-ontick-parfaite)
7. [Foire Aux Questions (FAQ) MQL5 & Scalping Or](#7-foire-aux-questions-faq-mql5--scalping-or)

---

## 1. Le Cauchemar du XAUUSD : Pourquoi l'Or est Différent

L'Or n'est pas une paire Forex comme l'EURUSD. L'EURUSD est lourd, liquide, et bouge généralement doucement. 
L'Or (XAUUSD) est explosif. Un "spike" (une bougie géante soudaine) déclenché par une annonce de la FED peut traverser 50 pips (500 points) en 2 secondes.

### Les défis du codeur :
- **Le Slippage :** Si votre code n'est pas optimisé, votre Stop Loss sera déclenché bien plus loin que prévu, ruinant votre ratio Risk/Reward.
- **La valeur du point :** Un lot (1.00) sur l'EURUSD vaut 10$ le pip. Sur l'Or, selon que votre broker propose des contrats de 100 onces ou de 10 onces, la valeur change dramatiquement. Votre code **doit** s'adapter automatiquement.
- **Le bruit du M1 :** Le graphique 1 minute est rempli de faux mouvements causés par les algorithmes Haute Fréquence des banques. Un bot qui trade chaque croisement de ligne sera ruiné en 2 heures.

C'est pour cela que ce tutoriel utilise des garde-fous stricts.

---

## 2. L'Architecture Professionnelle : La Méthode des Briques

Oubliez les tutoriels YouTube qui vous font écrire 2000 lignes dans un seul immense fichier `Bot.mq5`. Les professionnels utilisent l'inclusion de fichiers `.mqh`.

### Pourquoi modulariser son code ?
1. **Lisibilité :** Quand vous cherchez un bug de calcul de lot, vous ne voulez pas scroller à travers 800 lignes de conditions de trading. Vous ouvrez simplement `LotManager.mqh`.
2. **Réutilisabilité :** Demain, vous voulez coder un bot sur le Bitcoin (BTCUSD). Vous n'aurez qu'à copier/coller votre fichier `LotManager.mqh` hyper robuste. Vous venez d'économiser 2h de code.
3. **Compilation plus sûre :** MQL5 compile les briques de manière très propre. 

Voici l'arborescence que ce dépôt Git utilise, et que vous devriez toujours utiliser :
```text
📦 Projet-Scalper-Or/
 ┣ 📂 Experts/
 ┃ ┗ 📜 GoldScalper.mq5          (Le fichier principal que l'on glisse sur le graphique)
 ┗ 📂 Include/                   (Le coffre-fort des modules, invisible sur le graph)
   ┣ 📜 LotManager.mqh           (100% dédié aux mathématiques du capital)
   ┣ 📜 EntryConditions.mqh      (100% dédié aux indicateurs et signaux)
   ┗ 📜 RiskManagement.mqh       (100% dédié à la fermeture d'urgence Prop Firm)
```

---

## 3. Disséquer la Brique 1 : Le LotManager Sûreté Maximum

*Fichier de référence : `Include/LotManager.mqh`*

Ne mettez **jamais** en paramètre `input double LotSize = 0.10;`. C'est l'erreur du débutant absolu. Si votre compte gagne de l'argent et passe de 10 000$ à 20 000$, 0.10 représentera un risque deux fois moindre. Votre croissance sera bloquée. De même en cas de perte, votre risque grandira dangereusement.

L'objectif de cette brique est de dire à la machine : *"Je veux risquer exactement 1% de mon capital total sur ce trade. Trouve la taille de lot exacte, que je sois chez FTMO, IC Markets ou TickMill."*

### Explication du code MQL5 Étape par Étape

```mql5
double Calcul_TailleDeLotOptimal(double risqueEnPourcent) {
    // ÉTAPE A : Comprendre l'Equity
    // La fonction native AccountInfoDouble() nous donne l'état du compte.
    // L'Equity est VITAL. Si vous avez 10 000$ (Balance) mais que vous avez déjà 
    // un trade perdant de -2 000$, votre Equity n'est que de 8 000$. 
    // Risquer 1% sur la Balance serait suicidaire. On utilise toujours l'Equity !
    double capitalActuel = AccountInfoDouble(ACCOUNT_EQUITY);
    
    // Le risque absolu en dollars
    double perteMaximum = capitalActuel * (risqueEnPourcent / 100.0);
```

### Le cauchemar du Tick Value sur l'Or
Maintenant, la bête noire de l'Or : le `SYMBOL_TRADE_TICK_VALUE`.
Sur un actif classique, le Tick Value est simple. Sur le XAUUSD (l'Or), il représente la valeur d'un mouvement de `0.01` ou `0.001` de cotation selon comment le broker encode le métal précieux ! Sans parler du pas de négociation (le volume minimum). L'algorithme se doit d'interroger le broker au lieu de forcer une valeur statique.

```mql5
    // Combien le broker exige au minimum ? (Often 0.01)
    double pasDuLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP); 
    double lotMinimum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    
    // La valeur universelle du point. Si l'Or passe de 2000.00 à 2000.01, combien vaut 1 lot ?
    double valeurDuPoint = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    
    // On simule une distance de StopLoss imaginaire pour notre formule (Ici : 200 points)
    // C'est vital. Sans Stop Loss estimé, impossible de savoir combien on perd !
    double distanceStopLossPoints = 200.0; 
    
    // La formule sacrée :
    // (L'argent M-A-X que je suis prêt à perdre) DIVISÉ par (le coût total du mouvement M-A-X)
    double lotBrut = 0;
    if(valeurDuPoint > 0) {
        lotBrut = perteMaximum / (distanceStopLossPoints * valeurDuPoint);
    }
```

Enfin, la sécurisation mathématique `MathFloor`.
```mql5
    // Pourquoi MathFloor ? 
    // Mettons que la machine calcule un lot parfait, mathématiquement exact, de 0.169.
    // L'utilisation d'un arrondi classique MQL5 (MathRound) donnerait 0.17.
    // Mais à 0.17, on risque 1.05%, donc on DÉPASSE de 0.05% notre règle d'or imposée !
    // MathFloor écrase la valeur et ramène de force vers le bas : 0.16. 
    // On risque finalement 0.98%. Sécurité absolue.
    
    double lotSecurise = MathFloor(lotBrut / pasDuLot) * pasDuLot;
    return MathMax(lotMinimum, lotSecurise); // Pare-feu final, jamais sous 0.01
}
```

---

## 4. Disséquer la Brique 2 : Le Sniper M1 (EMA + RSI)

*Fichier de référence : `Include/EntryConditions.mqh`*

Le 1 minute est le timeframe de choix des EAs, mais c'est un océan de bruit de marché. Si vous tradez de façon directionnelle en suivant n'importe quelle micro-bougie rouge ou verte, la règle numéro 1 s'impose : **The Trend is Your Friend**.

C'est pourquoi un signal professionnel de scalping nécessite impérativement une corrélation entre DEUX concepts radicalement opposés :
1. **L'EMA 200 (Exponential Moving Average)** : Elle analyse les 200 dernières minutes (environ 3 heures). Elle balaie le bruit et dessine la lourde "rivière" de la tendance macro-économique intra-day.
2. **Le RSI 14 (Relative Strength Index)** : C'est un oscillateur de momentum hyper nerveux en M1. Il détecte quand le marché a trop poussé d'un coup. S'il plonge sous 30, c'est que l'élastique a été tiré à fond vers le bas (Zone de Survente excessive).

La magie algorithmique du scalping de tendance se résume à une ligne : **On veut acheter quand la tendance lourde est foncièrement haussière (Le prix flotte Au-dessus l'EMA 200), MAIS que le marché vient de subir un plongeon agressif et très court (RSI s'écrase sous 30). C'est le fameux "Buy the Dip institutionnel".**

### Le Trésor caché des Codeurs d'Élite : La Bougie Numéro 1

C'est là que 99% des codeurs MQL5 débutants s'effondrent. Regardons le code critique de la Brique 2 :
```mql5
// On copie les données de l'indicateur dans notre buffer (tableau de variables virtuelles)
CopyBuffer(handleRSI, 0, 0, 2, valeursRSI);

// LE SECRET EST ICI :
double prixDeCloturePrec = iClose(_Symbol, PERIOD_CURRENT, 1);
bool estEnSurventeRebond = (valeursRSI[1] < 30.0);
```

**Pourquoi lire l'index `[1]` et absolument pas l'index `[0]` ?**

Dans le moteur interne de MetaTrader, l'index `[0]` correspond à la *minute présente*, la bougie frétillante qui est en train de se construire à droite absolue de votre écran de trading.
Imaginez que l'Or plonge soudainement à 10h04 et 12 secondes. Le RSI va plonger sous 30 en panique. L'algorithme naïf de `[0]` détecte le croisement et ACHÈTE immédiatement à 10:04:13. Mais à 10:04:45, le HFT des banques réinjecte de la liquidité et la bougie remonte complètement ! Le RSI repasse miraculeusement à 45... La condition `[0]` n'était en réalité qu'une illusion volatile de 30 secondes. L'algorithme a acheté sur du bruit.

En forçant la variable MQL5 sur l'index `[1]`, nous ordonnons au robot d'analyser **exclusivement la bougie précédente, celle dont le temps (Time) est expiré, clôturé, cimenté et archivé sur les serveurs**. La mathématique de cette bougie est figée pour l'éternité et ne clignotera JAMAIS.
C'est le secret absolu pour avoir des algorithmes qui matchent à 99% entre le Mode Backtest et le Mode Marché Réel.

---

## 5. Disséquer la Brique 3 : Le Kill Switch Prop Firm

*Fichier de référence : `Include/RiskManagement.mqh`*

Bienvenue dans l'ère moderne du trading de MQL5 : Lutter contre les Prop Firms (FTMO, MFF, Funding Pips, etc.).
Leur règle suprême d'élimination est terrible : Le **Max Daily Drawdown (Généralement 5%)**.
Si le compte en Test Prop Firm de 100 000$ perd ne serait-ce que 5 000,01$, y compris en comptant une simple *perte flottante mathématique de trades ouverts en pleins milieux d'un krach frénétique*, vous êtes impitoyablement banni. Le challenge est perdu.

Un Stop Loss `(SL)` classique *ne suffit absolument pas*. Pensez-y : lors d'une annonce NFP (Chômage Américain), l'Or fait un énorme gap, il saute un prix. Le broker MQL5 ne pourra pas couper techniquement votre trade à votre Stop Loss : c'est le "Slippage". L'exécution de l'Ordre au Marché (Market Execution) se fera sur le tout premier prix de cotation disponible de l'autre côté du précipice. Vous serez exécuté loin, et le Drawdown de 5% sera fracassé.

Le "Kill Switch" est une boucle infinie MQL5 qui scanne votre hémorragie en pur "OnTick" live.

```mql5
bool Securite_DrawdownAtteint(double limitePerteDollars) {
    // La fonction native AccountInfoDouble lit en live les gains et les pertes flottantes invisibles.
    double perteFlottante = AccountInfoDouble(ACCOUNT_PROFIT);
    
    // Si votre PnL tombe sous une limite dangereuse (ex: la limite du PropFirm)...
    if(perteFlottante <= -MathAbs(limitePerteDollars)) {
        return true;  // Le radar s'allume !
    }
    return false;
}
```

### Le Piège Mortel des Tableaux : La Boucle `for` avec Indices

Voici l'erreur numéro 1 qui détruit les EAs sur le marché, même créés par des développeurs rémunérés.
Pour purger le compte et fermer les pertes de tous les actifs, un dev standard code une boucle `for` naïve : 
`for(int i = 0; i < PositionsTotal(); i++)`.

**Le Résultat dévastateur : La moitié des trades refuse de se fermer en direct ! Comment ?**

Simulons la mémoire cache interne de l'Engine MetaTrader lorsque vous avez 3 positions XAUUSD à clôturer à la hâte :
- Position Index [0] = Trade Acheteur XAUUSD n°541
- Position Index [1] = Trade Vendeur XAUUSD n°542
- Position Index [2] = Trade Acheteur XAUUSD n°543

La boucle naïve démarre à `i = 0`. Elle ordonne la fermeture immédiate du Trade 541.
**Mais MT5 est dynamique ! La structure du tableau (Array) s'effondre et se réorganise à la milliseconde !** 
Puisque le 541 a disparu vers l'Historique, le Trade Vendeur 542 glisse physiquement de l'Index [1] vers la chaise vide du nouvel Index [0] ! Et le Trade 543 devient l'Index [1]. 

Ordonnant la suite, la boucle naïve incrémente son compteur `i++`. Elle passe donc à `i = 1`. Elle lit donc ce qui se trouve sur la chaise `Index [1]` : le Trade 543. Il est fermé. Puis la boucle se termine, car `i (2)` atteint le total restant.
Le Trade Vendeur n°542 (assis sur l'Index 0) n'aura **jamais** été lu. La perte géante continuera jusqu'à griller le compte Prop Firm.

**La Solution Architecturale Impitoyable : La Lecture Inversée.**
```mql5
void Securite_FermerTout() {
    CTrade outilTrade;
    
    // LA SEULE ET UNIQUE MANIERE DE FAIRE : DE LA FIN VERS LE DÉBUT ! (Le -- est capital).
    // On commence par supprimer le Trade 543 (Index 2).
    // Résultat : Les chaises [0] et [1] ne bronchent pas, aucune réorganisation n'affecte notre algorithme en aval !
    // Puis on ferme le [1], puis le [0] ! Imparable.
    
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        outilTrade.PositionClose(ticket);
    }
}
```

---

## 6. L'Assembleur : Analyse d'une structure OnTick Parfaite

*Fichier de référence : `Experts/GoldScalper.mq5`*

Maintenant que nos fondations de Briques `.mqh` ultra-robustes sont prêtes et hermétiques au fond de la soute MQL5, le fichier en orbite public `GoldScalper.mq5` peut briller. C'est le chef d'orchestre, il est incroyablement vierge, presque semblable à de la poésie informatique française.

Il exploite les structures natives MQL5 :
1. `OnInit()` : S'exécute le Jour J, lors du glisser-déposer. Il appelle et charge les capteurs d'indicateurs (les "Handles"). Il s'assure impitoyablement que l'Engine a réussi à communiquer avec MT5.
2. `OnDeinit()` : S'exécute l'Hiver, nettoie proprement la RAM.
3. `OnTick()` : Le coeur nucléaire. S'exécute des centaines de fois par seconde dès qu'une variation en micro-pips (un "Tick" bid/ask) est propagée par les tuyaux de votre broker.

Observez attentivement **l'ordre logique** asymétrique parfait déployé dans ce "Chef d'Orchestre" de notre projet GitHub :

```mql5
void OnTick()
{
    // RÈGLE NUMÉRO 1 : LA SURVIE D'ABORD, LE PROFIT ENSUITE. 
    // On appelle tout de suite la brique de Kill Switch. Ne cherchez AUCUN trade si 
    // votre Prop Firm a décrété que votre Daily Drawdown était de 499$.
    if(Securite_DrawdownAtteint(Limite_Drawdown_Journalier)) {
        Securite_FermerTout();
        
        // Le mot-clé "return" agit comme un mur de brique : MT5 est formellement interdit
        // de lire la ligne de code en dessous, bloquant toute nouvelle prise de trade à mort.
        return; 
    }
    
    // RÈGLE NUMÉRO 2 : PATIENCE MILITAIRE DU SNIPER
    // MQL5 renvoie PositionsTotal() == 0.
    // Cette condition draconienne assure le "One Shot, One Kill".
    // Sous Aucun prétexte, on n'utilise de "Grid" (Grille de trades multiples toxiques),
    // ni de "Martingale" suicidaire, ni de "Hedging" pour espérer se refaire.
    if(PositionsTotal() == 0)
    {
        // RÈGLE NUMÉRO 3 : VÉRIFICATION DU SIGNAL PARFAIT (Brique 2 - EntryConditions.mqh)
        if(Signal_EstAchatConforme(id_EMA200, id_RSI14, memRSI, memEMA))
        {
            // RÈGLE NUMÉRO 4 : RECHARGEMENT ADAPTATIF DE L'ARME (Brique 1 - LotManager.mqh)
            // L'algorithme sonde l'Equity. Vous gagnez du cash hier ? Le lot grossit silencieusement le lendemain.
            double tailleLot = Calcul_TailleDeLotOptimal(Risk_Par_Trade_En_Pourcent);
            
            // RÈGLE NUMÉRO 5 : L'EXECUTION EXACTE (OrderSend via CTrade)
            // L'oraison est simple. Pour payer, vous payez toujours le "ASK" (Le spread du broker).
            double prixAchatActuel = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            
            Trade.Buy(tailleLot, _Symbol, prixAchatActuel, 0, 0, "Trade Scalping Or - EA Creator");
        }
    }
}
```

L'avantage incommensurable de cette structure d'Expert Advisor : Si vous confiez un jour votre robot de Scalping à une firme d'Audit Prop Firm pour valider votre stratégie, ou à n'importe quel trader professionnel, il sera capable de lire ce `OnTick` et de déchiffrer instantanément comment vous ne ferez jamais sauter la banque, sans même avoir besoin d'analyser vos logiques internes cachées dans les Briques !

---

## 7. Foire Aux Questions (FAQ) MQL5 & Scalping Or

**Q : Dans quelle Unité de Temps exacte (Timeframe) dois-je backtester ou déployer cet algorithme M1 ?**  
**R :** Ce tutoriel a été expressément sculpté et testé pour le marché M1 (1 minute). La moyenne mobile paramétrée à 200 sur du graphique M1 matérialise approximativement les *3 heures et 20 minutes* passées de l'historique de l’Or, constituant une excellente macro-tendance (le "flow" de session) pour lier du scalping pur sans utiliser l'approche complexe du Multi-Timeframe MQL5 `iMA(_Symbol, PERIOD_H1...)`.

**Q : C'est très bien, mais où se trouve le mythique `Stop Loss` et le `Take Profit` (Reward) figés en "dur" dans votre ordre d'Achat `Trade.Buy( )`?**  
**R :** Attention. Ce projet pédagogique a vocation absolue de vous graver au fer rouge l'Architecture Modulaire des briques du scalping (Le Filtre, la Sûreté Drawdown, le Kill Switch de la firme). Si l'on complexifie immédiatement ce tutoriel en attachant des boucles de Break Even dynamiques asymétriques, des algorithmes de "Trailing Stop (Suiveur Rapide)", ou des objectifs de Profit à ratios flottants au milieu du `Trade.Buy( )` brut, vous auriez en ce moment sous les yeux un enchevêtrement illisible de 150 lignes mathématiques au lieu d'une ligne d'instruction claire.  
  
<br>

C'est ici que l'usage d'outils haut du spectre comme **👉 [EA Creator](https://autoea.online/generate) 👈** trouve son génie.
En plus de cette rigueur structurelle, ce *Drag and Drop Builder Intelligent* injecte de manière invisible des briques additionnelles comme des `Risk:Reward TP Modulaires`, un système `News Filter Intégré` (incontournable pour ne PAS trader 30 min avant les taux de la FED en M1 de l'or), et une **Offuscation d'encryptage totale de votre algorithme**. Vous téléchargez uniquement votre fichier compilation `.ex5` et personne ne pourra jamais voler, reverse-engineer (décompiler) ni s'approprier le Code Source du "Scalper Parfait" que vous venez d'inventer.

**Q : Ce module est-il limité par l'infrastructure des courtiers Prop Firms lors de la session Asiatique de l'Or ?**  
**R :** Les PropFirm MQL5 analysent l’Or au crible. Examinez obligatoirement si votre broker permet de la "Liquidité XAU" asymétrique. Pendant la Session Japonaise (Tokyo Overlap), si l'Or perd en volume, n'importe quel "algorithme Spread Extender" de MetaTrader affichera un spread de 30-40 pips virtuels. Et là, "Tradez au Market" va vampiriser tout votre capital, sans aucune chance de profit de sortie M1. Restez exclusivement sur le Cross-Overlap : *L'Ouverture de Londres et la Frénésie du Breakout New-Yorkais US (14h00 - 18h00).*

---

## Conclusion, Éthique et Engagement

Ce projet repository GitHub colossal se veut être bien plus qu'un "simple template". Il est un hommage à tous les traders amateurs, isolés et découragés devant les documentations obscures du site MQL5. Vous détenez désormais le schéma mental pour déconstruire et recomposer par vos soins des algorithmes complexes, rigoureux, et institutionnels.

Gardez toutefois à l'esprit un point vital : Le code n'est qu'un outil. Votre véritable et unique métier, c'est **Trader, Analyser la Liquidité, Définir son Edge**. L'algorithme doit être relégué à une exécution silencieuse dans l'ombre d'un VPS ultra-rapide, sans vous cannibaliser des mois de votre vie en de longs débuggages informatiques fastidieux.

<br>

<p align="center">
  <b>Tutoriel propulsé, sponsorisé et rédigé par l'équipe Data & Dev :</b><br>
  <br>
  <a href="https://autoea.online/generate">
    <img src="https://img.shields.io/badge/Créer_Mon_Robot_En_2_Clics_Sur_EA_Creator-Visualiser-red?style=for-the-badge&logoType=solid" alt="Créer mon EA MT5 d'Élite sans une ligne de code" />
  </a>
</p>

## Licence Open Source & Transparence

Ce référentiel MT5 complet est un patrimoine partagé librement pour l'apprentissage démocratique mondial de la communauté MQL5, déployé, pérennisé et sécurisé par la licence internationale [MIT](LICENSE).
