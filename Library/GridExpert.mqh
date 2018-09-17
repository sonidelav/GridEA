//+------------------------------------------------------------------+
//|                                                   GridExpert.mqh |
//|       Copyright 2018, Valentinos Galanos <sonidelav@hotmail.com> |
//+------------------------------------------------------------------+
#ifndef C_GRIDEXPERT
#define C_GRIDEXPERT

#include <Arrays\ArrayObj.mqh>
#include "GridLine.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridExpert
{
private:
        CArrayObj   *m_GridLines;                   // GRID LINES
        CGridLine   *m_ReachedGridLine;             // REACHED GRIDLINE
        CGridLine   *m_EntryGridLine;               // ENTRY GRID LINE
        
        int         m_TotalGridLines;               // TOTAL GRID LINES ON EACH SIDE
        double      m_LotSize;                      // LOT VOLUME PER TRADE
        int         m_GridGapPips;                  // GRID GAP IN PIPS
        
        string      m_Symbol;                       // SYMBOL NAME
        double      m_SymbolPoint;                  // SYMBOL POINT
        
protected:
        void        GenerateGridLines();                // GENERATE GRID LINES ON EACH SIDE
        void        Reset();                            // RESET GRID
        
public:
         CGridExpert();
        ~CGridExpert();
        
        void    OnTimer();
        int     OnInit();
        void    OnDeinit(const int reason);
        void    OnTick();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGridExpert::CGridExpert()
{
    m_GridLines         = new CArrayObj;
    m_ReachedGridLine   = NULL;
    m_EntryGridLine     = NULL;
    
    // INPUTS
    m_TotalGridLines    = TotalGridLines;
    m_LotSize           = LotSize;
    m_GridGapPips       = GridGap;
    
    m_Symbol            = Symbol();
    m_SymbolPoint       = SymbolInfoDouble(m_Symbol, SYMBOL_POINT);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGridExpert::~CGridExpert()
{
    delete m_GridLines;
    delete m_EntryGridLine;
}
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CGridExpert::OnInit(void)
{
    ChartSetInteger(0, CHART_SHOW_OBJECT_DESCR, 0);
    ChartSetInteger(0, CHART_SHOW_GRID, 0);
    
    GenerateGridLines();
    
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridExpert::OnDeinit(const int reason)
{
    
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridExpert::OnTimer()
{
    
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridExpert::OnTick(void)
{
    // LOOK GRID LINES LOOP
    if(m_GridLines != NULL && m_GridLines.Total() > 0)
    {
        for(int i = 0; i < m_GridLines.Total(); i++)
        {
            CGridLine *gridLine = m_GridLines.At(i);
            if( gridLine.HasBeenReached() )
            {
                Print("[GRID EA] Reached GRID LINE");
                gridLine.MarketExecutionOrders(); 
                m_ReachedGridLine = gridLine;
                break;
            }
        }
    
    
        // LOOK FOR CLOSE PRICE REACHED
        if( m_ReachedGridLine != NULL && m_ReachedGridLine.HasBeenReachedClosePrice() )
        {
            m_ReachedGridLine = NULL;
            Reset();
        }
    
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridExpert::GenerateGridLines()
{
    // GET SYMBOL BID
    double  dSymbolBid          =   Bid;
    double  dSymbolAsk          =   Ask;
    
    double  dLongPrice          =   0;
    double  dShortPrice         =   0;
    double  dPointsFromPips     =   0;
    
    
    // CREATE ENTRY GRID LINE
    
    m_EntryGridLine = new CGridLine( dSymbolBid, StringFormat("GridLine Entry [ %d | %G ]", 0, dSymbolBid), clrGold, OP_BUY );
    m_EntryGridLine.MarketExecutionOrders();
    
    
    // CREATE GRID LINES [LONG , SHORT]
    for(int i = 1; i <= m_TotalGridLines; i++)
    {
        // CALCULATE POINTS FROM PIPS
        dPointsFromPips     =   ( m_SymbolPoint * (m_GridGapPips * 10) ) * i;
    
        // CALCULATE LONG DIRECTION PRICE
        dLongPrice  =   dSymbolBid + dPointsFromPips;
        dShortPrice =   dSymbolBid - dPointsFromPips;
        
        // CREATE GRID LINE
        
        // LONG LINE 
        CGridLine *longLine = new CGridLine( dLongPrice, StringFormat("GridLine Long [ %d | %G ]", i, dLongPrice), clrBlack, OP_BUY );
        m_GridLines.Add(longLine);
        
        // SHORT LINE
        CGridLine *shortLine = new CGridLine( dShortPrice, StringFormat("GridLine Short [ %d | %G ]", i, dShortPrice), clrBlack, OP_SELL );
        m_GridLines.Add(shortLine);
    }
    
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridExpert::Reset()
{
    // CLEAR GRIDLINES
    delete m_EntryGridLine;
    m_GridLines.Clear();
    
    // CLOSE ALL ORDERS
    Print("[GRID EA] - CLOSE ORDERS");
    while(OrdersTotal() > 0)
    {
        for(int i = 0; i < OrdersTotal(); i++)
        {
            if( OrderSelect(i, SELECT_BY_POS) )
            {            
                if( OrderTicket() != 0 )
                {
                    if( OrderType() == OP_BUY || OrderType() == OP_SELL )
                    {
                        bool closed = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
                    }
                    else
                    {
                        bool closed = OrderDelete(OrderTicket());
                    }
                }
            }
        }
    }
    
    // RE-GENERATE GRID LINES
    Print("[GRID EA] - RESET GRID LINES");
    GenerateGridLines();
}
#endif