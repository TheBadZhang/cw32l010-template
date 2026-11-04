/**
  ******************************************************************************
  * @file    syscalls.c
  * @author  CW32L010_SDK
  * @brief   newlib 系统调用重定向（arm-none-eabi-gcc）
  * @note    提供 _write/_read/_sbrk 等底层实现：
  *          - printf 等标准输出重定向到调试串口（bsp_uart_putc）
  *          - 堆禁用：_sbrk 恒返回 -1（本 SDK 不使用动态内存分配）
  ******************************************************************************
  */

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <errno.h>
#include <stdint.h>

#include "bsp_uart.h"

/* 全量 LTO + --gc-sections 下，libc.a（普通对象）内部对系统调用符号的引用
   无法阻止 LTO 裁剪，这里给所有 newlib 需要的符号加 used 属性强制保留 */
#define SYS_USED  __attribute__((used))

/**
  * @brief  标准输出重定向（printf 底层调用）
  * @param  fd：文件描述符
  * @param  ptr：数据指针
  * @param  len：数据长度
  * @retval 实际写入长度
  */
SYS_USED
int _write(int fd, char* ptr, int len)
{
  int i;
  (void)fd;

  for (i = 0; i < len; i++)
  {
    bsp_uart_putc((uint8_t)ptr[i]);
  }
  return len;
}

/**
  * @brief  标准输入（本 SDK 未实现，返回 0 表示 EOF）
  */
SYS_USED
int _read(int fd, char* ptr, int len)
{
  (void)fd;
  (void)ptr;
  (void)len;
  return 0;
}

/**
  * @brief  堆内存管理（malloc/free 底层调用）
  * @note   newlib 堆已禁用（链接脚本 _Min_Heap_Size = 0）：
  *         任何 newlib malloc/calloc/realloc 调用都会在此失败。
  * @param  incr：请求增加/减少的堆大小（忽略）
  * @retval 恒为 -1
  */
SYS_USED
void* _sbrk(ptrdiff_t incr)
{
  (void)incr;
  return (void*)-1;
}

/**
  * @brief  程序退出（嵌入式系统不应退出，陷入死循环）
  */
SYS_USED
void _exit(int status)
{
  (void)status;
  while (1)
  {
  }
}

/**
  * @brief  关闭文件描述符
  */
SYS_USED
int _close(int fd)
{
  (void)fd;
  return -1;
}

/**
  * @brief  文件定位
  */
SYS_USED
int _lseek(int fd, int ptr, int dir)
{
  (void)fd;
  (void)ptr;
  (void)dir;
  return 0;
}

/**
  * @brief  文件状态
  */
SYS_USED
int _fstat(int fd, void* st)
{
  (void)fd;
  (void)st;
  return 0;
}

/**
  * @brief  判断文件描述符是否为终端设备
  */
SYS_USED
int _isatty(int fd)
{
  (void)fd;
  return 1;
}

/**
  * @brief  查询文件读写位置（未用）
  */
SYS_USED
int _getpid(void)
{
  return 1;
}

/**
  * @brief  杀死进程（未用）
  */
SYS_USED
int _kill(int pid, int sig)
{
  (void)pid;
  (void)sig;
  return -1;
}
