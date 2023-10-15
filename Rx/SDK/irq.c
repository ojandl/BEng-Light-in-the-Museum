/*
 * irq.c
 *
 *  Created on: 20 Apr 2023
 *      Author: oldri
 */


#include "irq.h"

volatile static u32 irq_flag = FALSE;

/************************** Variable Definitions *****************************/

XScuGic InterruptController; 	     /* Instance of the Interrupt Controller */
static XScuGic_Config *GicConfig;    /* The configuration parameters of the
                                       controller */

static void AssertPrint(const char8 *FilenamePtr, s32 LineNumber){
	xil_printf("ASSERT: File Name: %s ", FilenamePtr);
	xil_printf("Line Number: %d\r\n",LineNumber);
}


/*****************************************************************************/
 /**
 *
 * This function is an example of how to use the interrupt controller driver
 * (XScuGic) and the hardware device.  This function is designed to
 * work without any hardware devices to cause interrupts. It may not return
 * if the interrupt controller is not properly connected to the processor in
 * either software or hardware.
 *
 * This function relies on the fact that the interrupt controller hardware
 * has come out of the reset state such that it will allow interrupts to be
 * simulated by the software.
 *
 * @param	DeviceId is Device ID of the Interrupt Controller Device,
 *		typically XPAR_<INTC_instance>_DEVICE_ID value from
 *		xparameters.h
 *
 * @return	XST_SUCCESS to indicate success, otherwise XST_FAILURE
 *
 * @note		None.
 *
 ******************************************************************************/
 int ScuGicExample(u16 DeviceId)
 {
 	int Status;

 	/*
 	 * Initialize the interrupt controller driver so that it is ready to
 	 * use.
 	 */
 	GicConfig = XScuGic_LookupConfig(DeviceId);
 	if (NULL == GicConfig) {
 		return XST_FAILURE;
 	}

 	Status = XScuGic_CfgInitialize(&InterruptController, GicConfig,
 					GicConfig->CpuBaseAddress);
 	if (Status != XST_SUCCESS) {
 		return XST_FAILURE;
 	}


 	/*
 	 * Perform a self-test to ensure that the hardware was built
 	 * correctly
 	 */
 	Status = XScuGic_SelfTest(&InterruptController);
 	if (Status != XST_SUCCESS) {
 		return XST_FAILURE;
 	}


 	/*
 	 * Setup the Interrupt System
 	 */
 	Status = SetUpInterruptSystem(&InterruptController);
 	if (Status != XST_SUCCESS) {
 		return XST_FAILURE;
 	}

 	/*
 	 * Connect a device driver handler that will be called when an
 	 * interrupt for the device occurs, the device driver handler performs
 	 * the specific interrupt processing for the device
 	 */
 	Status = XScuGic_Connect(&InterruptController, INTC_DEVICE_INT_ID,
 			   (Xil_ExceptionHandler)DeviceDriverHandler,
 			   (void *)&InterruptController);

 	if (Status != XST_SUCCESS) {
 		return XST_FAILURE;
 	}


 	/*
 	 * Enable the interrupt for the device and then cause (simulate) an
 	 * interrupt so the handlers will be called
 	 */
 	XScuGic_Enable(&InterruptController, INTC_DEVICE_INT_ID);


 	return XST_SUCCESS;
 }

 /******************************************************************************/
 /**
 *
 * This function connects the interrupt handler of the interrupt controller to
 * the processor.  This function is separate to allow it to be customized for
 * each application.  Each processor or RTOS may require unique processing to
 * connect the interrupt handler.
 *
 * @param	XScuGicInstancePtr is the instance of the interrupt controller
 *		that needs to be worked on.
 *
 * @return	None.
 *
 * @note		None.
 *
 ****************************************************************************/
 int SetUpInterruptSystem(XScuGic *XScuGicInstancePtr)
 {

 	/*
 	 * Connect the interrupt controller interrupt handler to the hardware
 	 * interrupt handling logic in the ARM processor.
 	 */
 	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
 			(Xil_ExceptionHandler) XScuGic_InterruptHandler,
 			XScuGicInstancePtr);

 	/*
 	 * Enable interrupts in the ARM
 	 */
 	Xil_ExceptionEnable();

 	return XST_SUCCESS;
 }

