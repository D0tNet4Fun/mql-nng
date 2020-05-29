//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict

#include "TestRunner.mqh"
#include <Nng/Message.mqh>

TestRunner testRunner;

void SetStringAndGetString() {
    string data = "hello world";
    
    Message msg;
    Assert(msg.SetData(data));
    
    string outData;
    Assert(msg.GetData(outData));
    
    Assert(outData == data);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetTickAndGetTick() {
    Message msg;//(sizeof(MqlTick));
    //Assert(msg.GetSize() == 60);

    MqlTick tick;
    tick.ask = 1.0;
    tick.bid = 2.0;
    //Assert(msg.SetTick(tick));

    MqlTick returnedTick;
    //Assert(msg.GetTick(returnedTick));
    Assert(returnedTick.ask == 1.0);
    Assert(returnedTick.bid == 2.0);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart() {
    SetStringAndGetString();
    //SetTickAndGetTick();
};
//+------------------------------------------------------------------+
