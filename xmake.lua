--!A cross-platform build utility based on Lua
--
-- CW32L010_SDK 顶层构建脚本
-- 工具链：GNU Arm Embedded Toolchain（arm-none-eabi-gcc），使用 xmake 内置 cross 平台
-- 用法：
--   xmake f -m debug/release          选择构建模式
--   xmake f -p cross -a arm --cross=arm-none-eabi-  设置交叉编译器前缀
--                                     工具已加入系统 PATH 时可直接生效；
--                                     也可配合 --sdk=<工具链根目录> 指定查找路径
--   xmake                            构建全部目标（app + 全部例程，各目标直接编译全部 SDK 源码）
--   xmake <target>                   构建单个目标（如 xmake 01_led_blink）
--   产物：build/<mode>/bin/<target>/<target>.elf|.bin|.hex
--
set_project("CW32L010_SDK")
set_version("0.1.0")
set_xmakever("3.0.0")

-- 平台与架构
set_plat("cross")
set_arch("arm")

-- 全局策略：显示链接器完整输出（否则 -Wl,--print-memory-usage 的输出
-- 会被 xmake 当作链接过程噪音吞掉，构建日志看不到 Memory region 表格）
set_policy("build.linker.output", true)

-- ============================================================================
-- 选项：目标器件（当前仅 CW32L010F8 = 64KB FLASH / 4KB SRAM）
-- ============================================================================
option("device")
    set_default("CW32L010F8P6")
    set_showmenu(true)
    set_description("Target device: CW32L010F8P6 (64K/4K), ...")
option_end()

-- ============================================================================
-- 选项：烧录器（jlink / pyocd / none）
--   用法：xmake f --flasher=jlink  或  xmake f --flasher=pyocd
-- ============================================================================
option("flasher")
    set_default("jlink")
    set_showmenu(true)
    set_values("jlink", "pyocd", "none")
    set_description("Programmer: jlink or pyocd (none to disable)")
option_end()

-- ============================================================================
-- 选项：JLink.exe 路径（缺省自动在常见路径/PATH 中查找）
-- ============================================================================
option("jlinkexe")
    set_showmenu(true)
    set_description("Path to JLink.exe (auto-detect if not set)")
option_end()

-- ============================================================================
-- 选项：pyocd 路径（缺省使用 PATH 中的 pyocd）
-- ============================================================================
option("pyocdexe")
    set_showmenu(true)
    set_description("Path to pyocd executable (default: pyocd in PATH)")
option_end()

-- ============================================================================
-- 选项：pyocd 的目标名（默认 cw32l010f8，来自 CMSIS-Pack 的 device 定义）
--   xmake f --pyocdtarget=cw32l010f8
-- ============================================================================
option("pyocdtarget")
    set_default("cw32l010f8")
    set_showmenu(true)
    set_description("pyocd target name (default: cw32l010f8)")
option_end()

-- ============================================================================
-- 选项：pyocd 使用的 CMSIS-Pack 路径
--   缺省用仓库自带的 misc/WHXY.CW32L010_DFP.1.0.2.pack
-- ============================================================================
option("packfile")
    set_showmenu(true)
    set_description("Path to CMSIS-Pack for pyocd (default: misc/WHXY.CW32L010_DFP.1.0.2.pack)")
option_end()

-- 公共编译参数
sdk_cpu_flags   = { "-mcpu=cortex-m0plus", "-mthumb", "-mfloat-abi=soft" }
sdk_opt_flags   = { "-ffunction-sections", "-fdata-sections" }
-- -Wno-unused-function：抑制官方固件库头文件中 static 声明未定义的噪音警告
-- -Wno-error=main：官方例程使用 int32_t main(void)（GCC 要求 main 返回 int，仅警告级豁免）
-- -Wno-missing-field-initializers：官方例程常用 {DISABLE, 0} 式部分初始化结构体
-- -Wno-error=format：arm-none-eabi newlib 中 uint32_t=unsigned long，与 MDK/IAR
--   （%x 期望 unsigned int）存在跨工具链格式差异，官方例程原样保留
sdk_warn_flags  = { "-Werror", "-Wall", "-Wextra", "-Wno-unused-function", "-Wno-unused-parameter", "-Wno-unused-variable", "-Wno-unused-but-set-variable", "-Wno-error=main", "-Wno-missing-field-initializers", "-Wno-error=format" }
-- CW32 官方库使用 __WEAK（MDK/IAR 编译器内置关键字），GCC 下需显式定义
sdk_gcc_compat  = { "__WEAK=__attribute__((weak))" }

