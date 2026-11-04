/**
  ******************************************************************************
  * @file    bsp_uart.c
  * @author  CW32L010_SDK
  * @brief   调试串口驱动实现（参考官方 UART_Printf 例程）
  ******************************************************************************
  */

#include "bsp_uart.h"

static UART_TypeDef *s_console = BSP_DEBUG_UART;   /* 当前 printf 输出串口 */

/**
  * @brief  指定 printf 底层输出所用的 UART 实例
  * @param  uart：CW_UART1 / CW_UART2 / NULL（NULL 时输出丢弃）
  * @retval 无
  */
void bsp_uart_set_console(UART_TypeDef *uart)
{
  s_console = uart;
}

/**
  * @brief  初始化默认调试串口（UART2，PB05=TX / PB06=RX）
  * @param  uclk：UART 时钟频率（即 PCLK，例程常为 8MHz）
  * @param  baud：波特率
  * @retval 无
  */
void bsp_uart_init(uint32_t uclk, uint32_t baud)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};
  UART_InitTypeDef  UART_InitStruct = {0};

  /* 使能 UART 与 GPIO 时钟 */
  SYSCTRL_APBPeriphClk_Enable1(BSP_DEBUG_UART_CLK, ENABLE);
  SYSCTRL_AHBPeriphClk_Enable(BSP_DEBUG_GPIO_CLK, ENABLE);

  /* TX 引脚：先输出高（空闲），再配置为输出 */
  GPIO_WritePin(BSP_DEBUG_TX_PORT, BSP_DEBUG_TX_PIN, GPIO_Pin_SET);
  GPIO_InitStruct.Pins = BSP_DEBUG_TX_PIN;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.IT   = GPIO_IT_NONE;
  GPIO_Init(BSP_DEBUG_TX_PORT, &GPIO_InitStruct);

  /* RX 引脚：输入上拉 */
  GPIO_InitStruct.Pins = BSP_DEBUG_RX_PIN;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT_PULLUP;
  GPIO_InitStruct.IT   = GPIO_IT_NONE;
  GPIO_Init(BSP_DEBUG_RX_PORT, &GPIO_InitStruct);

  /* 复用功能：TX/RX */
  BSP_DEBUG_TX_AF();
  BSP_DEBUG_RX_AF();

  /* UART 参数配置 */
  UART_InitStruct.UART_BaudRate          = baud;
  UART_InitStruct.UART_Over              = UART_Over_16;
  UART_InitStruct.UART_Source            = UART_Source_PCLK;
  UART_InitStruct.UART_UclkFreq          = uclk;
  UART_InitStruct.UART_StartBit          = UART_StartBit_FE;
  UART_InitStruct.UART_StopBits          = UART_StopBits_1;
  UART_InitStruct.UART_Parity            = UART_Parity_No;
  UART_InitStruct.UART_HardwareFlowControl = UART_HardwareFlowControl_None;
  UART_InitStruct.UART_Mode              = UART_Mode_Rx | UART_Mode_Tx;
  UART_Init(BSP_DEBUG_UART, &UART_InitStruct);

  s_console = BSP_DEBUG_UART;
}

/**
  * @brief  发送一个字节（阻塞等待 TXE）
  * @param  c：待发送字节
  * @retval 无
  */
void bsp_uart_putc(uint8_t c)
{
  if (s_console == NULL)
  {
    return;
  }
  UART_SendData_8bit(s_console, c);
  while (UART_GetFlagStatus(s_console, UART_FLAG_TXE) == RESET)
  {
  }
}

/**
  * @brief  读取一个字节（无数据返回 0）
  * @param  无
  * @retval 收到的字节（无数据时 0）
  */
uint8_t bsp_uart_getc(void)
{
  uint8_t c = 0;
  if (s_console == NULL)
  {
    return 0;
  }
  if (UART_GetFlagStatus(s_console, UART_FLAG_RC) == SET)
  {
    c = UART_ReceiveData_8bit(s_console);
  }
  return c;
}
