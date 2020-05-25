//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict

#include <Nng\Sockets.mqh>
#include "TestRunner.mqh"

TestRunner testRunner;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Socket_Open_Close() {
    Pair0Socket s;
    Assert(s.IsOpen());
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Socket_Listen_Dial() {
    string endpoint = "inproc://" + __FUNCTION__;

    Pair0Socket server;
    Assert(server.Listen(endpoint));
    Pair0Socket client;
    Assert(client.Dial(endpoint));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart() {
    Socket_Open_Close();
    Socket_Listen_Dial();
}
//+------------------------------------------------------------------+
