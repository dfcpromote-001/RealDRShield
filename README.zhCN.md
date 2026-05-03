# 实时减伤与护盾

这是一个 World of Warcraft 插件，用于显示玩家当前的分类型减伤和护盾信息。

## 功能

- 物理减伤：护甲、全能减伤、已识别全局防御 Buff、已识别物理专属防御 Buff。
- 魔法减伤：全能减伤、已识别全局防御 Buff、已识别魔法专属防御 Buff。
- 范围减伤：Avoidance 范围减伤、全能减伤、已识别全局/范围防御 Buff。
- 全局减伤：全能减伤、已识别全局防御 Buff。
- 总护盾：通过 `UnitGetTotalAbsorbs("player")` 读取当前准确总吸收量。
- 护盾拆分：在已识别护盾光环能暴露当前数值时，估算拆分为物理盾、魔法盾、通用盾。
- 治疗吸收：可选显示 `UnitGetTotalHealAbsorbs("player")`。

## 安装

把 `RealDRShield` 文件夹复制到：

```text
World of Warcraft/_retail_/Interface/AddOns/
```

然后重启游戏，或在游戏内运行：

```text
/reload
```

之后在插件列表中启用 **Real DR Shield**。

## 命令

```text
/rds unlock      解锁框体，可用鼠标左键拖动
/rds lock        锁定框体
/rds reset       重置位置和设置
/rds hide        隐藏框体
/rds show        显示框体
/rds healabsorb  开关治疗吸收显示
/rds scan        打印当前玩家身上的光环 spell ID
```

中文命令别名：

```text
/减伤
```

## 显示口径

### 物理减伤

插件会先读取护甲减伤，再乘算全能减伤、全局防御 Buff 和物理专属防御 Buff。

### 魔法减伤

插件会乘算全能减伤、全局防御 Buff 和魔法专属防御 Buff。

### 范围减伤

插件会优先读取 Avoidance 范围减伤，再乘算全能减伤、全局防御 Buff 和范围专属防御 Buff。

### 全局减伤

插件会显示全能减伤和已识别全局防御 Buff 乘算后的结果。

## 护盾拆分限制

暴雪 API 能准确提供当前总护盾：

```lua
UnitGetTotalAbsorbs("player")
```

但它不提供一个可靠的“物理护盾 / 魔法护盾 / 通用护盾”总拆分接口。插件只能在某个已识别护盾 Buff 暴露当前剩余吸收量时，才把它归入对应分类。

无法可靠拆分的护盾会显示在“未分类”中。这是为了避免把总护盾错误归类成物理盾或魔法盾。

## 扩展 Buff 和护盾

如果要增加职业技能、饰品、套装或副本特效，编辑 `Core.lua` 里的 `auraRules` 表。

减伤示例：

```lua
[871] = { name = "Shield Wall", dr = 0.40, categories = { "global" } },
```

护盾示例：

```lua
[190456] = { name = "Ignore Pain", shieldType = "physical" },
```

可用分类：

```text
global    全局减伤
physical  物理专属减伤
magic     魔法专属减伤
aoe       范围伤害减伤
```

可用护盾类型：

```text
all       通用盾
physical  物理盾
magic     魔法盾
```

可以先在游戏中运行：

```text
/rds scan
```

然后从聊天框输出中找到当前 Buff 的 spell ID，再补进 `auraRules`。
