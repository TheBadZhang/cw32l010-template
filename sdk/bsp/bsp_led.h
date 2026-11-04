/**
  ******************************************************************************
  * @file    bsp_led.h
  * @author  CW32L010_SDK
  * @brief   板级 LED 驱动（默认 PB02，对应官方 gpio_blink 例程 LED2）
  * @note    引脚可在本文件集中修改
  ******************************************************************************
  */

#ifndef __BSP_LED_H
#define __BSP_LED_H

#include "cw32l010.h"
#include "cw32l010_gpio.h"
#include "cw32l010_sysctrl.h"

/* LED 引脚配置（默认 PB02 = 官方例程 LED2） */
#define LED_GPIO_PORT        CW_GPIOB
#define LED_GPIO_PINS        GPIO_PIN_2
#define LED_GPIO_CLK         SYSCTRL_AHB_PERIPH_GPIOB
#define LED_ON_LEVEL         1      /* 输出高电平点亮（GPIO_WritePin/GPIO_SetBits 风格） */

/* 便捷宏：点亮/熄灭/翻转（低电平点亮板请把 ON_LEVEL 改 0） */
#define LED_ON()             GPIO_WritePin(LED_GPIO_PORT, LED_GPIO_PINS, GPIO_Pin_SET)
#define LED_OFF()            GPIO_WritePin(LED_GPIO_PORT, LED_GPIO_PINS, GPIO_Pin_RESET)
#define LED_TOGGLE()         GPIO_TogglePin(LED_GPIO_PORT, LED_GPIO_PINS)

/* 固件库风格带参宏 */
#define LEDn(PinState)       GPIO_WritePin(LED_GPIO_PORT, LED_GPIO_PINS, (PinState))

void LED_GPIO_Config(void);   /* 配置 LED 引脚为推挽输出 */

#endif /* __BSP_LED_H */
