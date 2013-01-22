# Set a compile type
ifndef COMPILE_TYPE
	COMPILE_TYPE := dev
endif

ifeq ($(COMPILE_TYPE), dev)
	# No optimization, inclde debug symbols, compile objs for unit testing
	CXXFLAGS += -O0 -Wall -g3 -DTEST_VIRTUAL=virtual
endif
ifeq ($(COMPILE_TYPE), code_coverage)
	# Use to create coverage tests
	CXXFLAGS += -O0 -Wall -g3 -DTEST_VIRTUAL=virtual -fprofile-arcs -ftest-coverage --coverage
	LDFLAG += --coverage -lgcov
endif

static_analysis:
	rm -rf static_analysis.xml static_analysis verapp verapp.xml cppcheck.xml 
	cppcheck --xml -v -a . 2>cppcheck.xml
	find | egrep '\.(cpp|cc|h|hpp)$$' | \
			egrep -v 'IFC|tests' | \
			xargs ~/.vera++/vera++ 2>verapp
	cat verapp | awk -F':' '{print "<error file=\""$$1"\" line=\""$$2"\" id=\"style\" severity=\"style\" msg=\""$$3"\"/>"}' > verapp.xml
	cat cppcheck.xml | grep "error file=" > static_analysis || true
	cat verapp.xml >> static_analysis
	rm -rf verapp verapp.xml cppcheck.xml
	echo "<?xml version="1.0"?><results>" > static_analysis.xml
	cat static_analysis | sort >> static_analysis.xml
	echo "</results>" >> static_analysis.xml
	rm -f static_analysis

	

%.o: %.cpp %.h
	$(COMPILE.cpp) -o $@ $<

hello: main.cpp hello.o
	$(LINK.cpp) $^ -o $@ 

all: hello

.PHONY: clean test coverage_report
clean:
	rm -rf hello hello.o

# Find all sources with available tests
TEST_SRCS := $(patsubst ./%, %, $(shell find|egrep "_test\.cpp$$") )
TEST_BINS := $(patsubst %.cpp, %, $(TEST_SRCS))

test:
	@# Run all tests
	for TEST in $(TEST_BINS); do \
		make "$$TEST"_run; \
	done

%_test: %_test.cpp
	@# Compile the source and link with the real .o
	g++ $(CXXFLAGS) $(LDFLAGS) \
		-lgtest_main -lgmock -o $@ \
			$(patsubst %_test.cpp, %.o, $<) \
			$< 

%_test_run: %_test
	@# Zomg magic magic - this will make the test and then run it
	./$<

coverage_report:
	# Reset code coverage counters and clean up previous reports
	rm -rf coverage_report; 
	lcov --zerocounters --directory .
	$(MAKE) clean
	$(MAKE) COMPILE_TYPE=code_coverage &&\
		$(MAKE) COMPILE_TYPE=code_coverage test
	lcov --capture --directory . --base-directory . -o salida.out &&\
	lcov --remove salida.out "*usr/include*" -o salida.out &&\
	genhtml -o coverage_report salida.out
	rm salida.out
	

