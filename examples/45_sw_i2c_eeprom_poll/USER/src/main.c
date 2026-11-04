/**
 * @file main.c
 * @author WHXY
 * @brief
 * @version 0.1
 * @date 2024-08-07
 *
 * @copyright Copyright (c) 2021
 *
 */
/*******************************************************************************
*
* 代码许可和免责信息
* 武汉芯源半导体有限公司授予您使用所有编程代码示例的非专属的版权许可，您可以由此
* 生成根据您的特定需要而定制的相似功能。根据不能被排除的任何法定保证，武汉芯源半
* 导体有限公司及其程序开发商和供应商对程序或技术支持（如果有）不提供任何明示或暗
* 含的保证或条件，包括但不限于暗含的有关适销性、适用于某种特定用途和非侵权的保证
* 或条件。
* 无论何种情形，武汉芯源半导体有限公司及其程序开发商或供应商均不对下列各项负责，
* 即使被告知其发生的可能性时，也是如此：数据的丢失或损坏；直接的、特别的、附带的
* 或间接的损害，或任何后果性经济损害；或利润、业务、收入、商誉或预期可节省金额的
* 损失。
* 某些司法辖区不允许对直接的、附带的或后果性的损害有任何的排除或限制，因此某些或
* 全部上述排除或限制可能并不适用于您。
*
*******************************************************************************/
#include "main.h"
#include "MyI2C.h"
#include "SW_EEPROM.h"

uint8_t u8Senddata[10] = {0x01,0x2,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A};
uint8_t u8Recdata[10]= {0};
uint8_t RecvAddr = 0;

void UART_Configuration(void);

int32_t main(void)
{
	SYSCTRL_HSI_Enable(SYSCTRL_HSIOSC_DIV1);
	__SYSCTRL_GPIOB_CLK_ENABLE();
	
	PB02_SETLOW();
	PB03_SETLOW();
	GPIO_InitTypeDef GPIO_InitStructure = {0};
	
    GPIO_InitStructure.Pins = GPIO_PIN_2 | GPIO_PIN_3;
    GPIO_InitStructure.Mode = GPIO_MODE_OUTPUT_PP;    
    GPIO_Init(CW_GPIOB, &GPIO_InitStructure);
	
	UART_Configuration();
	
	I2C_User_Init();
	
	SW_I2C_MasterSendDataToSlave(0xA0, 0x33, u8Senddata, 10);
	
	SW_I2C_MasterRecDataFromSlave(0xA0,0x33,u8Recdata,10);
	
	//检查写入数据u8Senddata[]和读出来的数据u8Recdata[]是否一致
	for(uint16_t i=0;i<10;i++)
	{
		if(u8Recdata[i]!=u8Senddata[i])
		{
			printf("data check fail\r\n");
			while(1)
			{
				PB03_TOG();
				Delay_us(500000);
			}
		}
	}
	
	printf("data check success\r\n");
	
	while(1)
	{
		PB02_TOG();
		Delay_us(500000);
	}
}

void UART_Configuration(void)
{
	__SYSCTRL_GPIOB_CLK_ENABLE();
	
	GPIO_InitTypeDef GPIO_InitStructure = {0};
	
    GPIO_WritePin(CW_GPIOB, GPIO_PIN_5,GPIO_Pin_SET);    // 设置TXD的默认电平为高，空闲

    GPIO_InitStructure.Pins = GPIO_PIN_5;
    GPIO_InitStructure.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_Init(CW_GPIOB, &GPIO_InitStructure);

    GPIO_InitStructure.Pins = GPIO_PIN_6;
    GPIO_InitStructure.Mode = GPIO_MODE_INPUT_PULLUP;
    GPIO_Init(CW_GPIOB, &GPIO_InitStructure);

     //UART TX RX 复用
    PB05_AFx_UART2TXD();
	PB06_AFx_UART2RXD();
	
	__SYSCTRL_UART2_CLK_ENABLE();
	
    UART_InitTypeDef UART_InitStructure = {0};

    UART_InitStructure.UART_BaudRate = 115200;
    UART_InitStructure.UART_Over = UART_Over_16;
    UART_InitStructure.UART_Source = UART_Source_PCLK;
    UART_InitStructure.UART_UclkFreq = 48000000;
    UART_InitStructure.UART_StartBit = UART_StartBit_FE;
    UART_InitStructure.UART_StopBits = UART_StopBits_1;
    UART_InitStructure.UART_Parity = UART_Parity_No ;
    UART_InitStructure.UART_HardwareFlowControl = UART_HardwareFlowControl_None;
    UART_InitStructure.UART_Mode = UART_Mode_Rx | UART_Mode_Tx;
    UART_Init(CW_UART2, &UART_InitStructure);
}

int fputc(int ch, FILE *f)
{
	UART_SendData_8bit(CW_UART2, (uint8_t)ch);
    while (UART_GetFlagStatus(CW_UART2, UART_FLAG_TXE) == RESET);
    return ch;
}

/******************************************************************************
 * EOF (not truncated)
 ******************************************************************************/
#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @return None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
    /* USER CODE BEGIN 6 */
    /* User can add his own implementation to report the file name and line number,
       tex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
    /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */

