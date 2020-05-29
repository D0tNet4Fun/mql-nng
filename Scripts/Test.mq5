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

    Message msg;
    Assert(msg.SetData("hello"));
    Assert(client.SendMessage(msg));

    Message receivedMessage;
    Assert(server.ReceiveMessage(receivedMessage));
    size_t size = receivedMessage.GetSize();
    Assert(6 == size);
    string receivedString;
    Assert(receivedMessage.GetData(receivedString));
    Assert("hello" == receivedString);
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
