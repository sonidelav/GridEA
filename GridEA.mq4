//+------------------------------------------------------------------+
//|                                                       GridEA.mq4 |
//|       Copyright 2018, Valentinos Galanos <sonidelav@hotmail.com> |
//+------------------------------------------------------------------+
#define ver "1.00"
#property copyright "Copyright 2018, Valentinos Galanos <sonidelav@hotmail.com>"
#property version   ver
#property strict

//--- input parameters
input int      GridGap          =   50;             // Grid Gap (Pips)
input double   LotSize          =   0.01;           // Trade Lot Volume
input int      TotalGridLines   =   7;              // Total Grid Lines Each Side

//--- Includes
#include "Library\GridExpert.mqh"

//--- Expert
CGridExpert*    GridEA;
//--- Memory
bool            initialized=false;
bool            timerCalled=false;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- create timer
    EventSetMillisecondTimer(500);
    
    if( initialized == false )
    {
        initialized = true;
        GridEA      = new CGridExpert;
        return GridEA.OnInit();
    }
    
    //---
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //--- destroy timer
    EventKillTimer();
    
    switch(reason)
    {
        case REASON_CLOSE:
        case REASON_INITFAILED:
        case REASON_RECOMPILE:
        case REASON_REMOVE:
        case REASON_ACCOUNT:
        case REASON_CHARTCLOSE:
        case REASON_PROGRAM:
            if( initialized && GridEA != NULL)
            {
                GridEA.OnDeinit(reason);
                initialized = false;
                delete GridEA;
            }
            break;
    }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    //---
    if( initialized && GridEA != NULL )
    {
        GridEA.OnTick();
    }
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    if(timerCalled == false)
    {
        timerCalled = true;
        //---
        if( initialized && GridEA != NULL )
        {
            GridEA.OnTimer();
        }
        timerCalled = false;
    }
}
//+------------------------------------------------------------------+
