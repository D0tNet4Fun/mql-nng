//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict

#include "nng.mqh"

/// Function pointer for opening a socket
typedef NngErrorCode (*OpenSocketFunc)(nng_socket&);

/// Macro for defining a function used to open a specific type of socket
#define EmitOpenSocketFunc(TYPENAME, NNGTYPENAME) \
    static NngErrorCode Open##TYPENAME##Socket(nng_socket &socket) \
    {\
        return nng_##NNGTYPENAME##_open(socket);\
    }

/// Class that defines all the functions used to open sockets (nng_*_open).
/// This is for internal use only.
class SocketFactory {
  public:
    EmitOpenSocketFunc(Pair0, pair0);
    EmitOpenSocketFunc(Publisher, pub0);
    // todo add more
};
//+------------------------------------------------------------------+
