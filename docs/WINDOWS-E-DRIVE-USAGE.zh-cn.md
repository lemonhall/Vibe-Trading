# Windows E 盘隔离安装与使用手册（lemonhall）

日期：2026-07-15  
仓库：`E:\development\Vibe-Trading`  
fork：https://github.com/lemonhall/Vibe-Trading

---

## 1. 我们实际装的是什么

不是“随便 pip 一下”，而是：

1. **源码仓**：GitHub 上的 `Vibe-Trading`（本地可编辑安装）
2. **PyPI 包名**：`vibe-trading-ai`（版本快照 `0.1.11`）
3. **CLI 入口**：
   - `vibe-trading`
   - `vibe-trading-mcp`（如需 MCP）
4. **运行时**：
   - uv managed CPython **3.12.12**
   - 项目内 `.venv`
   - 依赖约 180+ 包（pandas / langchain / fastapi / yfinance / akshare / ccxt 等）

### 1.1 为什么要 E 盘隔离

本机 skill：`isolating-python-projects-on-e-drive`

目标：尽量让 Python / uv 可控写入都落在：

```text
E:\development\Vibe-Trading\
  .venv\
  .uv-python\
  .uv-cache\
  .home\          # 伪 HOME / APPDATA
  .tmp\
  .python-user\
  .pycache\
```

避免默认把缓存和用户态垃圾写到 `C:\Users\...`。

> 说明：Windows 系统本身（Defender、事件日志等）仍可能写 C 盘，这不是 Python 环境能完全禁止的。

### 1.2 安装时踩过的坑（已处理）

| 问题 | 处理 |
|---|---|
| `uv sync` 解析 `[channels]` extra 失败（`slackify-markdown` 约束） | 安装脚本 `SkipSync`，改用 `uv pip install -e .` |
| `requirements-lock.txt` 也有依赖冲突 | 不走 lock 全量安装 |
| 需要 entry points / CLI | 可编辑安装后生成 `.venv\Scripts\vibe-trading.exe` |

---

## 2. 一键脚本一览

| 文件 | 作用 |
|---|---|
| `Install-EDrive.bat` | 安装 / 修复隔离环境 |
| `Start-VibeTrading.bat` | 启动 Web UI（默认 8899） |
| `Start-VibeTrading-CLI.bat` | 启动交互 CLI |
| `scripts/windows/Install-EDriveIsolated.ps1` | 安装逻辑 |
| `scripts/windows/Enter-IsolatedEnv.ps1` | 进入隔离会话 |
| `scripts/windows/Start-WebUI.ps1` | Web 启动 |
| `scripts/windows/Start-CLI.ps1` | CLI 启动 |

### 2.1 推荐日常路径

```text
第一次：
  Install-EDrive.bat
  → vibe-trading init

以后每天：
  Start-VibeTrading.bat
  或 Start-VibeTrading-CLI.bat
```

### 2.2 安装可选组件

```powershell
# A 股 baostock + DeepSeek 原生适配 + 长桥
.\scripts\windows\Install-EDriveIsolated.ps1 -WithAshare -WithDeepseek -WithLongbridge
```

---

## 3. 首次配置

```powershell
. .\scripts\windows\Enter-IsolatedEnv.ps1
vibe-trading init
```

你通常需要：

1. **LLM Provider**（二选一或多选）
   - OpenAI / DeepSeek / 月之暗面 / Qwen / OpenRouter 等
2. **可选数据 token**
   - `TUSHARE_TOKEN`（A 股增强）
   - 其他付费源按需
3. **远程访问时**
   - `API_AUTH_KEY`（强随机串）

配置文件优先位置（隔离后）：

```text
E:\development\Vibe-Trading\.home\.vibe-trading\.env
```

也可用：

```text
E:\development\Vibe-Trading\agent\.env
```

排查 provider：

```powershell
vibe-trading provider doctor
```

---

## 4. 启动方式

### Web UI

```powershell
.\Start-VibeTrading.bat
# 或
.\scripts\windows\Start-WebUI.ps1 -Port 8899
```

浏览器打开：http://localhost:8899

### 交互 CLI

```powershell
.\Start-VibeTrading-CLI.bat
```

### 单次任务

```powershell
. .\scripts\windows\Enter-IsolatedEnv.ps1
vibe-trading run -p "......"
```

---

## 5. 提示词模板（可直接改数字）

### 5.1 回测类

**加密双均线**

```text
回测 BTC-USDT 在 2024-01-01 到 2024-12-31 的 20/50 双均线策略。
输出：总收益、年化、最大回撤、夏普、交易次数，并导出报告。
说明滑点与手续费假设。
```

