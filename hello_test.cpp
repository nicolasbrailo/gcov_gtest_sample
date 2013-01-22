#include <gtest/gtest.h>
#include <gmock/gmock.h>
using namespace testing;

#include "Hello.h"
#include "Msg.h"

class MockMsg : public Msg {
	public:
		MockMsg() : Msg("Dummy") {}
		MOCK_CONST_METHOD0(get_msg, const char *());
};

TEST( HelloWorld_test, Say ) {
	MockMsg msg;
	EXPECT_CALL( msg, get_msg() )
		.WillOnce(Return("Hola!"));

	Hello saludador;
	saludador.say(&msg);
}

