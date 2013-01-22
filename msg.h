#ifndef MSG_H_INCLUDED__
#define MSG_H_INCLUDED__

#include <string>

class Msg {
	std::string msg;
	public:
		Msg(const char* msg) : msg(msg) {}
		virtual const char *get_msg() const { return msg.c_str(); }
};

#endif /* MSG_H_INCLUDED__ */
