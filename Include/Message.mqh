//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "Marshal.mqh"
#include "nng.mqh"

struct Message {
  private:
    nng_msg _message;
  public:
    Message(size_t size = 0);
    ~Message();
    void Dispose();
    void Wrap(nng_msg &message);
    nng_msg Unwrap();
    size_t GetSize();
    bool SetTick(MqlTick &value);
    bool GetTick(MqlTick &result);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Message::Message(size_t size = 0)
    : _message(0) {
    if (size == 0) return;
    NngErrorCode errorCode = nng_msg_alloc(_message, size);
    if (errorCode != NngErrorCode::NNG_SUCCESS) {
        Print("(!) Failed to allocate message");
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Message::~Message() {
    if(_message == 0) return;

    nng_msg_free(_message);
    _message = 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Message::Wrap(nng_msg &message) {
    _message = message;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
nng_msg Message::Unwrap() {
    return _message;
}

//+------------------------------------------------------------------+
//| Called when the socket accepts the message for delivery.         |
//+------------------------------------------------------------------+
void Message::Dispose() {
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
bool Message::SetTick(MqlTick &value) {
    intptr_t body = nng_msg_body(_message);
    if (body == 0) return false;
    Serialize(value, body, sizeof(MqlTick));
    return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Message::GetTick(MqlTick &result) {
    intptr_t body = nng_msg_body(_message);
    if (body == 0) return false;
    Deserialize(body, result, sizeof(MqlTick));
    return true;
}
//+------------------------------------------------------------------+