-- 公共头文件搜索路径（绝对路径，避免子目录解析歧义）
sdk_incdirs = {
    path.join("$(projectdir)/sdk/include"),
    path.join("$(projectdir)/sdk/cmsis/core"),
    path.join("$(projectdir)/sdk/cmsis/device/include"),
    path.join("$(projectdir)/sdk/cwlib/inc"),
    path.join("$(projectdir)/sdk/bsp"),
}

-- ============================================================================
-- 创建固件目标（可执行 ELF + bin + hex）
--   将所有 SDK 源码（官方外设库 + CMSIS + BSP）与例程源码放在同一 target 中编译，
--   所有源文件统一开启 -Os，实现最优代码体积
--   name     ：目标名
--   srcdir   ：应用源码目录（含 main.c 等），相对项目根目录
--   extra_includedirs ：可选，额外 include 目录（相对 srcdir，如例程自带 USER/inc）
--   extra_defines     ：可选，额外编译宏
--   extra             ：可选，表 { sources = {...}, includedirs = {...} }
--                       sources     相对项目根目录的额外源文件（如自带第三方库）
--                       includedirs 相对项目根目录的额外 include 目录
-- ============================================================================
function sdk_firmware(name, srcdir, extra_includedirs, extra_defines, extra)
    target(name)
        set_kind("binary")
        set_targetdir(path.join("$(builddir)", "bin", name))
        set_basename(name .. ".elf")
        set_default(true)

        -- 启动文件 + SDK 全部源码 + 官方库 + BSP + 例程源码（同一 target）
        add_files("startup/startup_cw32l010.s")
        -- 官方外设库/CMSIS 系统源：官方代码存在旧式声明等写法（如 "void inline"），
        -- 对这些源文件关闭 -Werror（保留警告输出），避免第三方代码阻断构建
        add_files("sdk/cwlib/src/*.c", {cflags = "-Wno-error"})
        add_files("sdk/cmsis/device/source/system_cw32l010.c", {cflags = "-Wno-error"})
        add_files("sdk/bsp/*.c")
        -- 例程源码：官方部分例程存在编译器不同视角的告警（如 49_lptim_pwm_lse 中
        -- for(uint32_t i; ...) 未初始化 i 是官方原样代码；官方库头内 assert_param
        -- 展开会对 uint8_t 等产生 type-limits 恒真比较告警），对例程源码豁免这些
        -- 告警的 -Werror 升级，保持官方源码零修改（其余 -Werror 仍生效）
        add_files(path.join(os.projectdir(), srcdir, "*.c"), {cflags = "-Wno-error=uninitialized -Wno-error=type-limits"})
        -- 目标自带的额外源文件（如第三方中间件），随目标一起编译
        if extra and extra.sources then
            for _, src in ipairs(extra.sources) do
                add_files(path.join(os.projectdir(), src))
            end
        end

        -- 头文件与宏
        add_includedirs(sdk_incdirs)
        if extra_includedirs then
            for _, inc in ipairs(extra_includedirs) do
                add_includedirs(path.join(os.projectdir(), srcdir, inc))
            end
        end
        if extra and extra.includedirs then
            for _, inc in ipairs(extra.includedirs) do
                add_includedirs(path.join(os.projectdir(), inc))
            end
        end
        add_defines(sdk_gcc_compat)
        if extra_defines then
            add_defines(extra_defines)
        end

        -- 编译参数（-Os 体积优化，所有源文件统一）
        -- -g：保留调试信息，供 after_build 中 objdump -d -S 反汇编时穿插 C 源码行
        add_cflags(sdk_cpu_flags, "-g", "-Os", sdk_opt_flags, sdk_warn_flags, {force = true})
        add_cxxflags("-fno-exceptions", "-fno-rtti")
        add_asflags(sdk_cpu_flags)
        set_languages("c23", "c++23")

        -- 链接参数：使用 newlib-nano + nosys，_write 等由 sdk/bsp/syscalls.c 提供
        local ldflags = {
            "-Os",
            "-T" .. path.join("startup/linker/cw32l010_flash_64k_4k.ld"),
            "-Wl,--gc-sections",
            "-nostartfiles",
            "-nostdlib", "-nolibc",
            "-Wl,-Map=" .. path.join("$(builddir)", "bin", name, name .. ".map"),
            "--specs=nano.specs", "--specs=nosys.specs",
            "-Wl,--start-group", "-lc", "-lm", "-lgcc", "-Wl,--end-group",
            "-Wl,--print-memory-usage",
        }
        add_ldflags(sdk_cpu_flags, ldflags, {force = true})

        -- 生成 bin / hex 固件 + C↔汇编对照反汇编（<name>.lst）
        after_build(function(target)
            local elf = target:targetfile()
            local dir = target:targetdir()
            if not os.isdir(dir) then os.mkdir(dir) end
            if not os.isfile(elf) then
                raise("elf not found: " .. elf .. ", please rebuild")
            end

            -- 并行构建时链接刚结束就立即读取 ELF，Windows 下偶发文件句柄未释放/
            -- 杀毒软件锁定导致 objcopy 打开失败，这里失败后短暂重试
            local function run_retry(prog, args, opts, max_retries)
                local retries = max_retries or 3
                local err_tmp = path.join(os.projectdir(), "build", "afterbuild_" .. name .. "_err.txt")
                for i = 1, retries do
                    local exec_opts = {stderr = err_tmp}
                    if opts and opts.stdout then exec_opts.stdout = opts.stdout end
                    local ok = os.execv(prog, args, exec_opts)
                    if ok then
                        if os.isfile(err_tmp) then os.rm(err_tmp) end
                        return true
                    end
                    if os.isfile(err_tmp) then
                        local err = io.readfile(err_tmp) or ""
                        os.rm(err_tmp)
                        print(string.format("  !! %s retry %d/%d failed: %s", prog, i, retries, err))
                    end
                    if i < retries then os.sleep(0.2) end
                end
                return false
            end

            local okbin = run_retry("arm-none-eabi-objcopy", {"-O", "binary", elf, path.join(dir, name .. ".bin")})
            local okhex = run_retry("arm-none-eabi-objcopy", {"-O", "ihex",   elf, path.join(dir, name .. ".hex")})
            if not (okbin and okhex) then
                raise("objcopy failed for target '" .. name .. "' (elf: " .. elf .. "), please retry")
            end
            -- 反汇编：-d 反汇编代码段，-S 穿插 C 源码行，-l 显示源文件名/行号
            local lst = path.join(dir, name .. ".lst")
            run_retry("arm-none-eabi-objdump", {"-d", "-S", "-l", "--no-show-raw-insn", elf}, {stdout = lst})
        end)

        -- 烧录：xmake run <target>  →  构建后调用 J-Link/PyOCD 烧录
        on_run(function(target)
            if not os.isfile(target:targetfile()) then
                os.exec("xmake " .. name)
            end
            local hex_path = path.join(target:targetdir(), name .. ".hex")
            if not os.isfile(hex_path) then
                raise("hex not found: " .. hex_path .. ", please build first")
            end

            local flasher = get_config("flasher") or "jlink"
            local device = get_config("device") or "CW32L010F8P6"
            local misc_dir = path.join(os.projectdir(), "misc")

            -- 查找 JLink.exe（先看 --jlinkexe 选项，再查常见路径）
            local function find_jlink()
                local exe = get_config("jlinkexe")
                if exe and os.isfile(exe) then return exe end
                local candidates = {
                    "C:/Program Files/SEGGER/JLink/JLink.exe",
                    "C:/Program Files (x86)/SEGGER/JLink/JLink.exe",
                }
                for _, c in ipairs(candidates) do
                    if os.isfile(c) then return c end
                end
                return "JLink"  -- 最后回退：期望在 PATH 中
            end

            if flasher == "none" then
                print("flasher disabled (--flasher=none), skip flashing")
                return
            elseif flasher == "jlink" then
                local script = path.join(os.projectdir(), "build", "flash_" .. name .. ".jlink")
                if not os.isdir(path.directory(script)) then os.mkdir(path.directory(script)) end
                local hex_esc = hex_path:gsub("/", "\\\\")
                io.writefile(script, string.format("erase\nloadfile %s 0 noreset\nr\ng\nexit\n", hex_esc))

                local jlink = find_jlink()
                print(string.format(">> Flashing %s with J-Link (%s)...", name, jlink))
                print(">>   device: " .. device)
                local jlink_tmp = path.join(os.projectdir(), "build", "jlink_out.txt")
                local ok = os.execv(jlink, {
                    "-device", device,
                    "-if", "swd",
                    "-speed", "4000",
                    "-JLinkScriptFile", path.join(misc_dir, "jlink-script"),
                    "-CommanderScript", script,
                }, { stdout = jlink_tmp, stderr = jlink_tmp })
                local jlink_out = ""
                if os.isfile(jlink_tmp) then
                    jlink_out = io.readfile(jlink_tmp) or ""
                    os.rm(jlink_tmp)
                end
                if not ok or jlink_out:find("FAILED") or jlink_out:find("Cannot connect") then
                    print(jlink_out)
                    raise("J-Link flash failed, please check connection/device type")
                end
            elseif flasher == "pyocd" then
                local pyocd = get_config("pyocdexe") or "pyocd"
                -- pyocd 的目标名来自 CMSIS-Pack 的 device 定义（cw32l010f8），
                -- 与 J-Link 的 --device 名（CW32L010F8P6）不同，故单独配置
                local target = get_config("pyocdtarget") or "cw32l010f8"
                -- 仓库自带的 DFP pack：pyocd 据此解析 FLASH 算法与页大小，
                -- 不带 --pack 时需事先用 pyocd pack install 安装过该器件
                local pack = get_config("packfile")
                if not (pack and os.isfile(pack)) then
                    pack = path.join(os.projectdir(), "misc", "WHXY.CW32L010_DFP.1.0.2.pack")
                end
                local common = { "-t", target, "-f", "2000000" }
                if os.isfile(pack) then
                    table.join2(common, { "--pack", pack })
                    print(">> using pack: " .. pack)
                end
                print(">> Checking debug probe with PyOCD...")
                local probe_tmp = path.join(os.projectdir(), "build", "probe_check.txt")
                os.execv(pyocd, { "list", "--probes" }, { stdout = probe_tmp, stderr = probe_tmp })
                local probe_text = ""
                if os.isfile(probe_tmp) then
                    probe_text = io.readfile(probe_tmp) or ""
                    os.rm(probe_tmp)
                end
                if probe_text:find("No available") then
                    raise("No debug probe found! Please connect probe and retry")
                end
                print(string.format(">> Erasing with PyOCD (%s, target %s)...", pyocd, target))
                local eok = os.execv(pyocd, table.join({ "erase", "-c" }, common))
                if not eok then
                    raise("PyOCD erase failed, please check connection/device type")
                end
                print(string.format(">> Flashing %s with PyOCD...", name))
                local lok = os.execv(pyocd, table.join({ "load", hex_path }, common))
                if not lok then
                    raise("PyOCD flash failed, please check connection/device type")
                end
            else
                raise("unknown flasher: " .. flasher .. " (choose jlink/pyocd/none)")
            end
            print(string.format(">> %s flashed OK", name))
        end)
    target_end()
