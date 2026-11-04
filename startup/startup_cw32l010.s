@*******************************************************************************
@* @file     startup_cw32l010.s
@* @brief    CW32L010 系列 Cortex-M0+ 启动文件（GNU as 语法，arm-none-eabi-gcc 使用）
@* @note     根据官方 MDK/IAR 启动文件移植：
@*           - 设置初始 SP
@*           - 设置初始 PC = Reset_Handler
@*           - 建立中断向量表（与官方一致，前 16 内核异常 + 32 外设中断）
@*           - 调用 SystemInit 后拷贝 .data / 清零 .bss，再进入 main
@*           复位后处理器处于线程模式、特权级、主栈。
@*******************************************************************************

  .syntax unified
  .cpu cortex-m0plus
  .fpu softvfp
  .thumb

.global  g_pfnVectors
.global  Default_Handler

@*******************************************************************************
@ Reset Handler：系统复位后执行的入口
@   1) 设置主栈指针 _estack（RAM 顶端）
@   2) 调用 SystemInit（官方库：加载 HSI/LSI TRIM、可选向量表重定位）
@   3) 拷贝 .data 段（FLASH → RAM）
@   4) 清零 .bss 段
@   5) 跳转 main（应用入口，永不返回）
@*******************************************************************************
  .section  .text.Reset_Handler
  .weak  Reset_Handler
  .type  Reset_Handler, %function
Reset_Handler:
  ldr   r0, =_estack           /* 设置栈指针 */
  mov   sp, r0

/* 调用系统初始化函数 SystemInit */
  bl  SystemInit

/* 拷贝 .data 段：源 _sidata（FLASH）→ 目的 _sdata.._edata（RAM）
   @note Cortex-M0+ 不支持 LDR/STR 后变址 [rn],#imm，使用 +4 显式增量 */
  ldr   r0, =_sdata
  ldr   r1, =_edata
  ldr   r2, =_sidata
  b     .copy_check
.copy_loop:
  ldr   r3, [r2]
  str   r3, [r0]
  adds  r0, r0, #4
  adds  r2, r2, #4
.copy_check:
  cmp   r0, r1
  bcc   .copy_loop

/* 清零 .bss 段：_sbss.._ebss */
  movs  r0, #0
  ldr   r1, =_sbss
  ldr   r2, =_ebss
  b     .zero_check
.zero_loop:
  str   r0, [r1]
  adds  r1, r1, #4
.zero_check:
  cmp   r1, r2
  bcc   .zero_loop

/* 跳转应用 main（永不返回） */
  bl  main

LoopForever:
  b LoopForever

.size  Reset_Handler, .-Reset_Handler

@*******************************************************************************
@ 默认异常处理：未使用的中断统一陷入死循环，便于调试
@*******************************************************************************
  .section  .text.Default_Handler,"ax",%progbits
Default_Handler:
Infinite_Loop:
  b  Infinite_Loop
  .size  Default_Handler, .-Default_Handler

@*******************************************************************************
@ 中断向量表（与官方启动文件一一对应）
@ 前 16 项为 Cortex-M0+ 内核异常，后 32 项为 CW32L010 外设中断（0~31）
@ 各中断名与官方 interrupts_cw32l010.h 声明完全一致
@*******************************************************************************
  .section  .isr_vector,"a",%progbits
  .type  g_pfnVectors, %object
  .size  g_pfnVectors, .-g_pfnVectors

