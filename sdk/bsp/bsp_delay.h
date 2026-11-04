/**
  ******************************************************************************
  * @file    bsp_delay.h
  * @author  CW32L010_SDK
  * @brief   基于 SysTick 自由运行计数的忙等延时头文件
  * @note    不复用官方库 cw32l010_systick 的中断 tick（避免与应用自带
  *          SysTick_Handler 相互干扰），而是自行将 SysTick 配置为
  *          1ms 自由运行计数（不使能中断），基于 SysTick->VAL 忙等实现，
  *          无需任何中断支持、与例程自带中断模板互不干扰。
  ******************************************************************************
  */
#ifndef __BSP_DELAY_H
#define __BSP_DELAY_H

#include "cw32l010.h"

void bsp_delay_init(uint32_t hclk);   /* 初始化 1ms 自由运行计数，hclk=系统时钟 Hz */
void bsp_delay_ms(uint32_t ms);       /* 毫秒忙等延时 */
void bsp_delay_us(uint32_t us);       /* 微秒忙等延时 */

#endif /* __BSP_DELAY_H */
