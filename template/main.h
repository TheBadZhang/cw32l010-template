/**
  ******************************************************************************
  * @file    main.h
  * @author  CW32L010_SDK
  * @brief   应用模板主头文件
  * @note    进入 main 前，系统时钟尚未配置（CW32L010 官方 SystemInit 仅加载
  *          HSI/LSI TRIM 校准，不配置时钟），需在 main 开头显式配置时钟，
  *          例如 SYSCTRL_HSI_Enable(SYSCTRL_HSIOSC_DIV6) → 8MHz
  ******************************************************************************
  */

#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "cw32l010.h"
#include "cw32l010_sysctrl.h"
#include "cw32l010_systick.h"
#include "system_cw32l010.h"
#include "define.h"
#include "bsp_led.h"
#include "bsp_uart.h"
#include "bsp_delay.h"
#include "interrupts_cw32l010.h"

/* Private defines -----------------------------------------------------------*/
/* USER CODE BEGIN PD */
/* USER CODE END PD */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */
