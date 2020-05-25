//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict

#include <Nng\Sockets.mqh>
#include <Nng\Message.mqh>
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
void Socket_SendReceiveMessage() {
    string endpoint = "inproc://" + __FUNCTION__;
    Pair0Socket server;
    server.Listen(endpoint);
    Pair0Socket client;
    client.Dial(endpoint);

    Message msg(sizeof(MqlTick));
    MqlTick tick = {0};
    tick.ask = 10.0;
    tick.bid = 9.5;
    msg.SetTick(tick);
    Assert(client.SendMessage(msg));

    Message receivedMessage;
    Assert(server.ReceiveMessage(receivedMessage));
    size_t size = receivedMessage.GetSize();
    Assert(size == sizeof(MqlTick));
    MqlTick receivedTick = {0};
    Assert(receivedMessage.GetTick(receivedTick));
    Assert(receivedTick.ask == 10.0);
    Assert(receivedTick.bid == 9.5);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart() {
    Socket_Open_Close();
    Socket_Listen_Dial();
    Socket_SendReceiveMessage();
}
//+------------------------------------------------------------------+
