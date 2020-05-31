//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "Marshal.mqh"
#include "nng.mqh"
#include "Serialization.mqh"

class Message {
  private:
    nng_msg _message;
    void Free();
  public:
    Message();
    Message(nng_msg nngMsg);
    ~Message();
    nng_msg Unwrap();
    bool Allocate(int size);
    size_t GetSize();
    intptr_t GetBody();
    void Release();
    bool SetData(const string in, uint codePage = CP_UTF8);
    bool GetData(string &out, uint codePage = CP_UTF8);

    template <typename T> bool SetData(T &in, IJsonSerializer<T> *serializer) {
        string serialized = NULL;
        if (!serializer.Serialize(in, serialized)) return false;
        return SetData(serialized);
    }
    template <typename T> bool GetData(T &out, IJsonSerializer<T> *serializer) {
        string serialized;
        if (!GetData(serialized)) return false;
        return serializer.Deserialize(serialized, out);
    }
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Message::Message()
    : _message(0) {
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Message::Message(nng_msg nngMsg)
    : _message(nngMsg) {
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Message::~Message() {
    Free();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
nng_msg Message::Unwrap() {
    return _message;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Message::Allocate(int size) {
    if (size == 0) return false;
    NngErrorCode errorCode = nng_msg_alloc(_message, size);
    return errorCode == NNG_SUCCESS;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Message::Free() {
    if (_message == 0) return;
    nng_msg_free(_message);
    _message = 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
size_t Message::GetSize() {
    return nng_msg_len(_message);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
intptr_t Message::GetBody() {
    return nng_msg_body(_message);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Message::SetData(const string in, uint codePage = CP_UTF8) {
    int size = StringSizeInBytes(in, codePage);
    if (!Allocate(size)) return false;
    intptr_t body = GetBody();
    if (body == 0) return false;
    return StringToPointer(in, body, codePage);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Message::GetData(string &out, uint codePage = CP_UTF8) {
    intptr_t body = GetBody();
    if (body == 0) return false;
    return PointerToString(body, out, codePage);
}

//+------------------------------------------------------------------+
//| Called when the socket accepts the message for delivery.         |
//+------------------------------------------------------------------+
void Message::Release() {
    _message = 0;
}
//+------------------------------------------------------------------+
