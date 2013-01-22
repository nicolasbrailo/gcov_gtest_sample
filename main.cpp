#include "hello.h"
#include "msg.h"

int main() {
	Msg msg("Hi world!");
	Hello world;
	world.say(&msg);
	return 0;
}

