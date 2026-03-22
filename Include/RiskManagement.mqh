//+------------------------------------------------------------------+
//|                                               RiskManagement.mqh |
//|                                  Copyright 2026, EA Creator      |
//|                                       https://autoea.online      |
//+------------------------------------------------------------------+
//
// BRIQUE 3 : LE BOUCLIER ANTI-DRAWDOWN (Kill Switch)
// Objectif : Fonction cruciale pour réussir un challenge Prop Firm.
// Le Bouclier scanne la santé du compte. Si ça saigne trop, il explose tout.
//-------------------------------------------------------------------+

#include <Trade\Trade.mqh>

// --- Fonction Capteur : Détection de l'hémorragie financière ---
bool Securite_DrawdownAtteint(double limitePerteDollars)
{
    // Quelle est la douleur actuelle ? On regarde le PnL (profit) brut et flottant des trades en cours.
    double perteFlottante = AccountInfoDouble(ACCOUNT_PROFIT);
    
    // MathAbs s'assure qu'on compare avec un chiffre absolu.
    // Si la perte atteint par exemple -500$, ou franchit la ligne en négatif...
    if(perteFlottante <= -MathAbs(limitePerteDollars))
    {
        return true; // ALERTE ROUGE DÉCLENCHÉE
    }
    
    return false; // Silence radio, le compte est en sécurité.
}

// --- Fonction Exécuteur : Le Bouton d'Arrêt d'Urgence ! ---
void Securite_FermerTout()
{
    CTrade outilTrade;
    
    // On doit balayer tous nos trades ouverts en partant de la FIN pour éviter le bug des index qui se décalent (classique MT5)
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        // On cible le "ticket de caisse" de la position
        ulong ticket = PositionGetTicket(i);
        
        // On s'assure qu'on ne ferme que l'actif sur lequel ce bot tourne (ex: OR / XAUUSD)
        if(PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
            outilTrade.PositionClose(ticket);
        }
    }
    
    Print("🚨 DANGER : Le Bouclier Anti-Drawdown est intervenu. Panique à bord, toutes les positions XAUUSD ont été atomisées !");
}
