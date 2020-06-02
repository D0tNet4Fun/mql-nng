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
  protected:
    void Serialize(const Person &in, CJAVal &json) {
        Serialize((PersonData)in, json);
        if (in.Sibling.Age > 0) { // null check
            CJAVal siblingJson;
            Serialize(in.Sibling, siblingJson);
            json["sibling"].Set(siblingJson);
        }
    }
    void Deserialize(CJAVal &json, Person &out) {
        Deserialize(json, (PersonData)out);
        CJAVal siblingJson = json["sibling"];
        Deserialize(siblingJson, (PersonData)out.Sibling);
    }
  private:
    void Serialize(const PersonData &in, CJAVal &json) {
        json["name"] = in.Name;
        json["age"] = in.Age;
    }
    void Deserialize(CJAVal &json, PersonData &out) {
        out.Name = json["name"].ToStr();
        out.Age = (int)json["age"].ToInt(); 
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

void SetPersonArrayAndGetPersonArray() {
    Person p1;
    p1.Name = "John";
    p1.Age = 25;
    Person p2;
    p2.Name = "Tim";
    p2.Age = 23;

    Message msg;

    PersonSerializer serializer;
    IJsonSerializer<Person> *serializerPtr = GetPointer(serializer);

    Person persons[2];
    persons[0] = p1;
    persons[1] = p2;

    Assert(msg.SetData(persons, serializerPtr));

    Person outPersons[];
    Assert(msg.GetData(outPersons, serializerPtr));
    Assert(2 == ArraySize(outPersons));
    Person outP1 = outPersons[0];
    Assert(outP1.Name == p1.Name);
    Assert(outP1.Age == p1.Age);
    Person outP2 = outPersons[1];
    Assert(outP2.Name == p2.Name);
    Assert(outP2.Age == p2.Age);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart() {
    SetPersonAndGetPerson();
    SetPersonArrayAndGetPersonArray();
};
//+------------------------------------------------------------------+
