//+------------------------------------------------------------------+
//| NNG interop.                                                     |
//+------------------------------------------------------------------+
#property strict

#include "native.mqh"

#define nng_socket uint
#define nng_listener uint
#define nng_dialer uint
#define nng_msg intptr_t

enum NngErrorCode {
    NNG_SUCCESS = 0,
    NNG_EINTR = 1,
    NNG_ENOMEM = 2,
    NNG_EINVAL = 3,
    NNG_EBUSY = 4,
    NNG_ETIMEDOUT = 5,
    NNG_ECONNREFUSED = 6,
    NNG_ECLOSED = 7,
    NNG_EAGAIN = 8,
    NNG_ENOTSUP = 9,
    NNG_EADDRINUSE = 10,
    NNG_ESTATE = 11,
    NNG_ENOENT = 12,
    NNG_EPROTO = 13,
    NNG_EUNREACHABLE = 14,
    NNG_EADDRINVAL = 15,
    NNG_EPERM = 16,
    NNG_EMSGSIZE = 17,
    NNG_ECONNABORTED = 18,
    NNG_ECONNRESET = 19,
    NNG_ECANCELED = 20,
    NNG_ENOFILES = 21,
    NNG_ENOSPC = 22,
    NNG_EEXIST = 23,
    NNG_EREADONLY = 24,
    NNG_EWRITEONLY = 25,
    NNG_ECRYPTO = 26,
    NNG_EPEERAUTH = 27,
    NNG_ENOARG = 28,
    NNG_EAMBIGUOUS = 29,
    NNG_EBADTYPE = 30,
    NNG_ECONNSHUT = 31,
    NNG_EINTERNAL = 1000,
    NNG_ESYSERR = 0x10000000,
    NNG_ETRANERR = 0x20000000
};

enum NngFlags {
    NNG_FLAG_NONE = 0,
    NNG_FLAG_ALLOC = 1, // Recv to allocate receive buffer.
    NNG_FLAG_NONBLOCK = 2  // Non-blocking operations.
};

// protocol options
const string NNG_OPT_SUB_SUBSCRIBE = "sub:subscribe";
const string NNG_OPT_SUB_UNSUBSCRIBE = "sub:unsubscribe";

#import "nng.dll"

// socket functions
NngErrorCode nng_close(nng_socket s);

// connection management
NngErrorCode nng_listen(nng_socket s, const char &url[], nng_listener &lp, NngFlags flags);
NngErrorCode nng_dial(nng_socket s, const char &url[], nng_dialer &dp, NngFlags flags);

// message functions
NngErrorCode nng_msg_alloc(nng_msg &msgp, size_t size);
NngErrorCode nng_msg_insert(nng_msg msg, const char &value[], size_t size);
intptr_t nng_msg_body(nng_msg msg);
void nng_msg_free(nng_msg msg);
size_t nng_msg_len(nng_msg msg);
NngErrorCode nng_sendmsg(nng_socket s, nng_msg msg, NngFlags flags);
NngErrorCode nng_recvmsg(nng_socket s, nng_msg &msgp, NngFlags flags);

// protocol functions
NngErrorCode nng_bus0_open(nng_socket &s);
NngErrorCode nng_pair0_open(nng_socket &s);
NngErrorCode nng_pair1_open(nng_socket &s);
NngErrorCode nng_pub0_open(nng_socket &s);
NngErrorCode nng_pull0_open(nng_socket &s);
NngErrorCode nng_push0_open(nng_socket &s);
NngErrorCode nng_rep0_open(nng_socket &s);
NngErrorCode nng_req0_open(nng_socket &s);
NngErrorCode nng_respondent0_open(nng_socket &s);
NngErrorCode nng_sub0_open(nng_socket &s);
NngErrorCode nng_surveyor0_open(nng_socket &s);

// options functions
NngErrorCode nng_socket_set_string(nng_socket s, const char &option[], const char &value[]);

#import
//+------------------------------------------------------------------+
