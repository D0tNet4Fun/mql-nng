//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict

#include "TestRunner.mqh"
#include <Nng/Message.mqh>
#include <JAson.mqh>

TestRunner testRunner;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
    Message msg;

    MqlTickSerializer serializer;
    IJsonSerializer<MqlTick> *serializerPtr = GetPointer(serializer);

    MqlTick tick;
    tick.ask = 1.0;
    tick.bid = 2.0;
    Assert(msg.SetData(tick, serializerPtr));

    MqlTick outTick;
    Assert(msg.GetData(outTick, serializerPtr));
    Assert(outTick.ask == 1.0);
    Assert(outTick.bid == 2.0);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart() {
    SetStringAndGetString();
    SetTickAndGetTick();
};
//+------------------------------------------------------------------+
