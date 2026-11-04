/**
  ******************************************************************************
  * @file    bsp_key.c
  * @author  CW32L010_SDK
  * @brief   板级按键驱动实现
  ******************************************************************************
  */

#include "bsp_key.h"

/**
  * @brief  配置按键引脚为带上拉输入
  * @param  无
  * @retval 无
  */
void KEY_GPIO_Config(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};

  SYSCTRL_AHBPeriphClk_Enable(KEY_GPIO_CLK, ENABLE);

  GPIO_InitStruct.Pins = KEY_GPIO_PINS;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT_PULLUP;
  GPIO_InitStruct.IT   = GPIO_IT_NONE;
  GPIO_Init(KEY_GPIO_PORT, &GPIO_InitStruct);
}
