/**
  ******************************************************************************
  * @file    bsp_uart.h
  * @author  CW32L010_SDK
  * @brief   调试串口驱动（printf 底层输出）
  * @note    默认控制台 = UART2 (PB05 TX / PB06 RX)，与官方 UART_Printf 例程一致；
  *          应用也可通过 bsp_uart_set_console 切换到其它 UART 实例。
  *          UART 初始化（时钟/GPIO/波特率）由 bsp_uart_init 完成。
  ******************************************************************************
  */

#ifndef __BSP_UART_H
#define __BSP_UART_H

#include "cw32l010.h"
#include "cw32l010_uart.h"
#include "cw32l010_gpio.h"
#include "cw32l010_sysctrl.h"

/* 默认调试串口：UART2 / PB05 TX / PB06 RX（同官方 UART_Printf 例程） */
#define BSP_DEBUG_UART         CW_UART2
#define BSP_DEBUG_UART_CLK     SYSCTRL_APB1_PERIPH_UART2
#define BSP_DEBUG_GPIO_CLK     SYSCTRL_AHB_PERIPH_GPIOB
#define BSP_DEBUG_TX_PORT      CW_GPIOB
#define BSP_DEBUG_TX_PIN       GPIO_PIN_5
#define BSP_DEBUG_RX_PORT      CW_GPIOB
#define BSP_DEBUG_RX_PIN       GPIO_PIN_6
#define BSP_DEBUG_TX_AF()      PB05_AFx_UART2TXD()
#define BSP_DEBUG_RX_AF()      PB06_AFx_UART2RXD()

void bsp_uart_init(uint32_t uclk, uint32_t baud); /* 初始化默认调试串口 */
void bsp_uart_set_console(UART_TypeDef *uart);    /* 指定 printf 输出 UART 实例 */
void bsp_uart_putc(uint8_t c);                    /* 输出单字节（阻塞） */
uint8_t bsp_uart_getc(void);                      /* 读取单字节（无数据返回 0） */

#endif /* __BSP_UART_H */
