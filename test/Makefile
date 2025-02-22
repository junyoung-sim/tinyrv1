HW_DIR   := $(TINYRV1)/hw
TEST_DIR := $(TINYRV1)/test

TESTS := $(wildcard $(TEST_DIR)/Proc_*_test.v)
EXECS := $(patsubst %.v, %, $(TESTS))

IVERILOG       := iverilog
IVERILOG_FLAGS := -Wall -g2012 -I $(HW_DIR)

all: $(EXECS)

$(EXECS): %: %.v
	$(IVERILOG) $(IVERILOG_FLAGS) -o $@ $<

%_test: $(TEST_DIR)/%_test.v
	$(IVERILOG) $(IVERILOG_FLAGS) -o $@ $<

clean:
	rm -f $(EXECS)