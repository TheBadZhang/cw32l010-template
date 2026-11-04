# CW32L010 文档

本目录为模板工程的说明文档集合（对应 hk32f030-template 的 docs/）。

## 官方资料

CW32L010 的寄存器级权威资料请以官方为准：

- 官方标准外设库：`CW32L010_StandardPeripheralLib_V1.0.9`（本工作区同级的官方库目录）
  - 每个例程自带 readme.txt（硬件连接 / 演示说明）
  - `IDEsupport/` 提供 Keil MDK / IAR 参考工程与 DFP pack
- 数据手册 / 参考手册：武汉芯源（WHXY）官网 CW32L010 页面

## 快速参考

| 项目 | 值 |
|---|---|
| 内核 | Cortex-M0+ @ up to 48MHz |
| FLASH | 0x00000000, 64KB |
| SRAM | 0x20000000, 4KB |
| HSI | 48MHz 内部 RC（HSIOSC），可 1~16 分频 |
| LSI | 内部低速 RC（RTC/LPTIM 等） |
| UART1 | PA05(RX)/PA06(TX) 等，AF 见 cw32l010_gpio.h |
| UART2 | PB05(TX)/PB06(RX) 等，AF 见 cw32l010_gpio.h |
| 调试串口（默认） | UART2 9600/115200 可配（sdk/bsp/bsp_uart.h） |

## 中断向量（节选，完整见 startup/startup_cw32l010.s）

| IRQn | Handler | 外设 |
|---|---|---|
| 0 | WDT_IRQHandler | 看门狗 |
| 1 | LVD_IRQHandler | 低电压检测 |
| 2 | RTC_IRQHandler | RTC |
| 3 | FLASHRAM_IRQHandler | Flash/RAM |
| 4 | SYSCTRL_IRQHandler | 时钟控制 |
| 5 | GPIOA_IRQHandler | GPIOA |
| 6 | GPIOB_IRQHandler | GPIOB |
| 12 | ADC_IRQHandler | ADC |
| 13 | ATIM_IRQHandler | 高级定时器 |
| 14/15 | VC1_/VC2_IRQHandler | 电压比较器 |
| 16 | GTIM1_IRQHandler | 通用定时器1 |
| 19 | LPTIM_IRQHandler | 低功耗定时器 |
| 20/21/22 | BTIM1_/BTIM2_/BTIM3_IRQHandler | 基础定时器 |
| 23 | I2C1_IRQHandler | I2C1 |
| 25 | SPI1_IRQHandler | SPI1 |
| 27/28 | UART1_/UART2_IRQHandler | 串口 |
| 31 | CLKFAULT_IRQHandler | 时钟失效 |

## 例程与官方对照

> 官方 Examples 共 70 个例程，本工程已全部移植（01~70），源码零修改。
> 每个例程目录下均有官方 readme.txt（演示说明/硬件连线/引脚）。
> 构建单个例程：`xmake NN_xxx`（如 `xmake 13_adc_sgl_ext_trig`）。

