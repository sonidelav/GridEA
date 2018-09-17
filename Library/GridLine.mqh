//+------------------------------------------------------------------+
//|                                                     GridLine.mqh |
//|       Copyright 2018, Valentinos Galanos <sonidelav@hotmail.com> |
//+------------------------------------------------------------------+
#ifndef C_GRIDLINE
#define C_GRIDLINE

#include <Object.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridLine : public CObject
{
private:
            CChartObjectHLine   *m_chartGridLineObj;    // GRAPH HORIZONTAL LINE
            
            double  m_price;                            // PRICE OF GRID LINE
            string  m_name;                             // NAME OF LINE
            color   m_lineColor;                        // LINE COLOR
            
            ENUM_ORDER_TYPE m_direction;                // DIRECTION
            bool    m_ordersExecuted;                   // MARKET EXECUTED
            bool    m_ordersPlaced;                     // PENDING ORDERS
            bool    m_reached;                          // REACH STATE
            
public:
             CGridLine(
                double dPrice,              // ENTRY PRICE
                string sName,               // LINE NAME
                color clLineColor,          // LINE COLOR
                ENUM_ORDER_TYPE eDirection, // LINE DIRECTION
                bool bWithoutOrders         // NO ORDERS ON THIS GRID LINE
            );
            ~CGridLine();
            
            double  GetClosePrice();
            bool    HasBeenReached();
            bool    HasBeenReachedClosePrice();
            void    MarketExecutionOrders();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGridLine::CGridLine(double dPrice, string sName, color clLineColor = clrBlack, ENUM_ORDER_TYPE eDirection = OP_BUY, bool bWithoutOrders = false)
{
    // GRID LINE PROPERTIES
    m_price             = dPrice;
    m_name              = sName;
    m_lineColor         = clLineColor;
    m_direction         = eDirection;
    m_ordersExecuted    = bWithoutOrders;
    m_ordersPlaced      = bWithoutOrders;
    m_reached           = false;
    
    // GRAPH LINE
    m_chartGridLineObj    = new CChartObjectHLine();
    
    m_chartGridLineObj.Create(ChartID(), m_name, 0, m_price);
    m_chartGridLineObj.Color(clLineColor);
    m_chartGridLineObj.Background(true);
    m_chartGridLineObj.Description(m_name);
    m_chartGridLineObj.Selectable(false);
    m_chartGridLineObj.Hidden(true);
    m_chartGridLineObj.Width(1);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGridLine::~CGridLine()
{
    delete m_chartGridLineObj;
}
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridLine::GetClosePrice()
{
    // LONG GRID LINE
    if( m_direction == OP_BUY )
    {
        return m_price - ( SymbolInfoDouble(Symbol(), SYMBOL_POINT) * (GridGap * 10) );
    }
    // SHORT GRID LINE
    else
    {
        return m_price + ( SymbolInfoDouble(Symbol(), SYMBOL_POINT) * (GridGap * 10) );
    }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridLine::HasBeenReached()
{
    if( m_reached == true ) return false;
    
    if( m_direction == OP_BUY )
    {
        if( Bid >= m_price )
        {
            m_reached = true;
            return true;
        }
    }
    else
    {
        if( Bid <= m_price )
        {
            m_reached = true;
            return true;
        }
    }
    
    return false;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridLine::HasBeenReachedClosePrice()
{
    if( m_direction == OP_BUY )
    {
        return Bid <= GetClosePrice();
    }
    else
    {
        return Bid >= GetClosePrice();
    }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridLine::MarketExecutionOrders()
{
    if(m_ordersExecuted == true) return;
    
    double dLongTakeProfit      = m_price + ( SymbolInfoDouble(Symbol(), SYMBOL_POINT) * (GridGap * 10) );
    double dShortTakeProfit     = m_price - ( SymbolInfoDouble(Symbol(), SYMBOL_POINT) * (GridGap * 10) );
    
    // Execute Long Order
    bool longExecuted = OrderSend(
        Symbol(),
        OP_BUY,
        LotSize,
        Ask,
        5,
        0,
        dLongTakeProfit,
        StringFormat("GRID|%G", m_price),
        333,
        0,
        clrNONE
    );
    
    // Execute Short Order
    bool shortExecuted = OrderSend(
        Symbol(),
        OP_SELL,
        LotSize,
        Bid,
        5,
        0,
        dShortTakeProfit,
        StringFormat("GRID|%G", m_price),
        333,
        0,
        clrNONE
    );
    
    m_ordersExecuted = true;
}

#endif