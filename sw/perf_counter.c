
#include "perf_counter.h"

#ifdef FPGA_TARGET
void pf_reset_all_counters(void)
{
	putfsl(RST_ALL, PERF_COUNTER_FSL_ID);
}

void pf_reset_counter(uint32_t id)
{
	putfsl(((id << ID_BIT_SHIFT) | RST_ID), PERF_COUNTER_FSL_ID);
}

void pf_start_counter(uint32_t id)
{
	putfsl(((id << ID_BIT_SHIFT) | START_ID), PERF_COUNTER_FSL_ID);
}

void pf_stop_counter(uint32_t id)
{
	putfsl(((id << ID_BIT_SHIFT) | STOP_ID), PERF_COUNTER_FSL_ID);
}

uint32_t pf_read_counter(uint32_t id)
{
	uint32_t lo_word = 0;
	uint32_t hi_word = 0;
	putfsl(((id << ID_BIT_SHIFT) | READ_ID), PERF_COUNTER_FSL_ID);
	getfsl(hi_word, PERF_COUNTER_FSL_ID);
	getfsl(lo_word, PERF_COUNTER_FSL_ID);

	/* TODO: Handle the high-word */
	return hi_word;
}
#else

static uint64_t rdtsc()
{
    uint32_t lo, hi;
    __asm__ __volatile__ (
      "xorl %%eax, %%eax\n"
      "cpuid\n"
      "rdtsc\n"
      : "=a" (lo), "=d" (hi)
      :
      : "%ebx", "%ecx");
    return (uint64_t)hi << 32 | lo;
}

uint64_t start[TMR_ARRAY_LEN];
uint64_t end[TMR_ARRAY_LEN];


void pf_reset_all_counters(void)
{
	uint32_t i = 0;

	for (i = 0; i < TMR_ARRAY_LEN; i++) {
		start[i] = 0;
		end[i] = 0;
	}
}

void pf_reset_counter(uint32_t id)
{
	start[id] = 0;
	end[id] = 0;
}

void pf_start_counter(uint32_t id)
{
	start[id] = rdtsc();
}

void pf_stop_counter(uint32_t id)
{
	end[id] = rdtsc();
}

uint32_t pf_read_counter(uint32_t id)
{
	/* TODO: Handle the high-word */
	return (uint32_t) (end[id] - start[id]);
}

#endif
