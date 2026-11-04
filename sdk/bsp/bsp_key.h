/**
  ******************************************************************************
  * @file    bsp_key.h
  * @author  CW32L010_SDK
  * @brief   板级按键驱动（默认 KEY2 = PA06，对应官方 gpio_int_default 例程）
  * @note    引脚可在本文件集中修改
  ******************************************************************************
  */

#ifndef __BSP_KEY_H
#define __BSP_KEY_H

#include "cw32l010.h"
#include "cw32l010_gpio.h"
#include "cw32l010_sysctrl.h"

/* 按键引脚配置（默认 KEY2 = PA06，按下为低电平） */
#define KEY_GPIO_PORT        CW_GPIOA
#define KEY_GPIO_PINS        GPIO_PIN_6
#define KEY_GPIO_CLK         SYSCTRL_AHB_PERIPH_GPIOA
#define KEY_PRESS_LEVEL      0        /* 按下时的电平：0=低电平有效 */

/* 读取按键电平：返回 1 表示按下 */
#define KEY_READ()           ((GPIO_ReadPin(KEY_GPIO_PORT, KEY_GPIO_PINS) == KEY_PRESS_LEVEL) ? 1 : 0)

void KEY_GPIO_Config(void);   /* 配置按键引脚为带上拉输入 */

#endif /* __BSP_KEY_H */
