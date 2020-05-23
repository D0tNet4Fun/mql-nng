//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "Native.mqh"

#define CopyMemory RtlCopyMemory

#import "kernel32.dll"
void CopyMemory(MqlTick &destination, intptr_t source, size_t length);
void CopyMemory(intptr_t destination, MqlTick &source, size_t length);
#import

template <typename T>
void Serialize(T &source, intptr_t destination, size_t length) {
    CopyMemory(destination, source, length);
}

template <typename T>
void Deserialize(intptr_t source, T &destination, size_t length) {
    CopyMemory(destination, source, length);
}
//+------------------------------------------------------------------+
