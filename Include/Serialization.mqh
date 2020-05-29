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

        bool _Deserialize(const string &in, MqlTick &out) {
            if (!_json.Deserialize(in)) return false;
            ZeroMemory(out);
            return true;
        }
};