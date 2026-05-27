#define NOC_MEM_BASE 0x00080000

volatile unsigned int* NOC_REGS[16] = {
    (volatile unsigned int*)(NOC_MEM_BASE + 0x00),
    (volatile unsigned int*)(NOC_MEM_BASE + 0x04),
    (volatile unsigned int*)(NOC_MEM_BASE + 0x08),
    (volatile unsigned int*)(NOC_MEM_BASE + 0x0C),
    (volatile unsigned int*)(NOC_MEM_BASE + 0x10),
    (volatile unsigned int*)(NOC_MEM_BASE + 0x14),
    (volatile unsigned int*)(NOC_MEM_BASE + 0x18),
    (volatile unsigned int*)(NOC_MEM_BASE + 0x1C),
    (volatile unsigned int*)(NOC_MEM_BASE + 0x20),
    (volatile unsigned int*)(NOC_MEM_BASE + 0x24),
    (volatile unsigned int*)(NOC_MEM_BASE + 0x28),
    (volatile unsigned int*)(NOC_MEM_BASE + 0x2C),
    (volatile unsigned int*)(NOC_MEM_BASE + 0x30),
    (volatile unsigned int*)(NOC_MEM_BASE + 0x34),
    (volatile unsigned int*)(NOC_MEM_BASE + 0x38),
    (volatile unsigned int*)(NOC_MEM_BASE + 0x3C)
};