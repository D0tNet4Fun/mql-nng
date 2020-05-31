#property strict

#include <JAson.mqh>

template <typename T> interface IJsonSerializer {
    bool Serialize(const T& in, string &out);
    bool Deserialize(const string &in, T &out);
};

template <typename T> class JsonSerializerBase : public IJsonSerializer<T> {
    protected:
        CJAVal _json;

        bool _Serialize(string &out) {
            _json.Serialize(out);
            return true;
        }

        bool _Deserialize(const string &in, T &out) {
            if (!_json.Deserialize(in)) return false;
            ZeroMemory(out);
            return true;
        }
};

class MqlTickSerializer : public JsonSerializerBase<MqlTick> {
  public:
    bool Serialize(const MqlTick &in, string &out) {
        _json["ask"] = in.ask;
        _json["bid"] = in.bid;
        //_json["flags"] = in.flags;
        _json["last"] = in.last;
        //_json["time"] = (long)in.time;
        _json["time_msc"] = in.time_msc;
        _json["volume"] = (long)in.volume;
        _json["volume_real"] = in.volume_real;
        return _Serialize(out);
    }
    
    bool Deserialize(const string &in, MqlTick &out) {
        if (!_Deserialize(in, out)) return false;
        out.ask = _json["ask"].ToDbl();
        out.bid = _json["bid"].ToDbl();
        //out.flags = (uint)_json["flags"].ToInt();
        out.last = _json["last"].ToDbl();
        //out.time = _json["time"];
        out.time_msc = _json["time_msc"].ToInt();
        out.volume = _json["volume"].ToInt();
        out.volume_real = _json["volume_real"].ToDbl();
        return true;
    }
};

class MqlTradeRequestSerializer : public JsonSerializerBase<MqlTradeRequest> {
  public:
    bool Serialize(const MqlTradeRequest &in, string &out) {
        _json["action"] = (int)in.action;
        _json["symbol"] = in.symbol;
        _json["volume"] = in.volume;
        _json["type"] = (int)in.type;
        return _Serialize(out);
    }

    bool Deserialize(const string &in, MqlTradeRequest &out) {
        if (!_Deserialize(in, out)) return false;
        out.action = (ENUM_TRADE_REQUEST_ACTIONS)_json["action"].ToInt();
        out.symbol = _json["symbol"].ToStr();
        out.volume = _json["volume"].ToDbl();
        out.type = (ENUM_ORDER_TYPE)_json["type"].ToInt();
        return true;
    }
};