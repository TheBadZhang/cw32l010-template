#include "SW_EEPROM.h"
#include "MyI2C.h"
#include "cw32l010_uart.h"

#define EEPROM_TYPE 2 //2:24c02  256:24c256 512:24c512

//1、注意不能跨页写
void SW_I2C_MasterSendDataToSlave(uint8_t u8SlaveAddr, uint16_t DataAddr, uint8_t* pu8Data, uint32_t u32Len)
{
	I2C_User_Start();//发送START信号
	I2C_User_SendByte(u8SlaveAddr | 0x00);//发送从机地址+写(0)
	uint8_t ans = I2C_User_RecvAck();//接收从机应答位
	if(ans) printf("slaver answer NACK\r\n");
	if(EEPROM_TYPE==2)	I2C_User_SendByte(DataAddr);//发送待写入数据的地址
	else if((EEPROM_TYPE==256) || (EEPROM_TYPE==512)) 
	{
		I2C_User_SendByte((uint8_t)(DataAddr>>8));//先发送DataAddr的高8位
		I2C_User_SendByte((uint8_t)(DataAddr));//再发送DataAddr的低8位
	}
	ans = I2C_User_RecvAck();//接收从机应答位
	if(ans) printf("slaver answer NACK\r\n");
	for(uint32_t i=0;i<u32Len;i++)
	{
		I2C_User_SendByte(pu8Data[i]);//发送要写的数据
		ans = I2C_User_RecvAck();//接收从机应答位
		if(ans) printf("slaver answer NACK\r\n");
	}
	I2C_User_Stop();//发送STOP信号
	
	Delay_us(10000);//延时一段时间，等待EEPROM芯片写完，write cycle time一般在5~10ms
}

void SW_I2C_MasterRecDataFromSlave(uint8_t u8SlaveAddr, uint16_t DataAddr, uint8_t* pu8Data, uint32_t u32Len)
{
	//2、指定地址0x00开始读数据
	I2C_User_Start();//发送START信号
	I2C_User_SendByte(u8SlaveAddr | 0x00);//发送从机地址+写(0)
	uint8_t ans = I2C_User_RecvAck();//接收从机应答位
	if(ans) printf("slaver answer NACK\r\n");
	if(EEPROM_TYPE==2)	I2C_User_SendByte(DataAddr);//发送待写入数据的地址
	else if((EEPROM_TYPE==256) || (EEPROM_TYPE==512)) 
	{
		I2C_User_SendByte((uint8_t)(DataAddr>>8));//先发送DataAddr的高8位
		I2C_User_SendByte((uint8_t)(DataAddr));//再发送DataAddr的低8位
	}
	ans = I2C_User_RecvAck();//接收从机应答位
	if(ans) printf("slaver answer NACK\r\n");
	I2C_User_Start();//发送RESTART信号
	I2C_User_SendByte(u8SlaveAddr | 0x01);//发送从机地址+读(1)
	ans = I2C_User_RecvAck();//接收从机应答位
	if(ans) printf("slaver answer NACK\r\n");
	uint32_t i;
	for(i=0;i<u32Len-1;i++)
	{
		pu8Data[i] = I2C_User_RecvByte();//接收读取的数据
		I2C_User_SendAck(0);
	}
	pu8Data[i] = I2C_User_RecvByte();//接收读取最后一个数据的数据
	I2C_User_SendAck(1);//发送NACK
	I2C_User_Stop();
}
