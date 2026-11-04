/**
  ******************************************************************************
  * @file    bsp_led.c
  * @author  CW32L010_SDK
  * @brief   板级 LED 驱动实现
  ******************************************************************************
  */

#include "bsp_led.h"

/**
  * @brief  配置 LED 引脚为推挽输出
  * @param  无
  * @retval 无
  */
void LED_GPIO_Config(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};

  /* 使能 GPIO 外设时钟（SYSCTRL 寄存器写保护需要 KEY 解锁，库函数内部处理） */
  SYSCTRL_AHBPeriphClk_Enable(LED_GPIO_CLK, ENABLE);

  GPIO_InitStruct.Pins = LED_GPIO_PINS;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.IT   = GPIO_IT_NONE;
  GPIO_Init(LED_GPIO_PORT, &GPIO_InitStruct);

  LED_OFF();
}
