示例目的：
          使用GPIO软件模拟I2C，读写EEPROM芯片（CW24C02）。

硬件资源：
          1. CW32L010 StartKit
          2. 时钟HSI
          3. 系统时钟设置为HSI时钟1分频，48MHz， PCLK、HCLK不分频，PCLK=HCLK=SysClk=48MHz
          4. PA05 模拟成SDA PA06模拟成SCK
		  5.PB05复用成UART2_TXD，OB06复用成UART2_RXD，串口波特率为115200

演示说明：
1、上电后，程序先将u8Senddata[10]的数据全部写入24C02的地址0x33，接着又把数据读回来进行对比，如果对比通过，LED2闪烁，对比不通过，LED1闪烁

硬件连接：
     SDA-----------PA05
     SCL-----------PA06
	 
	 PCRX---------PB05
     PCTX---------PB06

使用说明：
+ EWARM
          1. 打开project.eww文件
          2. 编译所有文件：Project->Rebuild all
          3. 载入工程镜像：Project->Debug
          4. 运行程序：Debug->Go(F5)

+ MDK-ARM
          1. 打开i2c_cw24c02_int.uvproj文件
          2. 编译所有文件：Project->Rebuild all target files
          3. 载入工程镜像：Debug->Start/Stop Debug Session
          4. 运行程序：Debug->Run(F5)
