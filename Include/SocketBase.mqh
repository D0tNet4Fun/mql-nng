//+------------------------------------------------------------------+
//| Base class for all socket classes.                               |
//+------------------------------------------------------------------+
#property strict

#include "nng.mqh"
#include "SocketFactory.mqh"

class SocketBase
{
private:
   nng_socket m_socket;
protected:
   SocketBase(OpenSocketFunc func);
   ~SocketBase();
public:
   bool IsOpen();
};

SocketBase::SocketBase(OpenSocketFunc func)
   : m_socket(0)
{
   NngErrorCode errorCode = func(m_socket);
   if (errorCode != NngErrorCode::NNG_SUCCESS)
   {
      PrintFormat("(!) Error opening socket: %s", EnumToString(errorCode));
   }
}

SocketBase::~SocketBase()
{
   if (!IsOpen()) return;
   
   NngErrorCode errorCode = nng_close(m_socket);
   if (errorCode != NngErrorCode::NNG_SUCCESS)
   {
      PrintFormat("(!) Error closing socket: %s", EnumToString(errorCode));
   }
   else
   {
      m_socket = 0;
   }
}

bool SocketBase::IsOpen() { return m_socket > 0; }