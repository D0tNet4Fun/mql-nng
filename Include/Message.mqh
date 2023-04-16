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
    uint _topicLength;
  public:
    Message();
    Message(nng_msg nngMsg);
    ~Message();
    nng_msg Unwrap();
    bool Allocate(int size);
    size_t GetSize();
    intptr_t GetBody();
    void Release();
    bool Insert(const string value, uint codePage = CP_UTF8);
    bool SetData(const string in, uint codePage = CP_UTF8);
    bool GetData(string &out, int offset = 0, uint codePage = CP_UTF8);

    template <typename T> bool SetData(T &in, IJsonSerializer<T> *serializer) {
        string serialized = NULL;
        serializer.Serialize(in, serialized);
        return SetData(serialized);
    }
    template <typename T> bool SetData(T &in[], IJsonSerializer<T> *serializer) {
        string serialized = NULL;
        serializer.Serialize(in, serialized);
        return SetData(serialized);
    }
    template <typename T> bool GetData(T &out, IJsonSerializer<T> *serializer, int offset = 0) {
        string serialized;
        if (!GetData(serialized, offset)) return false;
        return serializer.Deserialize(serialized, out);
    }
    template <typename T> bool GetData(T &out[], IJsonSerializer<T> *serializer, int offset = 0) {
        string serialized;
        if (!GetData(serialized, offset)) return false;
        return serializer.Deserialize(serialized, out);
    }

    static int GetTopicLength(const string topic) {
        return StringLen(topic) + 1;
    }
    string GetTopic();
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Message::Message()
    : _message(0), _topicLength(0) {
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
bool Message::Insert(const string value, uint codePage = CP_UTF8) {
    uchar valueChars[];
    StringToCharArray(value, valueChars, 0, WHOLE_ARRAY, codePage);
    size_t size = ArraySize(valueChars);
    NngErrorCode errorCode = nng_msg_insert(_message, valueChars, size);
    return errorCode == NNG_SUCCESS;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Message::SetData(const string in, uint codePage = CP_UTF8) {
    int size = StringSizeInBytes(in, codePage);
    if (!Allocate(_topicLength + size)) return false;
    intptr_t body = GetBody();
    if (body == 0) return false;
    return StringToPointer(in, body, codePage);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Message::GetData(string &out, int offset = 0, uint codePage = CP_UTF8) {
    intptr_t body = GetBody();
    if (body == 0) return false;
    return PointerToString(body + offset, out, codePage);
}

//+------------------------------------------------------------------+
//| Gets the first string from the message body that is supposed to be the message topic.
//| Use only when the message is expected to have a topic.
//+------------------------------------------------------------------+
string Message::GetTopic() {
    intptr_t body = GetBody();
    string topic = NULL;
    PointerToString(body, topic, CP_UTF8);
    return topic;
}

//+------------------------------------------------------------------+
//| Called when the socket accepts the message for delivery.         |
//+------------------------------------------------------------------+
void Message::Release() {
    _message = 0;
}
//+------------------------------------------------------------------+
