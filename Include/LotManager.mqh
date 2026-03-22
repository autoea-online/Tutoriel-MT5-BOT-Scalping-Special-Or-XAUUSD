//+------------------------------------------------------------------+
//|                                                   LotManager.mqh |
//|                                  Copyright 2026, EA Creator      |
//|                                       https://autoea.online      |
//+------------------------------------------------------------------+
//
// BRIQUE 1 : LE CALCULATEUR DE LOT SPÉCIAL OR
// Objectif : Adapter automatiquement la taille du lot à 
// votre capital actuel pour ne risquer qu'un pourcentage précis.
//-------------------------------------------------------------------+

double Calcul_TailleDeLotOptimal(double risqueEnPourcent)
{
    // 1. Quel est notre capital actuel protégé ? (L'Equity)
    // Contrairement à la Balance, l'Equity prend en compte vos trades ouverts.
    double capitalActuel = AccountInfoDouble(ACCOUNT_EQUITY);
    
    // 2. Quel est le montant maximum (en dollars) que l'on accepte de perdre ?
    double perteMaximum = capitalActuel * (risqueEnPourcent / 100.0);
    
    // 3. Spécificités structurelles imposées par le Broker pour le Gold
    double pasDuLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP); // Échelon (ex: 0.01)
    double lotMinimum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    
    // 4. Combien vaut 1 seul point de mouvement d'or pour 1 lot complet ?
    double valeurDuPoint = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    
    // Définition de la distance de notre Stop Loss imaginaire (en points)
    // Exemple : 20 pips sur de l'or = environ 200 points.
    double distanceStopLossPoints = 200.0; 
    
    // 5. Formule mathématique pure pour trouver le Lot Brut à générer
    double lotBrut = 0;
    if(valeurDuPoint > 0) 
    {
        lotBrut = perteMaximum / (distanceStopLossPoints * valeurDuPoint);
    }
    
    // 6. Normalisation : on arrondit strictement vers le bas pour ne JAMAIS dépasser le risque.
    double lotSecurise = MathFloor(lotBrut / pasDuLot) * pasDuLot;
    
    // Au grand minimum, si le lot calculé est infime, on ouvre la position au lot minimum du broker.
    return MathMax(lotMinimum, lotSecurise);
}
