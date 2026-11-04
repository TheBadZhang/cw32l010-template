#include "..\inc\main.h"
#include "MyI2C.h"

uint32_t Delay_Time = 100;//延时时间

void Delay_us(uint32_t cnt)
{
	for(uint32_t i=0;i<cnt;i++)
	{
		__NOP();
	}
}

//i2c可以慢但是太快绝对不行
void I2C_User_W_SCL(uint8_t BitValue)
{
    GPIO_WritePin(I2C1_SCL_GPIO_PORT,I2C1_SCL_GPIO_PIN,(GPIO_PinState)(BitValue));
    Delay_us(Delay_Time);// 延迟一位（I2C最大通信速率400kHz-2.5us）
}

//写SDA的操作
void I2C_User_W_SDA(uint8_t BitValue)
{
	uint8_t temp = (BitValue == 0)?0:1;
    GPIO_WritePin(I2C1_SDA_GPIO_PORT,I2C1_SDA_GPIO_PIN,(GPIO_PinState)(temp));
    Delay_us(Delay_Time);// 延迟一位（I2C最大通信速率400kHz-2.5us）
}

//读SDA的操作
uint8_t I2C_User_R_SDA(void)
{
    uint8_t BitValue=0;
    BitValue = GPIO_ReadPin(I2C1_SDA_GPIO_PORT,I2C1_SDA_GPIO_PIN);
    Delay_us(Delay_Time);// 延迟一位（I2C最大通信速率400kHz-2.5us）
    return BitValue;
}

//初始化两个GPIO口
void  I2C_User_Init(void)
{
    I2C1_SCL_GPIO_CLK_ENABLE();
	I2C1_SDA_GPIO_CLK_ENABLE();
	
	GPIO_InitTypeDef GPIO_InitStructure;
	
	//SDA、SCL脚都配置成开漏输出 + 上拉
    GPIO_InitStructure.Pins = I2C1_SCL_GPIO_PIN;
    GPIO_InitStructure.Mode = GPIO_MODE_OUTPUT_OD;    
    GPIO_Init(I2C1_SCL_GPIO_PORT, &GPIO_InitStructure);

    GPIO_InitStructure.Pins = I2C1_SDA_GPIO_PIN;
    GPIO_InitStructure.Mode = GPIO_MODE_OUTPUT_OD;    
    GPIO_Init(I2C1_SDA_GPIO_PORT, &GPIO_InitStructure);
	
	I2C1_SCL_GPIO_PORT->PUR_f.PIN5 = 1;//开SDA的上拉
	I2C1_SDA_GPIO_PORT->PUR_f.PIN6 = 1;//开SCL的上拉
    
	I2C_User_W_SDA(1);//SDA输出高电平
	I2C_User_W_SCL(1);//SCL输出高电平
}

//1. 发送起始位
void I2C_User_Start(void)
{
    // 调整SCL、SDA输出均为高电平-保险起见，先将SDA拉高,因为restart信号SDA会在SCK为低电平时拉高
    I2C_User_W_SDA(1);
    I2C_User_W_SCL(1);
    // SDA输出下降沿
    I2C_User_W_SDA(0);
    // 拉低SCL
    I2C_User_W_SCL(0);
}

//2. 发送终止位
void I2C_User_Stop(void)
{
    // 调整SCL、SDA输出均为低电平
    I2C_User_W_SCL(0);
    I2C_User_W_SDA(0);
    // 拉高SCL
    I2C_User_W_SCL(1);
    // 拉高SDA
    I2C_User_W_SDA(1);  
}

//3. 发送一个字节
void I2C_User_SendByte(uint8_t send_byte)
{
    uint8_t i=0;
    for(i=0;i<8;i++)
	{
        //改变SDA
        I2C_User_W_SDA((0x80>>i) & send_byte);
        //拉高SCL
        I2C_User_W_SCL(1);
        //拉低SCL
        I2C_User_W_SCL(0);
    }
}

//4. 接收一个字节
uint8_t I2C_User_RecvByte(void)
{
    uint8_t recv_byte=0x00;
    uint8_t i=0;
    //主机释放总线
    I2C_User_W_SDA(1);
    //接收数据
    for(i=0;i<8;i++)
	{
        // 拉高SCL
        I2C_User_W_SCL(1);
        // 读取数据
        if(I2C_User_R_SDA()==1)
		{
            recv_byte |= (0x80>>i);
        }
        // 拉低SCL
        I2C_User_W_SCL(0);
    }
    return recv_byte;
}

//5. 发送应答位
void I2C_User_SendAck(uint8_t AckBit)
{
    // 将应答位放在SDA上
    I2C_User_W_SDA(AckBit);
    // 拉高SCL
    I2C_User_W_SCL(1);
    // 拉低SCL
    I2C_User_W_SCL(0);
}

//6. 接收应答位
uint8_t I2C_User_RecvAck(void)
{
    uint8_t AckBit=0;
    //主机释放总线
    I2C_User_W_SDA(1);
    // 拉高SCL
    I2C_User_W_SCL(1);
    // 读取应答信号
    AckBit = I2C_User_R_SDA();
    // 拉低SCL
    I2C_User_W_SCL(0);
    return AckBit;
}


