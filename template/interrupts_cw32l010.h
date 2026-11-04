/**
  ******************************************************************************
  * @file    interrupts_cw32l010.h
  * @author  CW32L010_SDK
  * @brief   中断处理函数声明模板
  * @note    启动文件 startup_cw32l010.s 已为全部异常/中断提供 weak 定义
  *          （统一跳 Default_Handler 死循环），因此工程默认不需要本文件也能
  *          链接运行。若需使用某中断：
  *          1) 复制本模板到工程（或直接在 main.c 中定义同名强符号）
  *          2) 只保留/定义用到的 Handler
  *          3) 在 main 中使能对应外设中断 + NVIC
  * @note    SysTick_Handler：官方库 cw32l010_systick.c 已提供 __WEAK 实现
  *          （内部 uwTick 自增，供 InitTick/GetTick/SysTickDelay 使用）。
  *          若此处强定义 SysTick_Handler，需自行维护 tick（参考官方例程
  *          SysTick_HandlerCallback 方案）。
  ******************************************************************************
  */
#ifndef __INTERRUPTS_CW32L010_H
#define __INTERRUPTS_CW32L010_H

#ifdef __cplusplus
extern "C" {
#endif

/* 内核异常 */
void NMI_Handler(void);
void HardFault_Handler(void);
void SVC_Handler(void);
void PendSV_Handler(void);
void SysTick_Handler(void);

/* CW32L010 外设中断（与 cw32l010.h IRQn_Type / startup 向量表一一对应） */
void WDT_IRQHandler(void);
void LVD_IRQHandler(void);
void RTC_IRQHandler(void);
void FLASHRAM_IRQHandler(void);
void SYSCTRL_IRQHandler(void);
void GPIOA_IRQHandler(void);
void GPIOB_IRQHandler(void);
void ADC_IRQHandler(void);
void ATIM_IRQHandler(void);
void VC1_IRQHandler(void);
void VC2_IRQHandler(void);
void GTIM1_IRQHandler(void);
void LPTIM_IRQHandler(void);
void BTIM1_IRQHandler(void);
void BTIM2_IRQHandler(void);
void BTIM3_IRQHandler(void);
void I2C1_IRQHandler(void);
void SPI1_IRQHandler(void);
void UART1_IRQHandler(void);
void UART2_IRQHandler(void);
void CLKFAULT_IRQHandler(void);

#ifdef __cplusplus
}
#endif

#endif /* __INTERRUPTS_CW32L010_H */