end

-- ============================================================================
-- 应用模板（template 目录，对应 hk32f030 的 app）
-- ============================================================================
sdk_firmware("app", "template")

-- ============================================================================
-- 应用：按键控制 VBUS 电源 + WS2812 彩灯
-- ----------------------------------------------------------------------------
-- 自 CW32L010_StandardPeripheralLib_V1.0.9/Project 的 GNU Make 工程迁移而来，
-- 已改为本仓库的目录格式（USER/inc + USER/src）与 xmake 构建：
--   apps/vbus_ws2812_key/USER/inc/   板级/按键/灯效/调度/VBUS 头文件
--   apps/vbus_ws2812_key/USER/src/   对应实现 + main.c
--   sdk/bsp/rtt/                     SEGGER RTT 源码（日志输出，随仓库自带）
--   apps/vbus_ws2812_key/tools/      主机端辅助脚本（RTT 监控/诊断/调度器测试）
--
-- 功能：PA2 单击开关 VBUS（PB6），双击启动 WCH ISP 进入时序；
--       WS2812(PA4=SPI1_MOSI) 红灯指示 VBUS、蓝灯指示 ISP 进度。
-- ============================================================================
sdk_firmware("vbus_ws2812_key", "apps/vbus_ws2812_key/USER/src",
    {"../inc"},
    {
        -- 为 4KB RAM 绰身：覆盖 SEGGER RTT 官方默认值
        -- （SEGGER_RTT_Conf.h 中这些宏均有 #ifndef 保护，不修改官方源码）
        "BUFFER_SIZE_UP=512",
        "BUFFER_SIZE_DOWN=16",
        "SEGGER_RTT_MAX_NUM_UP_BUFFERS=1",
        "SEGGER_RTT_MAX_NUM_DOWN_BUFFERS=1",
    },
    {
        includedirs = {"sdk/bsp/rtt"},
        sources     = {"sdk/bsp/rtt/SEGGER_RTT.c", "sdk/bsp/rtt/SEGGER_RTT_printf.c"},
    })

