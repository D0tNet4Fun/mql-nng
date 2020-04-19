#property strict

#include <Nng\Sockets.mqh>
#include "TestRunner.mqh"

TestRunner testRunner;

void OpenAndCloseSocket()
{
   Pair0Socket s;
   Assert(s.IsOpen());
}

void OnStart()
{
   OpenAndCloseSocket();
}
