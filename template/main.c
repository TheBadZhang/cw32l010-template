/**
  ******************************************************************************
  * @file    main.c
  * @author  CW32L010_SDK
  * @brief   应用模板主函数
  * @note    CW32L010 官方 SystemInit 仅加载 HSI/LSI TRIM 校准，不配置时钟；
  *          因此 main 开头需显式配置系统时钟（本模板默认 HSI 6 分频 = 8MHz）。
  *          演示：LED 闪烁 + 串口 printf（若不需要串口，去掉 bsp_uart 部分即可）
  ******************************************************************************
  */

#include "main.h"

/**
  * @brief  主函数
  * @param  无
  * @retval 无
  */
int main(void)
{
  /* 1. 配置系统时钟：HSI(48MHz) 6 分频 → SYSCLK = 8MHz，HCLK/PCLK 不分频 */
  SYSCTRL_HSI_Enable(SYSCTRL_HSIOSC_DIV6);
  SystemCoreClock = 8000000U;      /* 手动维护 SystemCoreClock（官方库不自动更新） */

  /* 2. SysTick 忙等延时初始化（传入系统时钟频率） */
  bsp_delay_init(SystemCoreClock);

  /* 3. LED GPIO 初始化（默认 PB02，见 bsp_led.h） */
  LED_GPIO_Config();

  /* 4.（可选）调试串口初始化：默认 UART2 PB05=TX/PB06=RX，uclk=8MHz, baud=115200 */
  bsp_uart_init(SystemCoreClock, 115200U);

  /* 5. 主循环：LED 闪烁 + 串口输出（观察演示效果） */
  printf("\r\nCW32L010 Template Start, SYSCLK = 8MHz\r\n");

  while (1)
  {
    LED_ON();
    bsp_delay_ms(200U);

    LED_OFF();
    bsp_delay_ms(200U);
  }
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  报告参数错误发生的源文件名与行号（USE_FULL_ASSERT 开启时需要）
  * @param  file：源文件名
  * @param  line：行号
  * @retval 无
  */
void assert_failed(uint8_t* file, uint32_t line)
{
  /* 用户可以添加自定义实现，如：
     printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  (void)file;
  (void)line;
  while (1)
  {
  }
}
#endif /* USE_FULL_ASSERT */