-- ============================================================================
-- 参考例程（自官方 StandardPeripheralLib Examples 移植）
--   例程目录结构保留官方 USER/inc + USER/src 布局，源文件尽量零修改
-- ============================================================================
sdk_firmware("01_led_blink",       "examples/01_led_blink/USER/src", {"../inc"})
sdk_firmware("02_usart_printf",    "examples/02_usart_printf/USER/src", {"../inc"})
sdk_firmware("03_exti_key",        "examples/03_exti_key/USER/src", {"../inc"})
sdk_firmware("04_btim_timer",      "examples/04_btim_timer/USER/src", {"../inc"})
sdk_firmware("05_gtim_timer",      "examples/05_gtim_timer/USER/src", {"../inc"})
sdk_firmware("06_atim_pwm",        "examples/06_atim_pwm/USER/src", {"../inc"})
sdk_firmware("07_adc_single",      "examples/07_adc_single/USER/src", {"../inc"})
sdk_firmware("08_rtc_calendar",    "examples/08_rtc_calendar/USER/src", {"../inc"})
sdk_firmware("09_lptim_timer",     "examples/09_lptim_timer/USER/src", {"../inc"})
sdk_firmware("10_iwdt_reset",      "examples/10_iwdt_reset/USER/src", {"../inc"})
sdk_firmware("11_flash_erasewrite", "examples/11_flash_erasewrite/USER/src", {"../inc"})
sdk_firmware("12_pwr_sleep",       "examples/12_pwr_sleep/USER/src", {"../inc"})

