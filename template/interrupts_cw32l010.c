/**
  ******************************************************************************
  * @file    interrupts_cw32l010.c
  * @author  CW32L010_SDK
  * @brief   中断处理函数模板
  * @note    ============ 使用方法 ============
  *          1. 本 SDK 的 startup_cw32l010.s 已为全部中断提供 weak 弱定义
  *             （统一跳 Default_Handler 死循环兜底），因此工程默认不需要
  *             本文件也能编译链接运行；
  *          2. 若需使用某中断：复制本模板（或直接在 main.c 中定义同名
  *             强符号函数），只保留用到的 Handler 并填入用户代码；
  *          3. 在 main 中使能对应外设中断 + NVIC（例：NVIC_EnableIRQ(...)）。
  *
  *          ============ 可用中断一览 ============
  *          WDT_IRQHandler        LVD_IRQHandler         RTC_IRQHandler
  *          FLASHRAM_IRQHandler   SYSCTRL_IRQHandler     GPIOA_IRQHandler
  *          GPIOB_IRQHandler      ADC_IRQHandler         ATIM_IRQHandler
  *          VC1_IRQHandler        VC2_IRQHandler         GTIM1_IRQHandler
  *          LPTIM_IRQHandler      BTIM1_IRQHandler       BTIM2_IRQHandler
  *          BTIM3_IRQHandler      I2C1_IRQHandler        SPI1_IRQHandler
  *          UART1_IRQHandler      UART2_IRQHandler       CLKFAULT_IRQHandler
  *
  *          ============ SysTick_Handler 注意 ============
  *          官方库 cw32l010_systick.c 已提供 __WEAK SysTick_Handler
  *          （内部 uwTick 递增，供 InitTick/GetTick/SysTickDelay 使用），
  *          startup 汇编刻意不为 SysTick_Handler 提供 weak 跳转版本，
  *          避免覆盖 C weak。请勿在本文件直接定义 SysTick_Handler 强符号；
  *          如需自定义，请参考官方例程 SysTick_HandlerCallback 回调方式。
  * @note    官方例程完整版见 Examples/NN_xxx/USER/src/interrupts_cw32l010.c
  ******************************************************************************
  */

#include "interrupts_cw32l010.h"

/* ============================ 示例（按需取消注释并填充） ===================== */

/*
void GPIOA_IRQHandler(void)
{
  // 用户代码：例如查询中断标志并执行操作
  // if (GPIO_GetITStatus(...) == SET) { ... }
}
*/

/******************************************************************************/
/*            Cortex-M0+ 内核异常兜底（startup 已有 weak，可强符号覆盖）        */
/******************************************************************************/
/* HardFault 建议保留实现便于调试（也可用 startup weak 死循环）：
void HardFault_Handler(void)
{
  while (1)
  {
  }
}
*/
