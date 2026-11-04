/*============================================================================
 * @file    cw32l010_flash_64k_4k.ld
 * @brief   CW32L010 系列链接脚本：64KB FLASH / 4KB SRAM
 * @note    适用器件：CW32L010F8（如 CW32L010F8P6）
 *          FLASH: 0x00000000 - 0x0000FFFF (64KB)   ← 注意从 0x0 开始
 *          SRAM : 0x20000000 - 0x20000FFF (4KB)
 *          参考官方 IAR 链接脚本 IDEsupport/EWARM/.../CW32L010x8.icf
 *============================================================================*/

ENTRY(Reset_Handler)

/* 栈顶地址 = RAM 最高地址 */
_estack = ORIGIN(RAM) + LENGTH(RAM);

/* 最小堆/栈大小：栈 0x400（1KB，与官方 MDK 一致，为 printf 等提供足够栈），
   堆保留 0x200（newlib malloc 可选；syscalls._sbrk 默认返回 -1 禁用） */
_Min_Heap_Size  = 0x200;
_Min_Stack_Size = 0x400;

MEMORY
{
  FLASH (rx)      : ORIGIN = 0x00000000, LENGTH = 64K
  RAM (xrw)       : ORIGIN = 0x20000000, LENGTH = 4K
}

SECTIONS
{
  /* 中断向量表（CW32L010 向量表位于 0x0，即 FLASH 起始） */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector))
    . = ALIGN(4);
  } >FLASH

  /* 程序代码 */
  .text :
  {
    . = ALIGN(4);
    *(.text)
    *(.text*)
    *(.glue_7)
    *(.glue_7t)
    . = ALIGN(4);
  } >FLASH

  /* 只读数据 */
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)
    *(.rodata*)
    . = ALIGN(4);
  } >FLASH

  /* .data 段初始值在 FLASH 中的加载地址 */
  _sidata = LOADADDR(.data);

  /* 已初始化数据段（由启动文件从 FLASH 拷贝到 SRAM） */
  .data :
  {
    . = ALIGN(4);
    _sdata = .;
    *(.data)
    *(.data*)
    . = ALIGN(4);
    _edata = .;
  } >RAM AT> FLASH

  /* 未初始化数据段（由启动文件清零） */
  .bss :
  {
    . = ALIGN(4);
    _sbss = .;
    __bss_start__ = _sbss;
    *(.bss)
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
    __bss_end__ = _ebss;
  } >RAM

  /* 堆与栈（不实际占用空间，仅保证地址范围） */
  ._user_heap_stack :
  {
    . = ALIGN(8);
    PROVIDE ( end = . );
    PROVIDE ( _end = . );
    . = . + _Min_Heap_Size;
    . = . + _Min_Stack_Size;
    . = ALIGN(8);
  } >RAM

  /* 移除 C 库默认的异常/退出代码（避免与启动文件冲突） */
  /DISCARD/ :
  {
    libc.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }

  /* ARM 工具链属性段 */
  .ARM.attributes 0 : { *(.ARM.attributes) }
}
