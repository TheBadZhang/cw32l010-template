/**
  ******************************************************************************
  * @file    define.h
  * @brief   CW32L010 SDK 公共类型与常用宏定义
  * @note    对应 hk32f030-template sdk/include/define.h；
  *          官方 CW32L010 类型/宏见 Libraries 的 base_types.h，此处补充别名
  ******************************************************************************
*/

#ifndef _DEFINE_H_
#define _DEFINE_H_

#include <stdint.h>    /* 标准整数类型 */
#include <string.h>
#include <stdio.h>

/* 兼容旧代码的易失性类型别名 */
typedef volatile unsigned char        byte;
typedef volatile unsigned char        BOOL;
typedef volatile unsigned char        u8int;
typedef volatile unsigned short int   u16int;
typedef volatile unsigned long int    u32int;

#ifndef FALSE
#define FALSE  0
#endif
#ifndef TRUE
#define TRUE   1
#endif

/* 位定义 */
#define BIT0  0x01
#define BIT1  0x02
#define BIT2  0x04
#define BIT3  0x08
#define BIT4  0x10
#define BIT5  0x20
#define BIT6  0x40
#define BIT7  0x80
#define BIT8  0x0100
#define BIT9  0x0200
#define BIT10 0x0400
#define BIT11 0x0800
#define BIT12 0x1000
#define BIT13 0x2000
#define BIT14 0x4000
#define BIT15 0x8000

/* 开关类型 */
typedef enum
{
  ONOFF_OFF,
  ONOFF_ON,
} ONOFF_TYPE;

/* 返回状态类型 */
typedef enum
{
  RET_ERROR = 0,
  RET_OK,
} RET_TYPE;

#endif /* _DEFINE_H_ */