| 本工程 target | 官方源例程 | 外设 |
|---|---|---|
| 01_led_blink | GPIO/gpio_blink | GPIO |
| 02_usart_printf | UART/UART_Printf | UART |
| 03_exti_key | GPIO/gpio_int_default | GPIO |
| 04_btim_timer | BTIM/BaseTimer | BTIM |
| 05_gtim_timer | GTIM/gtim_timer | GTIM |
| 06_atim_pwm | ATIM/atim_pwm_output_comp | ATIM |
| 07_adc_single | ADC/adc_sgl_sw | ADC |
| 08_rtc_calendar | RTC/RTC_Calendar | RTC |
| 09_lptim_timer | LPTIM/lptim_timer_mode | LPTIM |
| 10_iwdt_reset | IWDT/IWDT_reset | IWDT |
| 11_flash_erasewrite | FLASH/flash_EraseWrite | FLASH |
| 12_pwr_sleep | PWR/PWR_ConsumptionTest | PWR |
| 13_adc_sgl_ext_trig | ADC/adc_sgl_ext_trig | ADC |
| 14_adc_sgl_sw_trig_ts | ADC/adc_sgl_sw_trig_TS | ADC |
| 15_adc_sgl_sw_vdd | ADC/adc_sgl_sw_vdd | ADC |
| 16_adc_sgl_wdt | ADC/adc_sgl_wdt | ADC |
| 17_adc_sqr_irq_sw | ADC/adc_sqr_irq_sw | ADC |
| 18_adc_sqr_sw_vdd_ts | ADC/adc_sqr_sw_vdd_Ts | ADC |
| 19_atim_basetimer | ATIM/atim_basetimer | ATIM |
| 20_atim_counter_etr | ATIM/atim_counter_etr | ATIM |
| 21_atim_encoder | ATIM/atim_encoder | ATIM |
| 22_atim_input_capture | ATIM/atim_input_capture | ATIM |
| 23_atim_pwm_phaser | ATIM/atim_pwm_phaser | ATIM |
| 24_atim_trigger_adc | ATIM/atim_trigger_adc | ATIM |
| 25_btim_etr | BTIM/BaseTimer_ETR | BTIM |
| 26_btim_toggle_10hz | BTIM/BaseTimer_Toggle_10Hz | BTIM |
| 27_crc_calc | CRC/crc_calc | CRC |
| 28_digitalsign | DIGITALSIGN/DigitalSign | DIGITALSIGN |
| 29_flash_fullchip_erase | FLASH/flash_FullChipErase | FLASH |
| 30_flash_slib_create | FLASH/flash_safety_lib_create | FLASH |
| 31_flash_slib_call | FLASH/flash_safety_lib_call | FLASH |
| 32_gpio_hclk_pclk | GPIO/gpio_hclk_pclk | GPIO |
| 33_gpio_input_output | GPIO/gpio_input_output | GPIO |
| 34_gpio_int_filter | GPIO/gpio_int_filter | GPIO |
| 35_gpio_swd_io | GPIO/gpio_swd_io | GPIO |
| 36_gpio_wakeup_filter | GPIO/gpio_wakeup_filter | GPIO |
| 37_gtim_pwm_input | GTIM/gtim_pwm_input | GTIM |
| 38_gtim_pwm_output | GTIM/gtim_pwm_output | GTIM |
| 39_i2c_master_poll | I2C/i2c_master_recv_send_poll | I2C |
| 40_i2c_master_int | I2C/i2c_master_recv_send_int | I2C |
| 41_i2c_slave_poll | I2C/i2c_slaver_recv_send_poll | I2C |
| 42_i2c_slave_int | I2C/i2c_slaver_recv_send_int | I2C |
| 43_i2c_eeprom_poll | I2C/i2c_cw24c02_poll | I2C |
| 44_i2c_eeprom_int | I2C/i2c_cw24c02_int | I2C |
| 45_sw_i2c_eeprom_poll | I2C/gpio_sw_i2c_cw24c02_poll | I2C |
| 46_i2c_master_by_vc | I2C/I2C_Master_Convertted_By_VC | I2C |
| 47_iwdt_int | IWDT/IWDT_int | IWDT |
| 48_lptim_counter | LPTIM/lptim_counter_mode | LPTIM |
| 49_lptim_pwm_lse | LPTIM/lptim_pwm_LSE | LPTIM |
| 50_lvd_falling_irq | LVD/lvd_detect_falling_irq | LVD |
| 51_lvd_both_irq | LVD/lvd_detect_fallingrising_irq | LVD |
| 52_lvd_level_irq | LVD/lvd_detect_level_irq | LVD |
| 53_rcc_hsi_hse | RCC/rcc_hsi_hse | RCC |
| 54_rcc_hsi_lse | RCC/rcc_hsi_lse | RCC |
| 55_rcc_hsi_lsi | RCC/rcc_hsi_lsi | RCC |
| 56_rcc_mco | RCC/rcc_mco | RCC |
| 57_rcc_pclkout | RCC/rcc_pclkout | RCC |
| 58_spi_flash | SPI/SPI_FLASH | SPI |
| 59_spi_full_duplex_poll | SPI/SPI_FullDuplex_ComPolling | SPI |
| 60_spi_simplex_int | SPI/SPI_Simplex_Interrupt | SPI |
| 61_spi_slave_1line_poll | SPI/SPI_Slave_1LineHalfDuplex_Polling_8bit | SPI |
| 62_uart_polling | UART/UART_Polling | UART |
| 63_uart_interrupt | UART/UART_Interrupt | UART |
| 64_uart_int_recv_timeout | UART/UART_Interrupt_Recv_Timeout | UART |
| 65_uart_autobaud | UART/UART_AutoBaudRate | UART |
| 66_uart_1line_halfduplex | UART/UART_1LineHalfDuplex_Polling | UART |
| 67_uart_lin21 | UART/LIN 2.1 | UART |
| 68_vc_falling_irq | VC/vc_detect_falling_irq | VC |
| 69_vc_both_irq | VC/vc_detect_fallingRising_irq | VC |
| 70_vc_high_irq | VC/vc_detect_high_irq | VC |