**A 股 RSI**

```text
对 000001.SZ 使用 2022 至今日线数据，回测 RSI(14) 策略：
RSI < 30 买入，RSI > 70 卖出。
请报告绩效，并指出是否存在未来函数或过拟合风险。
```

**港股 / 美股对比**

```text
比较 0700.HK 与 AAPL 近 2 年动量与波动，
给出趋势跟踪是否可行的结论，并列出失效条件。
```

### 5.2 研究类

```text
用自然语言解释当前 BTC 资金费率与基差大概意味着什么，
并给出 2 个可回测的交易假设（不要直接建议我重仓）。
```

```text
帮我把“低波动高分红股票轮动”写成可回测规则：
选股池、再平衡频率、过滤条件、风控，然后先在美股 SPY 成分近似池上做简化回测。
```

### 5.3 交易日志 / Shadow Account

```text
分析我上传的成交明细：
1) 持仓天数、胜率、盈亏比、最大回撤
2) 是否有处置效应 / 过度交易 / 追涨
3) 提取我的影子交易规则
4) 与真实成交对比，输出 HTML 报告
```

配合：

```powershell
vibe-trading --upload trades_export.csv
vibe-trading run -p "（上面那段）"
```

### 5.4 Alpha Zoo

```powershell
vibe-trading alpha list
vibe-trading alpha show gtja_001
vibe-trading alpha bench --zoo gtja191 --universe csi300 --period 2018-2025 --top 20
vibe-trading alpha compare <id1> <id2> <id3> --sort ir
```

### 5.5 导出

```text
生成 BTC-USDT 的 MACD 策略，回测近 180 天，
导出 TradingView Pine Script，并说明参数默认值。
```

---

## 6. 推荐工作流（稳妥）

1. **先研究，不接实盘**
2. 用 `run -p` 或 Web UI 跑通一条最小回测
3. 看 artifacts / run card，检查是否有 warning
4. 同一假设换区间 / 换标的做稳健性
5. 需要自动化时再接 MCP 或 IM channels
6. 实盘（若有）单独建 connector profile，并设置硬止损 / 人工确认

---

## 7. 验证清单（安装后自检）

在隔离会话中执行：

```powershell
. .\scripts\windows\Enter-IsolatedEnv.ps1
python -c "import sys; print(sys.executable); print(sys.base_prefix)"
vibe-trading --version
uv cache dir
uv python dir
```

期望：

- `sys.executable` 在 `E:\development\Vibe-Trading\.venv\...`
- `sys.base_prefix` 在 `E:\development\Vibe-Trading\.uv-python\...`
- `uv cache dir` / `uv python dir` 都在 E 盘项目下
- `vibe-trading --version` 输出版本号

---

## 8. 常见问题

### Q1：`uv sync` 失败？

正常。本 fork 不依赖 `uv sync` 装基础功能。用：

```powershell
.\scripts\windows\Install-EDriveIsolated.ps1
```

### Q2：Web UI 从手机访问 403？

远程默认不信任。在 `.env` 设：

```env
API_AUTH_KEY=请换成足够长的随机串
```

重启 `serve`，在 Settings 填同一个 key。

### Q3：为什么配置写到 `.home`？

因为隔离环境把 `HOME`/`USERPROFILE` 指到项目内 `.home`，这是为了不写 C 盘用户目录。

### Q4：能不能装 channels（Telegram/飞书等）？

可以试，但不保证当前上游 extra 元数据可解析。建议按单个 extra 装，而不是一把梭 `channels`。

### Q5：这能保证赚钱吗？

不能。它是研究工作台。回测≠未来收益。

---

## 9. 本次落地文件清单

```text
Install-EDrive.bat
Start-VibeTrading.bat
Start-VibeTrading-CLI.bat
README.zh-cn.md
docs/WINDOWS-E-DRIVE-USAGE.zh-cn.md
scripts/windows/Enter-IsolatedEnv.ps1
scripts/windows/Install-EDriveIsolated.ps1
scripts/windows/Start-WebUI.ps1
scripts/windows/Start-CLI.ps1
.gitignore                 # 增补隔离目录忽略
```

---

## 10. 给未来的自己

如果重装机器：

1. 把仓库放回 `E:\development\Vibe-Trading`
2. 确认 `uv` 可用、代理 `127.0.0.1:7897` 可用
3. 跑 `Install-EDrive.bat`
4. `vibe-trading init`
5. `Start-VibeTrading.bat`

无需再手工回忆命令。
