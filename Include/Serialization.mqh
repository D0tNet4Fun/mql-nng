#property strict

#include <JAson.mqh>

template <typename T> interface IJsonSerializer {
    void Serialize(const T& in, string &out);
    void Serialize(const T& in[], string &out);
    bool Deserialize(const string &in, T &out);
    bool Deserialize(const string &in, T &out[]);
};

template <typename T> class JsonSerializerBase : public IJsonSerializer<T> {

  protected:
    virtual void Serialize(const T &in, CJAVal &json) = 0;
    virtual void Deserialize(CJAVal &json, T &out) = 0;

  public:
    void Serialize(const T &in, string &out) {
        CJAVal json;
        Serialize(in, json);
        json.Serialize(out);
    }
    void Serialize(const T &in[], string &out) {
        CJAVal json;
        for(int i = 0; i < ArraySize(in); i++) {
            CJAVal itemJson;
            T value = in[i];
            Serialize(value, itemJson);
            json.Add(itemJson);
        }
        json.Serialize(out);
    }
    bool Deserialize(const string &in, T &out) {
        CJAVal json;
        if (!json.Deserialize(in)) return false;
        ZeroMemory(out);
        Deserialize(json, out);
        return true;
    }
    bool Deserialize(const string &in, T &out[]) {
        CJAVal json;
        if (!json.Deserialize(in)) return false;
        ArrayResize(out, json.Size());
        for(int i = 0; i < ArraySize(out); i++) {
            CJAVal *itemJson = json[i];
            T item;
            ZeroMemory(item);
            Deserialize(itemJson, item);
            out[i] = item;
        }
        return true;
    }
};

class MqlTickSerializer : public JsonSerializerBase<MqlTick> {
  protected:
    void Serialize(const MqlTick &in, CJAVal &json) {
        json["ask"] = in.ask;
        json["bid"] = in.bid;
        //json["flags"] = in.flags;
        json["last"] = in.last;
        //json["time"] = (long)in.time;
        json["time_msc"] = in.time_msc;
        json["volume"] = (long)in.volume;
        json["volume_real"] = in.volume_real;
    }
    void Deserialize(CJAVal &json, MqlTick &out) {
        out.ask = json["ask"].ToDbl();
        out.bid = json["bid"].ToDbl();
        //out.flags = (uint)json["flags"].ToInt();
        out.last = json["last"].ToDbl();
        //out.time = json["time"];
        out.time_msc = json["time_msc"].ToInt();
        out.volume = json["volume"].ToInt();
        out.volume_real = json["volume_real"].ToDbl();
    }
};

class MqlTradeRequestSerializer : public JsonSerializerBase<MqlTradeRequest> {
  protected:
    void Serialize(const MqlTradeRequest &in, CJAVal &json) {
        json["action"] = (int)in.action;
        json["symbol"] = in.symbol;
        json["volume"] = in.volume;
        json["type"] = (int)in.type;
    }
    void Deserialize(CJAVal &json, MqlTradeRequest &out) {
        out.action = (ENUM_TRADE_REQUEST_ACTIONS)json["action"].ToInt();
        out.symbol = json["symbol"].ToStr();
        out.volume = json["volume"].ToDbl();
        out.type = (ENUM_ORDER_TYPE)json["type"].ToInt();
    }
};
