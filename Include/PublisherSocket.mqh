#include "SocketBase.mqh"
#include "SocketFactory.mqh"

class PublisherSocket : public SocketBase
{
public:
    PublisherSocket(): SocketBase(SocketFactory::OpenPublisherSocket) { }
    bool SendMessage(const string topic, Message &message);
};

bool PublisherSocket::SendMessage(const string topic, Message &message)
{
    if (!message.Insert(topic, CP_UTF8)) return false;
    return SocketBase::SendMessage(message);
}