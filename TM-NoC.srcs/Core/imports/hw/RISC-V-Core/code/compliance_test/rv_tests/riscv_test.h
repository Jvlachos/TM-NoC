// CUSTOM TEST FOR CS523

#define TEST_FUNC_NAME main

#ifndef TEST_FUNC_TXT
#  define TEST_FUNC_TXT "mytest"
#endif

#define RVTEST_RV64U
#define TESTNUM x28

#define RVTEST_CODE_BEGIN		\
        .data;                          \
        _test_name:                     \
        .ascii TEST_FUNC_TXT;           \
                                        \
	.text;				\
	.global TEST_FUNC_NAME;		\
TEST_FUNC_NAME:				\
        la      a0, _test_name;         \
        la      a2, _console_addr;      \
.prname_next:				\
	lb	a1,0(a0);		\
	beq	a1,zero,.prname_done;	\
	sw	a1,0(a2);		\
	addi	a0,a0,1;		\
	jal	zero,.prname_next;	\
.prname_done:				\
	addi	a1,zero,'.';		\
	sw	a1,0(a2);		\
	sw	a1,0(a2);		\
	sw	a1,0(a2);

#define RVTEST_PASS			\
        la      a0, _console_addr;      \
	addi	a1,zero,'O';		\
	addi	a2,zero,'K';		\
	addi	a3,zero,'\n';		\
	sw	a1,0(a0);		\
	sw	a2,0(a0);		\
	sw	a3,0(a0);		\
        add     a0,zero,zero;           \
        j       _exit_loop;

#define RVTEST_FAIL			\
        la      a0, _console_addr;      \
	addi	a1,zero,'E';		\
	addi	a2,zero,'R';		\
	addi	a3,zero,'O';		\
	addi	a4,zero,'\n';		\
	sw	a1,0(a0);		\
	sw	a2,0(a0);		\
	sw	a2,0(a0);		\
	sw	a3,0(a0);		\
	sw	a2,0(a0);		\
	sw	a4,0(a0);		\
        addi    a0,zero,1;              \
        j       _exit_loop;

#define RVTEST_CODE_END
#define RVTEST_DATA_BEGIN .balign 4;
#define RVTEST_DATA_END

