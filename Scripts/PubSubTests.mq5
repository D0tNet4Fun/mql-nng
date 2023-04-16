//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict

#include <Nng\Sockets.mqh>
#include <Nng\PublisherSocket.mqh>
#include <Nng\SubscriberSocket.mqh>
#include <Nng\Message.mqh>
#include "TestRunner.mqh"

TestRunner testRunner;

void PubSub_WhenNotSubscribedToAnyTopic_DoesNotReceiveMessage() {
    // setup pub and sub sockets
    string endpoint = "inproc://" + __FUNCTION__;
    PublisherSocket pub;
    Assert(pub.Listen(endpoint));
    SubscriberSocket sub;
    Assert(sub.Dial(endpoint));    

    // send message for topic
    const string topic = "any topic";
    Message msg;
    Assert(msg.SetData("hello"));
    Assert(pub.SendMessage(topic, msg));

    // try to receive message
    Message receivedMsg;
    Assert(false == sub.TryReceiveMessage(receivedMsg));
}

void PubSub_WhenSubscribedToAllTopics_ReceivesAllMessages() {
    // setup pub and sub sockets
    string endpoint = "inproc://" + __FUNCTION__;
    PublisherSocket pub;
    Assert(pub.Listen(endpoint));
    SubscriberSocket sub;
    Assert(sub.Dial(endpoint));

    // subscribe to all topics
    Assert(sub.SubscribeAll());

    // send message for topic
    const string topic = "any topic";
    Message msg;
    Assert(msg.SetData("hello"));
    Assert(pub.SendMessage(topic, msg));

    // try to receive message
    Message receivedMsg;
    Assert(sub.TryReceiveMessage(receivedMsg));
    string data;
    Assert(topic == receivedMsg.GetTopic());
    Assert(receivedMsg.GetData(data, Message::GetTopicLength(topic)));
    Assert(data == "hello");
}

void PubSub_WhenMessageDoesNotHaveTopic_ReceivesMessage() {
    // setup pub and sub sockets
    string endpoint = "inproc://" + __FUNCTION__;
    PublisherSocket pub;
    Assert(pub.Listen(endpoint));
    SubscriberSocket sub;
    Assert(sub.Dial(endpoint));

    // subscribe to all topics
    Assert(sub.SubscribeAll());

    // send message with no topic
    Message msg;
    Assert(msg.SetData("hello"));
    Assert(pub.SendMessage(msg));

    // try to receive message
    Message receivedMsg;
    Assert(sub.TryReceiveMessage(receivedMsg));
    string data;
    Assert(receivedMsg.GetData(data));
    Assert(data == "hello");
}

void PubSub_WhenSubscribedToOneTopic_ReceivesFilteredMessages() {
    // setup pub and sub sockets
    string endpoint = "inproc://" + __FUNCTION__;
    PublisherSocket pub;
    Assert(pub.Listen(endpoint));
    SubscriberSocket sub;
    Assert(sub.Dial(endpoint));

    // subscribe to one topic (topic1)
    const string topic1 = "topic1";
    const string topic2 = "topic2";
    Assert(sub.Subscribe(topic1));

    // send message for topic1
    Message msg1;
    Assert(msg1.SetData("hello"));
    Assert(pub.SendMessage(topic1, msg1));

    // receive message
    Message receivedMsg;
    Assert(sub.TryReceiveMessage(receivedMsg));

    // send another message for topic2
    Message msg2;
    Assert(msg2.SetData("hello"));
    Assert(pub.SendMessage(topic2, msg2));

    // try to receive message 2
    Message receivedMsg2;
    Assert(false == sub.TryReceiveMessage(receivedMsg2));
}

void PubSub_WhenMultipleSubscribers_TheyAllReceiveMessages() {
    // setup pub and sub sockets
    string endpoint = "inproc://" + __FUNCTION__;
    PublisherSocket pub;
    Assert(pub.Listen(endpoint));
    SubscriberSocket sub1;
    Assert(sub1.Dial(endpoint));
    SubscriberSocket sub2;
    Assert(sub2.Dial(endpoint));

    // subscribe to one topic (topic1)
    const string topic1 = "topic1";
    Assert(sub1.Subscribe(topic1));
    Assert(sub2.Subscribe(topic1));

    // send message #1 for topic1
    Message msg1;
    Assert(msg1.SetData("hello"));
    Assert(pub.SendMessage(topic1, msg1));

    // sub 1 receive message #1
    string data;
    Message receivedMsg11;
    Assert(sub1.TryReceiveMessage(receivedMsg11));
    Assert(receivedMsg11.GetData(data, Message::GetTopicLength(topic1)));
    Assert("hello" == data);

    // sub 2 receive message #1
    Message receivedMsg12;
    Assert(sub2.TryReceiveMessage(receivedMsg12));
    Assert(receivedMsg12.GetData(data, Message::GetTopicLength(topic1)));
    Assert("hello" == data);

    // send another message for topic2 (but no subscriptions)
    const string topic2 = "topic2";
    Message msg2;
    Assert(msg2.SetData("hello"));
    Assert(pub.SendMessage(topic2, msg2));

    // try to receive message #2
    Message receivedMsg2;
    Assert(false == sub1.TryReceiveMessage(receivedMsg2));
    Assert(false == sub2.TryReceiveMessage(receivedMsg2));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart() {
    PubSub_WhenNotSubscribedToAnyTopic_DoesNotReceiveMessage();
    PubSub_WhenSubscribedToAllTopics_ReceivesAllMessages();
    PubSub_WhenMessageDoesNotHaveTopic_ReceivesMessage
    PubSub_WhenSubscribedToOneTopic_ReceivesFilteredMessages();
    PubSub_WhenMultipleSubscribers_TheyAllReceiveMessages();
}
//+------------------------------------------------------------------+