g_pfnVectors:
  .word  _estack
  .word  Reset_Handler
  .word  NMI_Handler
  .word  HardFault_Handler
  .word  0                          /* Reserved */
  .word  0                          /* Reserved */
  .word  0                          /* Reserved */
  .word  0                          /* Reserved */
  .word  0                          /* Reserved */
  .word  0                          /* Reserved */
  .word  0                          /* Reserved */
  .word  SVC_Handler
  .word  0                          /* Reserved */
  .word  0                          /* Reserved */
  .word  PendSV_Handler
  .word  SysTick_Handler

  /* External Interrupts（CW32L010 外设中断，编号 0~31） */
  .word  WDT_IRQHandler            /* 0:  WDT                              */
  .word  LVD_IRQHandler            /* 1:  LVD                              */
  .word  RTC_IRQHandler            /* 2:  RTC                              */
  .word  FLASHRAM_IRQHandler       /* 3:  FLASH / RAM                      */
  .word  SYSCTRL_IRQHandler        /* 4:  SYSCTRL                          */
  .word  GPIOA_IRQHandler          /* 5:  GPIOA                            */
  .word  GPIOB_IRQHandler          /* 6:  GPIOB                            */
  .word  0                          /* 7:  Reserved                         */
  .word  0                          /* 8:  Reserved                         */
  .word  0                          /* 9:  Reserved                         */
  .word  0                          /* 10: Reserved                         */
  .word  0                          /* 11: Reserved                         */
  .word  ADC_IRQHandler            /* 12: ADC                              */
  .word  ATIM_IRQHandler           /* 13: ATIM                             */
  .word  VC1_IRQHandler            /* 14: VC1                              */
  .word  VC2_IRQHandler            /* 15: VC2                              */
  .word  GTIM1_IRQHandler          /* 16: GTIM1                            */
  .word  0                          /* 17: Reserved                         */
  .word  0                          /* 18: Reserved                         */
  .word  LPTIM_IRQHandler          /* 19: LPTIM                            */
  .word  BTIM1_IRQHandler          /* 20: BTIM1                            */
  .word  BTIM2_IRQHandler          /* 21: BTIM2                            */
  .word  BTIM3_IRQHandler          /* 22: BTIM3                            */
  .word  I2C1_IRQHandler           /* 23: I2C1                             */
  .word  0                          /* 24: Reserved                         */
  .word  SPI1_IRQHandler           /* 25: SPI1                             */
  .word  0                          /* 26: Reserved                         */
  .word  UART1_IRQHandler          /* 27: UART1                            */
  .word  UART2_IRQHandler          /* 28: UART2                            */
  .word  0                          /* 29: Reserved                         */
  .word  0                          /* 30: Reserved                         */
  .word  CLKFAULT_IRQHandler       /* 31: CLKFAULT                         */

@*******************************************************************************
@ 内核异常弱定义处理函数（可被用户强符号覆盖）
@   NMI/HardFault/SVC/PendSV：汇编弱定义，跳 Default_Handler 死循环
@   SysTick_Handler：不在此提供汇编弱定义！
@     官方库 cw32l010_systick.c 已提供 __WEAK C 版本（内部 uwTick 计数），
@     若此处保留汇编 weak（跳 Default_Handler），会因 startup.o 链接顺序在前
@     而覆盖 C weak 实现，导致 SysTickDelay/GetTick 失效
@     应用/例程可自定义强符号覆盖 C weak（如官方 interrupts_cw32l010.c）
@*******************************************************************************
  .section  .text.NMI_Handler
  .weak  NMI_Handler
  .type  NMI_Handler, %function
NMI_Handler:
  b  Default_Handler
  .size  NMI_Handler, .-NMI_Handler

  .section  .text.HardFault_Handler
  .weak  HardFault_Handler
  .type  HardFault_Handler, %function
HardFault_Handler:
  b  Default_Handler
  .size  HardFault_Handler, .-HardFault_Handler

  .section  .text.SVC_Handler
  .weak  SVC_Handler
  .type  SVC_Handler, %function
SVC_Handler:
  b  Default_Handler
  .size  SVC_Handler, .-SVC_Handler

  .section  .text.PendSV_Handler
  .weak  PendSV_Handler
  .type  PendSV_Handler, %function
PendSV_Handler:
  b  Default_Handler
  .size  PendSV_Handler, .-PendSV_Handler

@*******************************************************************************
@ 外设中断弱定义处理函数（可被用户强符号覆盖）
@   官方例程自带 interrupts_cw32l010.c（强符号空实现/用户实现），
@   可覆盖下面这些 weak 跳转；二者同时存在时强符号生效
@*******************************************************************************
  .macro  def_irq_handler  handler_name
  .section  .text.\handler_name
  .weak  \handler_name
  .type  \handler_name, %function
\handler_name:
  b  Default_Handler
  .size  \handler_name, .-\handler_name
  .endm

  def_irq_handler  WDT_IRQHandler
  def_irq_handler  LVD_IRQHandler
  def_irq_handler  RTC_IRQHandler
  def_irq_handler  FLASHRAM_IRQHandler
  def_irq_handler  SYSCTRL_IRQHandler
  def_irq_handler  GPIOA_IRQHandler
  def_irq_handler  GPIOB_IRQHandler
  def_irq_handler  ADC_IRQHandler
  def_irq_handler  ATIM_IRQHandler
  def_irq_handler  VC1_IRQHandler
  def_irq_handler  VC2_IRQHandler
  def_irq_handler  GTIM1_IRQHandler
  def_irq_handler  LPTIM_IRQHandler
  def_irq_handler  BTIM1_IRQHandler
  def_irq_handler  BTIM2_IRQHandler
  def_irq_handler  BTIM3_IRQHandler
  def_irq_handler  I2C1_IRQHandler
  def_irq_handler  SPI1_IRQHandler
  def_irq_handler  UART1_IRQHandler
  def_irq_handler  UART2_IRQHandler
  def_irq_handler  CLKFAULT_IRQHandler

@*******************************************************************************
@ 结束
@*******************************************************************************
  .end
