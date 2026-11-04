/**
  ******************************************************************************
  * @file    bsp_delay.c
  * @author  CW32L010_SDK
  * @brief   基于 SysTick 自由运行计数的忙等延时
  * @note    设计要点：
  *          - 不复用官方库 cw32l010_systick 的 InitTick/SysTick_Handler，
  *            避免与应用自带 SysTick_Handler（官方 interrupts 模板）冲突
  *          - 直接配置 SysTick 为 1ms 自由运行计数（不使能 TICKINT 中断）
  *          - delay_us/delay_ms 基于 SysTick->VAL 递减忙等，不依赖任何中断
  ******************************************************************************
  */

#include "bsp_delay.h"

static uint32_t s_fac_us = 0;   /* 每 us 的 SysTick 计数（= HCLK / 1MHz） */

/**
  * @brief  配置 SysTick 为 1ms 自由运行计数（关闭中断）
  * @param  hclk：系统时钟频率 Hz（M0+ 中 SysTick 时钟固定 = HCLK）
  * @retval 无
  */
void bsp_delay_init(uint32_t hclk)
{
  s_fac_us = hclk / 1000000U;                 /* 每微秒计数 */
  if (s_fac_us == 0)
  {
    s_fac_us = 1;
  }
  SysTick->LOAD = hclk / 1000U - 1U;          /* 1ms 重载周期 */
  SysTick->VAL  = 0U;
  SysTick->CTRL = SysTick_CTRL_CLKSOURCE_Msk | SysTick_CTRL_ENABLE_Msk;   /* 不使能中断 */
}

/**
  * @brief  微秒级忙等延时
  * @param  us：延时微秒数
  * @retval 无
  */
void bsp_delay_us(uint32_t us)
{
  uint32_t ticks, reload, t0, now, elapsed = 0;

  if (us == 0)
  {
    return;
  }
  ticks  = us * s_fac_us;          /* 目标计数 */
  reload = SysTick->LOAD + 1U;     /* 一个重载周期的计数（1ms） */
  t0     = SysTick->VAL;

  while (elapsed < ticks)
  {
    now = SysTick->VAL;
    if (now != t0)
    {
      if (now < t0)
      {
        elapsed += t0 - now;               /* 未跨重载点 */
      }
      else
      {
        elapsed += reload - now + t0;      /* 跨重载点（回绕补偿） */
      }
      t0 = now;
    }
  }
}

/**
  * @brief  毫秒级忙等延时（循环调用 us 延时，简单可靠）
  * @param  ms：延时毫秒数
  * @retval 无
  */
void bsp_delay_ms(uint32_t ms)
{
  while (ms--)
  {
    bsp_delay_us(1000U);
  }
}
