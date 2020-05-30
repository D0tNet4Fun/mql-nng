//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict

#include "TestRunner.mqh"
#include <Nng/Message.mqh>
#include <JAson.mqh>

struct PersonData {
    string Name;
    int Age;
};
struct Person : PersonData {
    PersonData Sibling;
};

class PersonSerializer : public JsonSerializerBase<Person> {
    public:
        bool Serialize(const Person& in, string &out) {
            Serialize(_json, (PersonData)in);
            CJAVal nestedJson;
            Serialize(nestedJson, (PersonData)in.Sibling);
            _json["sibling"].Set(nestedJson);
            return _Serialize(out);
        }
        bool Deserialize(const string &in, Person &out) {
            if (!_Deserialize(in, out)) return false;
            Deserialize(_json, (PersonData)out);
            CJAVal nestedJson = _json["sibling"];
            Deserialize(nestedJson, (PersonData)out.Sibling);
            return true;
        }
     private:
        void Serialize(CJAVal &json, PersonData &in) {
            json["name"] = in.Name;
            json["age"] = in.Age;
        }
        void Deserialize(CJAVal &json, PersonData &out) {
            out.Name = json["name"].ToStr();
            out.Age = json["age"].ToInt();
        }
};

TestRunner testRunner;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetPersonAndGetPerson() {
    Person p1;
    p1.Name = "John";
    p1.Age = 25;
    Person p2;
    p2.Name = "Tim";
    p2.Age = 23;
    p1.Sibling = p2;
        
    Message msg;

    PersonSerializer serializer;
    IJsonSerializer<Person> *serializerPtr = GetPointer(serializer);

    Assert(msg.SetData(p1, serializerPtr));

    Person outP1;
    Assert(msg.GetData(outP1, serializerPtr));
    Assert(outP1.Name == p1.Name);
    Assert(outP1.Age == p1.Age);
    Assert(outP1.Sibling.Name == p2.Name);
    Assert(outP1.Sibling.Age == p2.Age);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart() {
    SetPersonAndGetPerson();
};
//+------------------------------------------------------------------+
