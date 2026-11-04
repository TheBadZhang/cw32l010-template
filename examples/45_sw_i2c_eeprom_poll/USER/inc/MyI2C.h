#ifndef __MYI2C_H
#define __MYI2C_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

#define I2C1_SCL_GPIO_PIN 				GPIO_PIN_6
#define I2C1_SCL_GPIO_PORT 				CW_GPIOA
#define I2C1_SCL_GPIO_CLK_ENABLE() 		__SYSCTRL_GPIOA_CLK_ENABLE()


#define I2C1_SDA_GPIO_PIN 				GPIO_PIN_5
#define I2C1_SDA_GPIO_PORT 				CW_GPIOA
#define I2C1_SDA_GPIO_CLK_ENABLE() 		__SYSCTRL_GPIOA_CLK_ENABLE()


void  I2C_User_Init(void);
void I2C_User_Start(void);
void I2C_User_Stop(void);
void I2C_User_SendByte(uint8_t send_byte);
uint8_t I2C_User_RecvByte(void);
void I2C_User_SendAck(uint8_t AckBit);
uint8_t I2C_User_RecvAck(void);
void Delay_us(uint32_t cnt);


#ifdef __cplusplus
}
#endif

#endif 

