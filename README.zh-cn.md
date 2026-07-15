# Vibe-Trading · 中文快速上手（lemonhall fork）

> 上游项目：[HKUDS/Vibe-Trading](https://github.com/HKUDS/Vibe-Trading)  
> 本 fork： [lemonhall/Vibe-Trading](https://github.com/lemonhall/Vibe-Trading)  
> 本页记录 **Windows + E 盘隔离安装**、**一键启动** 与 **中文使用示例**。

---

## 这是什么

**Vibe-Trading** 是一个用自然语言做金融研究 / 回测 / 报告导出的开源 Agent 工作台。

- 自然语言提问 → 拉行情 → 生成策略 → 回测 → 报告 / Pine / TDX 等导出  
- 支持 A 股 / 港美股 / 加密 / 多数据源 fallback  
- 提供 CLI、Web UI、MCP  
- **默认定位是研究与模拟**；实盘需你自己授权券商连接器，且务必风控

> 安全提醒：官方从不发币。任何同名代币 / 假冒社媒都不是官方。详见上游 `SECURITY.md`。

---

## 本 fork 额外做了什么（2026-07-15）

在柠檬叔的 Windows 11 环境（`E:\development`）上完成并固化了：

1. **E 盘 Python 隔离安装**  
   使用 skill `isolating-python-projects-on-e-drive`，把 managed Python、`.venv`、uv 缓存、临时目录、`HOME`/`APPDATA` 等尽量关进项目目录，避免污染 C 盘。
2. **绕过上游 `uv sync` 的 channels extra 解析坑**  
   上游 `pyproject.toml` 的 optional `[channels]` 在部分 Python 标记组合下会因 `slackify-markdown` 版本约束解析失败。  
   本 fork 安装脚本默认改为：`uv pip install -e .`（基础包，够 CLI/Web/回测）。
3. **一键脚本**
   - `Install-EDrive.bat`：安装 / 修复隔离环境  
   - `Start-VibeTrading.bat`：一键开 Web UI（默认 `http://localhost:8899`）  
   - `Start-VibeTrading-CLI.bat`：一键开交互 CLI  
   - `scripts/windows/*.ps1`：对应 PowerShell 实现
4. **中文文档**
   - 本文件 `README.zh-cn.md`  
   - 更细的使用说明与提示词：`docs/WINDOWS-E-DRIVE-USAGE.zh-cn.md`

### 当前本机验证快照

| 项 | 值 |
|---|---|
| 路径 | `E:\development\Vibe-Trading` |
| 包版本 | `vibe-trading-ai 0.1.11` |
| Python | 3.12.12（uv managed，项目内 `.uv-python`） |
| CLI | `.venv\Scripts\vibe-trading.exe` |
| 隔离缓存 | `.uv-cache` / `.tmp` / `.home` 均在项目目录 |

---

## 5 分钟上手（Windows）

### 0. 前置

- 仓库放在 **E 盘**（推荐 `E:\development\Vibe-Trading`）
- 已安装 [uv](https://github.com/astral-sh/uv)
- 建议本机代理：`http://127.0.0.1:7897`（脚本默认会用）

### 1. 安装（只需一次）

双击：

```text
Install-EDrive.bat
```

或 PowerShell：

```powershell
.\scripts\windows\Install-EDriveIsolated.ps1
```

可选 extras：

```powershell
.\scripts\windows\Install-EDriveIsolated.ps1 -WithAshare -WithDeepseek
```

### 2. 首次配置 LLM

```powershell
. .\scripts\windows\Enter-IsolatedEnv.ps1
vibe-trading init
```

按提示写入 provider / API key。配置会落在隔离后的用户目录：

```text
E:\development\Vibe-Trading\.home\.vibe-trading\.env
```

（也兼容项目内 `agent/.env`）

### 3. 一键启动

| 方式 | 动作 |
|---|---|
| Web UI | 双击 `Start-VibeTrading.bat` → 浏览器打开 http://localhost:8899 |
| 交互 CLI | 双击 `Start-VibeTrading-CLI.bat` |
| 单次研究 | 见下方示例 |

---

## 常用命令

```powershell
. .\scripts\windows\Enter-IsolatedEnv.ps1

vibe-trading --version
vibe-trading init
vibe-trading                       # 交互 CLI
vibe-trading serve --port 8899     # Web UI
vibe-trading run -p "你的研究问题"
vibe-trading alpha list
vibe-trading alpha bench --zoo gtja191 --universe csi300 --period 2018-2025 --top 20
vibe-trading provider doctor
```

---

## 使用示例（提示词可直接抄）

### 1）加密货币均线回测

```powershell
vibe-trading run -p "回测 BTC-USDT 在 2024 年的 20/50 双均线策略，汇总收益率、最大回撤、夏普，并导出报告"
```

### 2）A 股技术策略

```powershell
vibe-trading run -p "用 000001.SZ 近 3 年数据回测 RSI(14) 超买超卖策略，说明参数、胜率、最大回撤，并给出改进建议"
```

### 3）美股动量研究

```powershell
vibe-trading run -p "分析 AAPL 近 1 年动量与波动，对比 SPY，给出是否适合趋势跟踪的结论和风险点"
```

### 4）上传成交记录做行为诊断（Shadow Account）

```powershell
vibe-trading --upload trades_export.csv
vibe-trading run -p "分析我的交易行为，提取我的影子策略规则，并和真实成交对比，输出 HTML 报告"
```

### 5）Alpha Zoo 横评

```powershell
vibe-trading alpha bench --zoo gtja191 --universe csi300 --period 2018-2025 --top 20
```

### 6）策略导出到 TradingView

```powershell
vibe-trading run -p "生成一个适用于 BTC-USDT 的 MACD 策略，回测最近 180 天，并把指标导出为 TradingView Pine Script"
```

更多提示词与排错见：

- [`docs/WINDOWS-E-DRIVE-USAGE.zh-cn.md`](docs/WINDOWS-E-DRIVE-USAGE.zh-cn.md)

---

## 目录约定（本 fork）

```text
E:\development\Vibe-Trading\
  Install-EDrive.bat              # 一键安装
  Start-VibeTrading.bat           # 一键 Web UI
  Start-VibeTrading-CLI.bat       # 一键 CLI
  README.zh-cn.md                 # 本文件
  docs\WINDOWS-E-DRIVE-USAGE.zh-cn.md
  scripts\windows\                # PowerShell 实现
  .venv\                          # 虚拟环境（不入库）
  .uv-python\ .uv-cache\ .home\   # 隔离目录（不入库）
```

---

## 已知限制

1. **不要默认 `uv sync` 全量 channels**  
   上游 `[project.optional-dependencies].channels` 目前可能解析失败；基础功能用 `-e .` 即可。
2. **系统级写入无法 100% 消除**  
   E 盘隔离只管 Python/uv 可控路径；Windows Defender / 事件日志等仍可能写 C 盘。
3. **远程访问 Web UI 需要 `API_AUTH_KEY`**  
   默认信任本机 loopback；局域网访问请先设强密钥。
4. **交易有风险**  
   研究工具 ≠ 盈利承诺。任何实盘前请自己做风控与合规检查。

---

## 上游文档

- 英文 README：`README.md`
- 官方中文长文：`README_zh.md`
- 官网 / 文档：https://vibetrading.wiki/

---

## 许可证

与上游一致：MIT（见 `LICENSE`）。
