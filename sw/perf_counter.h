
#ifndef PERF_COUNTER_H_
#define PERF_COUNTER_H_

#include <stdint.h>

#ifdef FPGA_TARGET
#include <mb_interface.h>
#else
#define TMR_ARRAY_LEN 4
#endif

#define PERF_COUNTER_FSL_ID 0
#define ID_BIT_SHIFT	3

#define RST_ALL			0x0
#define RST_ID			0x1
#define START_ID		0x2
#define STOP_ID			0x3
#define READ_ID			0x4

void pf_reset_all_counters(void);
void pf_reset_counter(uint32_t id);
void pf_start_counter(uint32_t id);
void pf_stop_counter(uint32_t id);
uint32_t pf_read_counter(uint32_t id);


#endif /* PERF_COUNTER_H_ */
