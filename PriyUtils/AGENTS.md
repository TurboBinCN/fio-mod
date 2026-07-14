# PriyUtils Mod 开发规则

## 项目概况
- 项目目录：e:\fio_mods\PriyUtils
- Factorio mod 项目

## 引用全局规则
@file ../AGENTS.md

## Log 模块配置
- Log 模块路径: e:\fio_mods\PriyUtils\scripts\message_panel.lua
- 必须使用 message_panel 提供的 log 函数，禁止直接使用 Factorio 原生 log 函数

## Log 级别使用规范
- `message_panel.debug(msg, ...)`: 详细调试信息，函数入口/出口、变量值、执行流程
- `message_panel.info(msg, ...)`: 重要流程信息，状态变化、配置变更、数据同步
- `message_panel.warn(msg, ...)`: 警告信息，边界条件、潜在问题、非致命异常
- `message_panel.error(msg, ...)`: 错误信息，运行时错误、异常情况、致命问题

## Log 控制配置
- `message_panel.set_log_level("DEBUG|INFO|WARN|ERROR|NONE")`: 控制日志级别
- `message_panel.set_game_print(true/false)`: 控制是否在游戏内打印
- `message_panel.set_log_file(true/false)`: 控制是否写入日志文件

## Log 输出格式
- 格式: `[PriyUtils] [tick] [LEVEL]: message`
- 使用 string.format 进行参数格式化
- 复杂数据使用 `message_panel.dump_table(tbl, name)` 输出

## 开发调试流程
1. 在 control.lua 开头引入 message_panel
2. 设置日志级别为 DEBUG（开发阶段）
3. 在关键函数入口/出口添加 log
4. 在状态变化和异常处理处添加 log
5. 运行游戏测试并查看 factorio-current.log
6. 定位问题后修复，确认 log 输出正确
7. 发布前将日志级别调整为 INFO 或 WARN