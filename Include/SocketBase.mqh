//+------------------------------------------------------------------+
//| Base class for all socket classes.                               |
//+------------------------------------------------------------------+
#property strict

#include "nng.mqh"
#include "SocketFactory.mqh"
#include "Message.mqh"

class SocketBase {
  private:
  protected:
    SocketBase(OpenSocketFunc func);
    ~SocketBase();
    nng_socket m_socket;
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
    if (errorCode != NNG_SUCCESS) {
        PrintFormat("(!) Error opening socket: %s", EnumToString(errorCode));
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SocketBase::~SocketBase() {
    if (!IsOpen()) return;

    NngErrorCode errorCode = nng_close(m_socket);
    if (errorCode != NNG_SUCCESS) {
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
    NngErrorCode errorCode = nng_listen(m_socket, url, listener, NNG_FLAG_NONE);
    return errorCode == NNG_SUCCESS;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SocketBase::Dial(const string endpoint) {
    char url[];
    StringToCharArray(endpoint, url);
    nng_listener dialer;
    NngErrorCode errorCode = nng_dial(m_socket, url, dialer, NNG_FLAG_NONE);
    return errorCode == NNG_SUCCESS;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SocketBase::SendMessage(Message &message) {
    NngErrorCode errorCode = nng_sendmsg(m_socket, message.Unwrap(), NNG_FLAG_NONE);
    if (errorCode == NNG_SUCCESS) {
        // the message is now owned by socket
        message.Release();
        return true;
    }
    Print("(!) Error sending message: %s", EnumToString(errorCode));
    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SocketBase::TrySendMessage(Message &message) {
    NngErrorCode errorCode = nng_sendmsg(m_socket, message.Unwrap(), NNG_FLAG_NONBLOCK);
    switch (errorCode) {
    case NNG_SUCCESS:
        // the message is now owned by socket
        message.Release();
        return true;
    case NNG_EAGAIN:
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
    nng_msg nngMsg;
    NngErrorCode errorCode = nng_recvmsg(m_socket, nngMsg, NNG_FLAG_NONE);
    if (errorCode == NNG_SUCCESS) {
        message = new Message(nngMsg);
        return true;
    }
    Print("(!) Error receiving message: %s", EnumToString(errorCode));
    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SocketBase::TryReceiveMessage(Message &message) {
    nng_msg nngMsg;
    NngErrorCode errorCode = nng_recvmsg(m_socket, nngMsg, NNG_FLAG_NONBLOCK);
    switch (errorCode) {
    case NNG_SUCCESS:
        message = new Message(nngMsg);
        return true;
    case NNG_EAGAIN:
        return false;
    default:
        Print("(!) Error trying to receive message: %s", EnumToString(errorCode));
        return false;
    }
}
//+------------------------------------------------------------------+