-- ---------------------------------------------------------------------------
-- 第二批移植（13~70，覆盖官方全部剩余例程；源码零修改，仅保留 USER 结构）
-- ---------------------------------------------------------------------------
sdk_firmware("13_adc_sgl_ext_trig",   "examples/13_adc_sgl_ext_trig/USER/src", {"../inc"})
sdk_firmware("14_adc_sgl_sw_trig_ts", "examples/14_adc_sgl_sw_trig_ts/USER/src", {"../inc"})
sdk_firmware("15_adc_sgl_sw_vdd",     "examples/15_adc_sgl_sw_vdd/USER/src", {"../inc"})
sdk_firmware("16_adc_sgl_wdt",        "examples/16_adc_sgl_wdt/USER/src", {"../inc"})
sdk_firmware("17_adc_sqr_irq_sw",     "examples/17_adc_sqr_irq_sw/USER/src", {"../inc"})
sdk_firmware("18_adc_sqr_sw_vdd_ts",  "examples/18_adc_sqr_sw_vdd_ts/USER/src", {"../inc"})
sdk_firmware("19_atim_basetimer",     "examples/19_atim_basetimer/USER/src", {"../inc"})
sdk_firmware("20_atim_counter_etr",   "examples/20_atim_counter_etr/USER/src", {"../inc"})
sdk_firmware("21_atim_encoder",       "examples/21_atim_encoder/USER/src", {"../inc"})
sdk_firmware("22_atim_input_capture", "examples/22_atim_input_capture/USER/src", {"../inc"})
sdk_firmware("23_atim_pwm_phaser",    "examples/23_atim_pwm_phaser/USER/src", {"../inc"})
sdk_firmware("24_atim_trigger_adc",   "examples/24_atim_trigger_adc/USER/src", {"../inc"})
sdk_firmware("25_btim_etr",           "examples/25_btim_etr/USER/src", {"../inc"})
sdk_firmware("26_btim_toggle_10hz",   "examples/26_btim_toggle_10hz/USER/src", {"../inc"})
sdk_firmware("27_crc_calc",           "examples/27_crc_calc/USER/src", {"../inc"})
sdk_firmware("28_digitalsign",        "examples/28_digitalsign/USER/src", {"../inc"})
sdk_firmware("29_flash_fullchip_erase", "examples/29_flash_fullchip_erase/USER/src", {"../inc"})
sdk_firmware("30_flash_slib_create",  "examples/30_flash_slib_create/USER/src", {"../inc"})
sdk_firmware("31_flash_slib_call",    "examples/31_flash_slib_call/USER/src", {"../inc"})
sdk_firmware("32_gpio_hclk_pclk",     "examples/32_gpio_hclk_pclk/USER/src", {"../inc"})
sdk_firmware("33_gpio_input_output",  "examples/33_gpio_input_output/USER/src", {"../inc"})
sdk_firmware("34_gpio_int_filter",    "examples/34_gpio_int_filter/USER/src", {"../inc"})
sdk_firmware("35_gpio_swd_io",        "examples/35_gpio_swd_io/USER/src", {"../inc"})
sdk_firmware("36_gpio_wakeup_filter", "examples/36_gpio_wakeup_filter/USER/src", {"../inc"})
sdk_firmware("37_gtim_pwm_input",     "examples/37_gtim_pwm_input/USER/src", {"../inc"})
sdk_firmware("38_gtim_pwm_output",    "examples/38_gtim_pwm_output/USER/src", {"../inc"})
sdk_firmware("39_i2c_master_poll",    "examples/39_i2c_master_poll/USER/src", {"../inc"})
sdk_firmware("40_i2c_master_int",     "examples/40_i2c_master_int/USER/src", {"../inc"})
sdk_firmware("41_i2c_slave_poll",     "examples/41_i2c_slave_poll/USER/src", {"../inc"})
sdk_firmware("42_i2c_slave_int",      "examples/42_i2c_slave_int/USER/src", {"../inc"})
sdk_firmware("43_i2c_eeprom_poll",    "examples/43_i2c_eeprom_poll/USER/src", {"../inc"})
sdk_firmware("44_i2c_eeprom_int",     "examples/44_i2c_eeprom_int/USER/src", {"../inc"})
sdk_firmware("45_sw_i2c_eeprom_poll", "examples/45_sw_i2c_eeprom_poll/USER/src", {"../inc"})
sdk_firmware("46_i2c_master_by_vc",   "examples/46_i2c_master_by_vc/USER/src", {"../inc"})
sdk_firmware("47_iwdt_int",           "examples/47_iwdt_int/USER/src", {"../inc"})
sdk_firmware("48_lptim_counter",      "examples/48_lptim_counter/USER/src", {"../inc"})
sdk_firmware("49_lptim_pwm_lse",      "examples/49_lptim_pwm_lse/USER/src", {"../inc"})
sdk_firmware("50_lvd_falling_irq",    "examples/50_lvd_falling_irq/USER/src", {"../inc"})
sdk_firmware("51_lvd_both_irq",       "examples/51_lvd_both_irq/USER/src", {"../inc"})
sdk_firmware("52_lvd_level_irq",      "examples/52_lvd_level_irq/USER/src", {"../inc"})
sdk_firmware("53_rcc_hsi_hse",        "examples/53_rcc_hsi_hse/USER/src", {"../inc"})
sdk_firmware("54_rcc_hsi_lse",        "examples/54_rcc_hsi_lse/USER/src", {"../inc"})
sdk_firmware("55_rcc_hsi_lsi",        "examples/55_rcc_hsi_lsi/USER/src", {"../inc"})
sdk_firmware("56_rcc_mco",            "examples/56_rcc_mco/USER/src", {"../inc"})
sdk_firmware("57_rcc_pclkout",        "examples/57_rcc_pclkout/USER/src", {"../inc"})
sdk_firmware("58_spi_flash",          "examples/58_spi_flash/USER/src", {"../inc"})
sdk_firmware("59_spi_full_duplex_poll", "examples/59_spi_full_duplex_poll/USER/src", {"../inc"})
sdk_firmware("60_spi_simplex_int",    "examples/60_spi_simplex_int/USER/src", {"../inc"})
sdk_firmware("61_spi_slave_1line_poll", "examples/61_spi_slave_1line_poll/USER/src", {"../inc"})
sdk_firmware("62_uart_polling",       "examples/62_uart_polling/USER/src", {"../inc"})
sdk_firmware("63_uart_interrupt",     "examples/63_uart_interrupt/USER/src", {"../inc"})
sdk_firmware("64_uart_int_recv_timeout", "examples/64_uart_int_recv_timeout/USER/src", {"../inc"})
sdk_firmware("65_uart_autobaud",      "examples/65_uart_autobaud/USER/src", {"../inc"})
sdk_firmware("66_uart_1line_halfduplex", "examples/66_uart_1line_halfduplex/USER/src", {"../inc"})
sdk_firmware("67_uart_lin21",         "examples/67_uart_lin21/USER/src", {"../inc"})
sdk_firmware("68_vc_falling_irq",     "examples/68_vc_falling_irq/USER/src", {"../inc"})
sdk_firmware("69_vc_both_irq",        "examples/69_vc_both_irq/USER/src", {"../inc"})
sdk_firmware("70_vc_high_irq",        "examples/70_vc_high_irq/USER/src", {"../inc"})

