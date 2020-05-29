//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "Native.mqh"

#import "kernel32.dll"
int MultiByteToWideChar(
    uint codePage,
    uint flags,
    const intptr_t multiByteString,
    int lengthMultiByte,
    string &wideCharString,
    int lengthWideChar);
int WideCharToMultiByte(
    uint codePage,
    uint flags,
    const string &wideCharString,
    int lengthWideChar,
    intptr_t multiByteString,
    int lengthMultiByte,
    intptr_t defaultChar,
    intptr_t usedDefaultChar);
#import

int StringSizeInBytes(const string &in, uint codePage) {
    return WideCharToMultiByte(codePage, 0, in, -1, 0, 0, 0, 0);
}

bool StringToPointer(const string &in, intptr_t ptr, uint codePage) {
    int size = StringSizeInBytes(in, codePage);
    return WideCharToMultiByte(codePage, 0, in, -1, ptr, size, 0, 0) == size;
}

bool PointerToString(const intptr_t ptr, string &out, uint codePage) {
    out = NULL;
    int size = MultiByteToWideChar(codePage, 0, ptr, -1, out, 0);
    StringInit(out, size);
    return MultiByteToWideChar(codePage, 0, ptr, -1, out, size) == size;
}
//+------------------------------------------------------------------+
