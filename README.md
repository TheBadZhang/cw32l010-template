# CW32L010_SDK 模板工程

基于官方 **CW32L010 标准外设库 V1.0.9**，参考 **hk32f030-template-main** 的目录结构整理的
xmake + arm-none-eabi-gcc 全套模板工程。保留官方固件库、官方例程（USER 结构原样拷贝），
新增 GNU 启动文件、链接脚本、BSP 封装与统一构建脚本。

## 目录结构

```
cw32l010-template-main/
├── .vscode/            # VS Code 任务/调试配置（可选）
├── apps/               # 实际应用（自其它工程迁移，GNU Make 已改为 xmake）
│   └── vbus_ws2812_key/     # 按键控制 VBUS 电源 + WS2812 彩灯
│       ├── USER/{inc,src}   # 应用源码（板级/调度/按键/灯效/VBUS/RTT 日志）
│       ├── tools/           # 主机端辅助脚本（仍用 tools/Makefile 入口）
│       └── README.md        # 硬件连接、时序推导、调试排查
├── docs/               # 简要说明文档（寄存器级文档可基于官方参考手册补充）
├── examples/           # 官方例程移植（NN_名称/USER/{inc,src}，源码零修改）
│   ├── 01_led_blink         # ← GPIO/gpio_blink（LED 闪烁）
│   ├── 02_usart_printf      # ← UART/UART_Printf（串口 printf，UART2 PB05/PB06）
│   ├── ...                  # 共 70 个例程（01~70）覆盖官方全部例程
│   └── 70_vc_high_irq       # ← VC/vc_detect_high_irq（电压比较器中断）
│   # 完整对照表见 docs/README.md
├── misc/               # 烧录辅助：CW32L010.svd、DFP pack、jlink-script
├── sdk/
│   ├── bsp/            # 板级支持：bsp_led/bsp_key/bsp_delay/bsp_uart + syscalls
│   │   └── rtt/        # SEGGER 官方 RTT 源码（供 vbus_ws2812_key 输出实时日志）
│   ├── cmsis/
│   │   ├── core/       # CMSIS Cortex-M0+ 内核头文件
│   │   └── device/     # 器件头：cw32l010.h / system_cw32l010.{h,c}
│   ├── cwlib/          # 官方标准外设库（inc + src，自 Libraries 原样拷贝）
│   │   ├── inc/
│   │   └── src/
│   └── include/        # define.h 等 SDK 公共头
├── startup/
│   ├── startup_cw32l010.s   # GNU as 启动文件（自官方 MDK 启动移植）
│   └── linker/              # cw32l010_flash_64k_4k.ld（64KB FLASH / 4KB SRAM）
├── template/           # 应用模板（main.c/h + interrupts_cw32l010.c/h）
├── xmake.lua           # ★ 唯一构建脚本（所有目标集中定义）
└── README.md
```

## 与 hk32f030-template-main 的结构对应

| hk32f030-template-main | 本工程（cw32l010-template-main） |
|---|---|
| `sdk/hklib/{inc,src}`（官方固件库） | `sdk/cwlib/{inc,src}`（官方标准外设库） |
| `sdk/cmsis/device/...`（hk32f030m.h） | `sdk/cmsis/device/...`（cw32l010.h） |
| `startup/startup_hk32f030m.s` + `linker/*.ld` | `startup/startup_cw32l010.s` + `linker/cw32l010_flash_64k_4k.ld` |
| `template/`（main + it 模板） | `template/`（main + interrupts_cw32l010 模板） |
| `examples/NN_xxx/` | `examples/NN_xxx/USER/{inc,src}`（保留官方例程结构） |
| `apps/`（实际应用） | `apps/vbus_ws2812_key/USER/{inc,src}`（按键控制 VBUS 电源 / WS2812 彩灯） |
| `misc/`（SVD/pack/jlink 脚本） | `misc/`（CW32L010.svd/DFP pack/jlink 脚本） |

## 快速开始

```sh
# 1. 配置（工具链 arm-none-eabi-gcc 在 PATH 中；也可用 --sdk= 指定根目录）
xmake f -p cross -a arm -m debug --cross=arm-none-eabi- -y

# 2. 构建全部（app + 应用 + 70 个例程，各 target 直接编译全部 SDK 源码）
xmake -j 8

# 或构建单个目标
xmake app
xmake vbus_ws2812_key
xmake 01_led_blink
```

产物位于 `build/bin/<target>/{<target>.elf,.bin,.hex,.map,.lst}`。

## 烧录

`xmake run <target>` 自动构建并烧录（烧录器通过 `xmake f --flasher=...` 选择）：

```sh
# J-Link（默认）
xmake f --device=CW32L010F8P6 --flasher=jlink -y
xmake run app

# PyOCD（需 CMSIS-DAP/ST-Link 等 probe；器件支持来自 misc 下 DFP pack）
xmake f --flasher=pyocd -y
xmake run app
```

> J-Link 的 `--device` 名称取决于 J-Link 软件对 CW32L010 的支持情况；
> PyOCD 亦可手动执行：
> `pyocd flash -t cw32l010f8 --pack misc/WHXY.CW32L010_DFP.1.0.2.pack build/bin/app/app.hex`