-- ============================================================================
-- 任务：烧录相关（自原 GNU Makefile 的 pack / flash / erase / reset 目标迁移）
--   xmake run <target>   构建并烧录（推荐，flash + build 一步到位）
--   xmake flash         构建并烧录 vbus_ws2812_key（等价于 xmake run，原 make flash）
--   xmake erase         擦除整片 FLASH（等价于原 make erase）
--   xmake reset         复位目标（等价于原 make reset）
--   xmake pack          重新生成 misc 下的 CMSIS-Pack（等价于原 make pack）
--   RTT 监控 / 按键诊断 / 调度器主机端测试属于工具类，仍由
--   apps/vbus_ws2812_key/tools/Makefile 提供（make monitor / diag-button / test-sched / rtt）
--
-- 注：任务回调运行在独立作用域，看不到工程脚本里的全局函数，因此：
--   - flash 直接委派给目标的 on_run（xmake run），复用其探针检查与烧录逻辑；
--   - erase / reset 就地组装 pyocd 参数（并在执行前先检查探针是否在线，
--     否则 pyocd 会一直等待探针接入而不返回）。
-- ============================================================================

task("flash")
    set_category("plugin")
    on_run(function ()
        import("core.base.option")
        local name = option.get("target") or "vbus_ws2812_key"
        -- 与 `xmake run <target>` 完全等价：产物不存在时先构建，再烧录
        if not os.execv("xmake", { "run", name }) then
            raise("flash failed for target '" .. name .. "'")
        end
    end)
    set_menu({
        usage       = "xmake flash [options]",
        description = "构建并烧录（等价于 xmake run，原 make flash）",
        options     = {
            {"t", "target", "kv", "vbus_ws2812_key", "要烧录的目标名（默认 vbus_ws2812_key）"},
        }
    })
