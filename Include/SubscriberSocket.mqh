#include "nng.mqh"
#include "SocketBase.mqh"
#include "SocketFactory.mqh"

class SubscriberSocket : public SocketBase
{
public:
    SubscriberSocket(): SocketBase(SocketFactory::OpenSubscriberSocket) { }
    bool SubscribeAll();
    bool Subscribe(const string topic);
    bool Unsubscribe(const string topic);
};

bool SubscriberSocket::SubscribeAll()
{
    return Subscribe(NULL);
}

bool SubscriberSocket::Subscribe(const string topic)
{
    uchar optionChars[];
    StringToCharArray(NNG_OPT_SUB_SUBSCRIBE, optionChars);
    uchar topicChars[];
    StringToCharArray(topic, topicChars);
    NngErrorCode errorCode = nng_socket_set_string(m_socket, optionChars, topicChars);
    return errorCode == NNG_SUCCESS;
}

bool SubscriberSocket::Unsubscribe(const string topic)
{
    uchar optionChars[];
    StringToCharArray(NNG_OPT_SUB_UNSUBSCRIBE, optionChars);
    uchar topicChars[];
    StringToCharArray(topic, topicChars);
    NngErrorCode errorCode = nng_socket_set_string(m_socket, optionChars, topicChars);
    return errorCode == NNG_SUCCESS;
}