### 烧录相关任务

原 GNU Makefile 的 `pack / flash / reset / erase` 已改为 xmake 任务：

```sh
xmake flash                    # 构建并烧录 vbus_ws2812_key（等价 xmake run <target>）
xmake flash -t app             # 指定目标
xmake erase                    # 擦除整片 FLASH
xmake reset                    # 复位目标
xmake pack --dfpdir=<DFP 目录>  # 由 SDK 的 DFP 目录重新生成 misc 下的 CMSIS-Pack
```

`flash / erase / reset` 会自动使用 `misc/WHXY.CW32L010_DFP.1.0.2.pack`，
pyocd 目标名默认 `cw32l010f8`，可用 `xmake f --pyocdtarget=... --packfile=...` 覆盖。

> `vbus_ws2812_key` 的 RTT 监控、按键诊断与调度器主机端测试属于工具类，
> 仍保留 GNU make 入口：`make -C apps/vbus_ws2812_key/tools help`。

## 器件资源

| 项目 | 说明 |
|---|---|
| 内核 | ARM Cortex-M0+，最高 48MHz |
| FLASH | 0x00000000 - 0x0000FFFF，64KB（注意：从 0x0 开始，非 0x08000000） |
| SRAM | 0x20000000 - 0x20000FFF，4KB |
| 启动流程 | Reset_Handler 拷贝 .data、清零 .bss → SystemInit（加载 HSI/LSI TRIM）→ main |
| 系统时钟 | CW32L010 官方 SystemInit **不配置时钟**，需在 main 开头显式配置，如 `SYSCTRL_HSI_Enable(SYSCTRL_HSIOSC_DIV6)` → 8MHz |

## 移植新官方例程的方法

1. 在官方库 `Examples/<外设>/<例程>/USER/` 中把 `inc/` 与 `src/` 拷贝为
   `examples/NN_名称/USER/inc`、`examples/NN_名称/USER/src`；
   （也可以把官方 readme.txt 一并拷入 `examples/NN_名称/` 作说明）
2. 源文件中的相对 include（`#include "..\inc\xxx.h"`）无需修改——
   arm-none-eabi-gcc 在 Windows 下可直接解析反斜杠路径（本工程已验证），
   官方源码保持零修改；
3. 在顶层 `xmake.lua` 末尾追加一行：
   `sdk_firmware("NN_名称", "examples/NN_名称/USER/src", {"../inc"})`；
4. `xmake NN_名称` 编译验证。

## 迁移带第三方源码的应用

`apps/vbus_ws2812_key` 是自另一个 GNU Make 工程迁移的实际应用，可作为参考：
源码同样放在 `USER/{inc,src}`，额外依赖（SEGGER RTT）随仓库放在
`sdk/bsp/rtt/`，目标定义使用 `sdk_firmware` 的第 5 个参数 `extra`：

```lua
sdk_firmware("vbus_ws2812_key", "apps/vbus_ws2812_key/USER/src",
    {"../inc"},                                     -- 相对 srcdir 的额外 include
    {"BUFFER_SIZE_UP=512", ...},                    -- 额外编译宏
    {
        includedirs = {"sdk/bsp/rtt"},              -- 相对项目根的 include 目录
        sources     = {"sdk/bsp/rtt/SEGGER_RTT.c",  -- 随目标一起编译的额外源文件
                       "sdk/bsp/rtt/SEGGER_RTT_printf.c"},
    })
```

`extra` 为可选参数，缺省时行为与原来完全一致（不影响已有 70 个例程）。

## GCC 移植差异说明

- 官方库使用 MDK/IAR 内置的 `__WEAK` 关键字，本工程通过编译宏
  `__WEAK=__attribute__((weak))` 全局提供；
- 官方 `interrupts_cw32l010.c` 模板与部分库文件写法（`int32_t main`、
  部分初始化结构体、`uint32_t` 的 `%x` 打印、`void inline` 旧式声明、
  未初始化循环变量、库头 `assert_param` 展开的 type-limits 恒真比较等）
  在 `-Werror -Wall -Wextra` 下有差异告警，已通过 `-Wno-error=main /
  -Wno-missing-field-initializers / -Wno-error=format /
  -Wno-error=uninitialized -Wno-error=type-limits` 兼容（见 xmake.lua 注释），
  官方库源文件以 `-Wno-error` 编译、仅保留警告输出；
- `printf` 输出经 `sdk/bsp/syscalls.c` 的 `_write()` 重定向到调试串口
  （默认 UART2 PB05/PB06），与官方 UART_Printf 例程一致；例程中自带的
  `__write`/`__retarget_putchar`（IAR/EWARM 入口）与 GCC newlib 的 `_write`
  符号不同名，二者共存无冲突；
- SysTick：官方库 `cw32l010_systick.c` 自带 `__WEAK SysTick_Handler`，
  启动文件刻意不提供汇编版 weak 跳转以免覆盖，`bsp_delay` 采用独立
  SysTick 自由运行计数实现（不依赖该 weak 实现）。
