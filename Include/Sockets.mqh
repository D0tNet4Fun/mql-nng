//+------------------------------------------------------------------+
//| Contains classes used to represent sockets (protocols).          |
//+------------------------------------------------------------------+
#property strict

#include "nng.mqh"
#include "SocketBase.mqh"
#include "SocketFactory.mqh"

/// Macro for defining a class used to represent a specific type of socket (protocol)
#define EmitSocketClass(TYPE) \
class TYPE##Socket : public SocketBase\
{\
public:\
   TYPE##Socket() : SocketBase(SocketFactory::Open##TYPE##Socket) { }\
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EmitSocketClass(Pair0)
EmitSocketClass(Puller)
// todo add more
