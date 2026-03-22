//+------------------------------------------------------------------+
//|                                                  GoldScalper.mq5 |
//|                                  Copyright 2026, EA Creator      |
//|                                       https://autoea.online      |
//+------------------------------------------------------------------+
#property copyright   "EA Creator Prop Firm & Scalping"
#property link        "https://autoea.online"
#property version     "2.00"
#property description "Un Chef d'Orchestre élégant pour scalper l'Or sans casser son compte."

// --- IMPORTATION DE NOS BRIQUES INTEMPORELLES ---
#include <Trade\Trade.mqh>
#include <LotManager.mqh>
#include <EntryConditions.mqh>
#include <RiskManagement.mqh>

// --- RÉGLAGES UTILISATEURS (Simples et Efficaces) ---
input double Risk_Par_Trade_En_Pourcent = 1.0;   // Risque toléré par position (%)
input double Limite_Drawdown_Journalier = 500.0; // PnL d'urgence (Kill Switch en $)

// Variables globales (les "yeux" de notre bot)
int id_EMA200;
int id_RSI14;
CTrade Trade;

//+------------------------------------------------------------------+
//| DÉMARRAGE DU BOT (Chargement des capteurs)                       |
//+------------------------------------------------------------------+
int OnInit()
{
    // On branche nos capteurs MQL5
    id_EMA200 = iMA(_Symbol, PERIOD_CURRENT, 200, 0, MODE_EMA, PRICE_CLOSE);
    id_RSI14  = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
    
    // Si les indicateurs n'ont pas pu charger (ex: pas de réseau)
    if(id_EMA200 == INVALID_HANDLE || id_RSI14 == INVALID_HANDLE)
    {
        Print("❌ ERREUR : Impossible d'initialiser les indicateurs.");
        return(INIT_FAILED);
    }
        
    Print("✅ Démarrage Réussi ! Scalper Or prêt au combat.");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| NETTOYAGE LORS DE LA FERMETURE DU BOT                            |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    IndicatorRelease(id_EMA200);
    IndicatorRelease(id_RSI14);
}

//+------------------------------------------------------------------+
//| LE COEUR BATTANT DU ROBOT (S'exécute à chaque micro-mouvement)   |
//+------------------------------------------------------------------+
void OnTick()
{
    // --- 1. SÉCURITÉ AVANT TOUT ---
    // Si la perte totale dépasse la limite, on ferme tout !
    if(Securite_DrawdownAtteint(Limite_Drawdown_Journalier))
    {
        Securite_FermerTout();
        return; // On stoppe l'action ici pour ce tick.
    }
    
    // --- 2. RECHERCHE D'OPPORTUNITÉ ---
    // Les scalpers intelligents n'ouvrent pas 50 positions d'un coup.
    // On trade uniquement si nos mains sont vides.
    if(PositionsTotal() == 0)
    {
        double memoireRSI[], memoireEMA[];
        ArraySetAsSeries(memoireRSI, true);
        ArraySetAsSeries(memoireEMA, true);
        
        // Y a-t-il un signal d'ACHAT parfait (Tendance + RSI Actif) ?
        if(Signal_EstAchatConforme(id_EMA200, id_RSI14, memoireRSI, memoireEMA))
        {
            // --- 3. PRÉPARATION DES MUNITIONS ---
            double tailleLot = Calcul_TailleDeLotOptimal(Risk_Par_Trade_En_Pourcent);
            
            // --- 4. EXÉCUTION ---
            double prixAchatActuel = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            Trade.Buy(tailleLot, _Symbol, prixAchatActuel, 0, 0, "Achat Scalping Or");
        }
        
        // Sinon, Y a-t-il un signal de VENTE parfait ?
        else if(Signal_EstVenteConforme(id_EMA200, id_RSI14, memoireRSI, memoireEMA))
        {
            double tailleLot = Calcul_TailleDeLotOptimal(Risk_Par_Trade_En_Pourcent);
            
            double prixVenteActuel = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            Trade.Sell(tailleLot, _Symbol, prixVenteActuel, 0, 0, "Vente Scalping Or");
        }
    }
}
