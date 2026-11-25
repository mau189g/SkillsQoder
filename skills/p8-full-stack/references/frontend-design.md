# 前端 · 独特视觉设计

生成**极具视觉冲击力、生产级、去 AI 味**的前端界面：独特排版、统一色彩主题、编排动效、
非对称布局、氛围化背景，直接产出可运行 HTML/CSS/JS 或 React/Vue 代码。中文需求必读本文件。

## 1. 核心方法

1. **先想后写**：锁定 Purpose（问题/受众）→ Tone（一个极端方向）→ Constraints（框架/性能/可访问性）→ Differentiation（记忆点）。
2. **锁定一种美学方向**（勿混三种成一团糊）：
   | 方向 | 关键词 | 适用 |
   |------|--------|------|
   | Brutally minimal | 极致留白、单一强调色、精确间距 | 工具、专业服务 |
   | Maximalist chaos | 层叠、混排、撞色、密度 | 潮流、娱乐、活动 |
   | Retro-futuristic | CRT 扫描线、霓虹、等宽字体 | 硬件、开发者工具 |
   | Organic / natural | 柔和曲线、大地色、纸质纹理 | 健康、食品、户外 |
   | Luxury / refined | 衬线大标题、克制金箔、大留白 | 高端消费、酒店 |
   | Editorial / magazine | 多栏网格、大字距、规则线 | 内容、媒体 |
   | Brutalist / raw | 裸露边框、原生控件感、黑粗线 | 创意工作室 |
   | Playful / toy-like | 圆角、明快色块、弹性动效 | 儿童、社交、C 端 |
   | Industrial | 仪表盘感、等宽数字、密信息 | 运维、监控、B 端 |

3. **四美学支柱**：Typography（独特展示字 + 内敛正文字，禁用 Inter/Roboto/Arial/system-ui 作展示面）｜
   Color & Theme（CSS 变量统一，主色主导 + 锐利强调色）｜Motion（优先 CSS，一次编排入场序列胜零散微交互）｜
   Composition（非对称、重叠、对角线、破格、留白或密度可控）。
4. **加氛围非平涂**：渐变网格、噪声纹理、几何图案、分层透明、戏剧阴影、装饰边框、自定义光标、颗粒叠加。
5. **复杂度匹配愿景**：极简靠精度与间距，非堆效果。

## 2. 关键规则

- 禁止默认审美：无 purple-gradient-on-white、无 predictable 三卡 hero 网格。
- 锁定一个方向并执行到焦点环；每次产出看起来都像"为这个场景设计"。
- **可访问性不可妥协**：正文对比度 ≥4.5:1（大字 ≥3:1）、触摸目标 ≥44×44px、可见焦点环、语义 HTML、键盘可达。
- **动效优雅降级**：每个动画元素尊重 `prefers-reduced-motion`。
- 交付可运行代码（结构+注释），无占位 "add your content here" 桩。
- 复杂度随愿景，非随习惯。

## 3. 工作流

1. **Direction Lock**：写一段定调（受众、风格方向、展示字/正文字、主色/强调色）。
2. **Foundations**：CSS 变量（颜色/字阶/间距/圆角/阴影/动效），明确 light/dark 基。
3. **Composition**：非对称/重叠/对角线/破格布局。
4. **Atmosphere**：背景与纹理层。
5. **Motion**：编排一次入场序列（staggered `animation-delay`）+ 滚动触发 + hover。
6. **QA**：跑反 AI 味清单，修每处命中；验证对比度、焦点态、reduced-motion、响应式。

## 4. 美学基准值

| 项目 | 基准 |
|------|------|
| 展示字 | ≥48px，字距 -0.02em~-0.04em |
| 正文行长 | 45–75 字符（中文 28–40 字）；行高正文 1.5–1.7，大标题 0.95–1.1 |
| 配色比例 | 主色 60% / 辅助 30% / 强调 10%；单页 ≤1 强调色 |
| 入场序列 | 3–6 组，间隔 60–120ms |
| 动效时长 | 微交互 150–200ms / 常规 300–400ms / 场景 600–800ms |
| 缓动 | `cubic-bezier(0.16,1,0.3,1)`（出场）/ `ease-out`（入场） |
| 阴影层级 | 3 级，Y 偏移 2/8/24px；首屏关键 CSS 内联，`font-display: swap` |

## 5. 交付物

Design Direction Note（定调）｜Working Frontend Code（可运行）｜Design Token Block（CSS 变量）｜
Motion Spec（入场/滚动/hover/降级）｜QA Checklist 结果。