task_end()

task("erase")
    set_category("plugin")
    on_run(function ()
        local pyocd = get_config("pyocdexe") or "pyocd"
        -- pyocd 目标名来自 CMSIS-Pack 的 device 定义（与 J-Link 的 --device 不同）
        local target = get_config("pyocdtarget") or "cw32l010f8"
        -- 仓库自带的 DFP pack（缺省 misc/WHXY.CW32L010_DFP.1.0.2.pack）
        local pack = get_config("packfile")
        if not (pack and os.isfile(pack)) then
            pack = path.join(os.projectdir(), "misc", "WHXY.CW32L010_DFP.1.0.2.pack")
        end

        -- 先确认探针在线：否则 pyocd 会一直阻塞等待接入
        local probe = path.join(os.projectdir(), "build", "probe_check.txt")
        os.execv(pyocd, { "list", "--probes" }, { stdout = probe, stderr = probe })
        local txt = ""
        if os.isfile(probe) then
            txt = io.readfile(probe) or ""
            os.rm(probe)
        end
        if txt:find("No available") then
            raise("No debug probe found! Please connect probe and retry")
        end

        local args = { "-t", target, "-f", "2000000" }
        if os.isfile(pack) then
            table.join2(args, { "--pack", pack })
        end

        print(">> Erasing chip FLASH with PyOCD...")
        if not os.execv(pyocd, table.join({ "erase", "-c" }, args)) then
            raise("PyOCD erase failed, please check connection/device type")
        end
        print(">> erase OK")
    end)
    set_menu({
        usage       = "xmake erase",
        description = "擦除整片 FLASH（pyocd，等价于原 make erase）",
    })
