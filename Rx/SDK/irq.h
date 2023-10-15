/*
 * irq.h
 *
 *  Created on: 20 Apr 2023
 *      Author: oldri
 */

#ifndef SRC_IRQ_H_
#define SRC_IRQ_H_

#include "xscugic.h"

#define INTC_DEVICE_ID		XPAR_SCUGIC_0_DEVICE_ID

#define INTC_DEVICE_INT_ID	XPAR_FABRIC_AXI_SLAVE_WRAPPER_0_IRQ_INTR

#define XSCUGIC_SPI_CPU_MASK	(XSCUGIC_SPI_CPU0_MASK << XPAR_CPU_ID)
#define XSCUGIC_SW_TIMEOUT_VAL	10000000U /* Wait for 10 sec */

int ScuGicExample(u16 DeviceId);
int SetUpInterruptSystem(XScuGic *XScuGicInstancePtr);
void DeviceDriverHandler(void *CallbackRef);
static void AssertPrint(const char8 *FilenamePtr, s32 LineNumber);

#endif /* SRC_IRQ_H_ */
