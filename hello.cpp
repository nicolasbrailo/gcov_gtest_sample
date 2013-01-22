#include <iostream>
#include "hello.h"
#include "msg.h"

void Hello::say(const Msg* msg) {
	std::cout << msg->get_msg() << "\n";
}