task_end()

task("reset")
    set_category("plugin")
    on_run(function ()
        local pyocd = get_config("pyocdexe") or "pyocd"
        local target = get_config("pyocdtarget") or "cw32l010f8"
        local pack = get_config("packfile")
        if not (pack and os.isfile(pack)) then
            pack = path.join(os.projectdir(), "misc", "WHXY.CW32L010_DFP.1.0.2.pack")
        end

        local probe = path.join(os.projectdir(), "build", "probe_check.txt")
        os.execv(pyocd, { "list", "--probes" }, { stdout = probe, stderr = probe })
        local txt = ""
        if os.isfile(probe) then
            txt = io.readfile(probe) or ""
            os.rm(probe)
        end
        if txt:find("No available") then
            raise("No debug probe found! Please connect probe and retry")
        end

        local args = { "-t", target, "-f", "2000000" }
        if os.isfile(pack) then
            table.join2(args, { "--pack", pack })
        end

        print(">> Resetting target with PyOCD...")
        if not os.execv(pyocd, table.join({ "reset" }, args)) then
            raise("PyOCD reset failed, please check connection/device type")
        end
        print(">> reset OK")
    end)
    set_menu({
        usage       = "xmake reset",
        description = "复位目标（pyocd，等价于原 make reset）",
    })
task_end()

task("pack")
    set_category("plugin")
    on_run(function ()
        -- 原 Makefile 的 pack 目标：把 SDK 展开的 DFP 目录重新打包成 pyocd 可用的 .pack，
        -- 因为 pyocd 需要 zip 格式的 CMSIS-Pack，而 SDK 提供的是展开后的 DFP 目录。
        import("core.base.option")
        local dfpdir = option.get("dfpdir") or get_config("dfpdir")
        if not dfpdir then
            print(">> 未指定 DFP 目录，跳过生成；仓库已自带: misc/WHXY.CW32L010_DFP.1.0.2.pack")
            print(">> 如需重新生成：xmake pack --dfpdir=<SDK>/IDEsupport/MDK/WHXY.CW32L010_DFP")
            return
        end
        if not os.isdir(dfpdir) then
            raise("DFP dir not found: " .. dfpdir)
        end
        local out = path.join(os.projectdir(), "misc", "WHXY.CW32L010_DFP.1.0.2.pack")
        local script = path.join(os.projectdir(), "apps", "vbus_ws2812_key", "tools", "make_pack.ps1")
        local tmp = path.join(os.projectdir(), "build", "make_pack_out.txt")
        if not os.isdir(path.directory(tmp)) then os.mkdir(path.directory(tmp)) end
        local ok = os.execv("powershell", {
            "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", script,
            "-DfpDir", dfpdir, "-Out", out,
        }, {stdout = tmp, stderr = tmp})
        if os.isfile(tmp) then
            print(io.readfile(tmp) or "")
            os.rm(tmp)
        end
        if not ok then
            raise("pack generation failed")
        end
        print(">> pack OK: " .. out)
    end)
    set_menu({
        usage       = "xmake pack [options]",
        description = "由 SDK 的 DFP 目录生成 pyocd 可用的 CMSIS-Pack（等价于原 make pack）",
        options     = {
            {"d", "dfpdir", "kv", nil, "SDK 的 WHXY.CW32L010_DFP 目录（不指定则跳过）"},
        }
    })
task_end()
