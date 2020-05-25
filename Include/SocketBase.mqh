//+------------------------------------------------------------------+
//| Base class for all socket classes.                               |
//+------------------------------------------------------------------+
#property strict

#include "nng.mqh"
#include "SocketFactory.mqh"
#include "Message.mqh"

class SocketBase {
  private:
    nng_socket m_socket;
  protected:
    SocketBase(OpenSocketFunc func);
    ~SocketBase();
  public:
    bool IsOpen();
    bool Listen(const string endpoint);
    bool Dial(const string endpoint);
    bool SendMessage(Message &message);
    bool TrySendMessage(Message &message);
    bool ReceiveMessage(Message &message);
    bool TryReceiveMessage(Message &message);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SocketBase::SocketBase(OpenSocketFunc func)
    : m_socket(0) {
    NngErrorCode errorCode = func(m_socket);
    if (errorCode != NngErrorCode::NNG_SUCCESS) {
        PrintFormat("(!) Error opening socket: %s", EnumToString(errorCode));
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SocketBase::~SocketBase() {
    if (!IsOpen()) return;

    NngErrorCode errorCode = nng_close(m_socket);
    if (errorCode != NngErrorCode::NNG_SUCCESS) {
        PrintFormat("(!) Error closing socket: %s", EnumToString(errorCode));
    } else {
        m_socket = 0;
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SocketBase::IsOpen() {
    return m_socket > 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SocketBase::Listen(const string endpoint) {
    char url[];
    StringToCharArray(endpoint, url);
    nng_listener listener;
    NngErrorCode errorCode = nng_listen(m_socket, url, listener, NngFlags::NNG_FLAG_NONE);
    return errorCode == NngErrorCode::NNG_SUCCESS;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SocketBase::Dial(const string endpoint) {
    char url[];
    StringToCharArray(endpoint, url);
    nng_listener dialer;
    NngErrorCode errorCode = nng_dial(m_socket, url, dialer, NngFlags::NNG_FLAG_NONE);
    return errorCode == NngErrorCode::NNG_SUCCESS;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SocketBase::SendMessage(Message &message) {
    NngErrorCode errorCode = nng_sendmsg(m_socket, message.Unwrap(), NngFlags::NNG_FLAG_NONE);
    if (errorCode == NngErrorCode::NNG_SUCCESS) {
        // the message is now owned by socket
        message.Dispose();
        return true;
    }
    Print("(!) Error sending message: %s", EnumToString(errorCode));
    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SocketBase::TrySendMessage(Message &message) {
    NngErrorCode errorCode = nng_sendmsg(m_socket, message.Unwrap(), NngFlags::NNG_FLAG_NONBLOCK);
    switch (errorCode) {
    case NngErrorCode::NNG_SUCCESS:
        // the message is now owned by socket
        message.Dispose();
        return true;
    case NngErrorCode::NNG_EAGAIN:
        return false;
    default:
        Print("(!) Error trying to send message: %s", EnumToString(errorCode));
        return false;
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SocketBase::ReceiveMessage(Message &message) {
    nng_msg msg;
    NngErrorCode errorCode = nng_recvmsg(m_socket, msg, NngFlags::NNG_FLAG_NONE);
    if (errorCode == NngErrorCode::NNG_SUCCESS) {
        message.Wrap(msg);
        return true;
    }
    Print("(!) Error trying to send message: %s", EnumToString(errorCode));
    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SocketBase::TryReceiveMessage(Message &message) {
    nng_msg msg;
    NngErrorCode errorCode = nng_recvmsg(m_socket, msg, NngFlags::NNG_FLAG_NONBLOCK);
    switch (errorCode) {
    case NngErrorCode::NNG_SUCCESS:
        message.Wrap(msg);
        return true;
    case NngErrorCode::NNG_EAGAIN:
        return false;
    default:
        Print("(!) Error trying to send message: %s", EnumToString(errorCode));
        return false;
    }
}
//+------------------------------------------------------------------+
