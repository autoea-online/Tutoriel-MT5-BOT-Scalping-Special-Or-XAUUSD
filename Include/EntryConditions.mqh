//+------------------------------------------------------------------+
//|                                              EntryConditions.mqh |
//|                                  Copyright 2026, EA Creator      |
//|                                       https://autoea.online      |
//+------------------------------------------------------------------+
//
// BRIQUE 2 : LE SNIPER D'ENTRÉE (Tendance + Survente M1)
// Objectif : Analyser le graphique en temps réel pour détecter l'alignement
// parfait d'une forte tendance de fond et d'un rebond d'élastique court terme.
//-------------------------------------------------------------------+

bool Signal_EstAchatConforme(int handleEMA, int handleRSI, double &valeursRSI[], double &valeursEMA[])
{
   // --- ETAPE 1 : Récupération des dernières données ---
   // On copie les 2 dernières valeurs de RSI et EMA dans nos tableaux vierges.
   if(CopyBuffer(handleRSI, 0, 0, 2, valeursRSI) <= 0) return false;
   if(CopyBuffer(handleEMA, 0, 0, 2, valeursEMA) <= 0) return false;
   
   // --- ETAPE 2 : On filtre la bougie fantôme ---
   // On lit le prix de clôture de la bougie "1" (celle qui est figée dans le passé).
   // C'est vital ! Si on utilise la bougie en cours [0], le RSI va bouger chaque seconde.
   double prixDeCloturePrec = iClose(_Symbol, PERIOD_CURRENT, 1);
   
   // --- ETAPE 3 : Vérification (A) de la Tendance de Fond ---
   // L'EMA 200 est notre radar. Si le prix est plus haut, on est en Haussier lourd.
   bool estEnTendanceHaussiere = (prixDeCloturePrec > valeursEMA[1]);
   
   // --- ETAPE 4 : Vérification (B) du Momentum de l'Or ---
   // Le RSI a plongé, l'élastique est tendu. (Survente sous la zone des 30)
   bool estEnSurventeRebond = (valeursRSI[1] < 30.0);
   
   // --- VERDICT ---
   // On dégaine uniquement si les conditions s'alignent.
   if(estEnTendanceHaussiere && estEnSurventeRebond)
   {
       return true; // FEU VERT ACHAT
   }
   
   return false;
}

bool Signal_EstVenteConforme(int handleEMA, int handleRSI, double &valeursRSI[], double &valeursEMA[])
{
   // On récupère les indicateurs en tampon mémoire
   if(CopyBuffer(handleRSI, 0, 0, 2, valeursRSI) <= 0) return false;
   if(CopyBuffer(handleEMA, 0, 0, 2, valeursEMA) <= 0) return false;
   
   // On lit la bougie d'il y a 1 minute.
   double prixDeCloturePrec = iClose(_Symbol, PERIOD_CURRENT, 1);
   
   // VERIF 1 : L'ours a pris le contrôle (Sous l'EMA 200)
   bool estEnTendanceBaissiere = (prixDeCloturePrec < valeursEMA[1]);
   
   // VERIF 2 : Le marché est trop gourmand (Surachat supérieur à 70)
   bool estEnSurchauffe = (valeursRSI[1] > 70.0);
   
   // VERDICT
   if(estEnTendanceBaissiere && estEnSurchauffe)
   {
       return true; // FEU VERT VENTE
   }
   
   return false;
}
