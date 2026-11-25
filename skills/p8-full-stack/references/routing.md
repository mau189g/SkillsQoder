# 意图路由与协同顺序（从 SKILL.md §四 展开）

本文件细化路由判断与多意图协同的顺序。路由未命中时，先按"信息查询 / 简单任务 / 复杂任务"三分法归类。

## 1. 意图三分法（先定档位，再路由）

| 类别 | 特征 | 处理 |
|------|------|------|
| **信息查询** | "怎么写/为什么/有啥规范"、只读 | 直接答，不改动文件 |
| **简单任务** | 明确、小、低风险、≤1 文件 | 快速通道：轻量/常规档直接执行 |
| **复杂任务** | 多文件/跨模块/DB·配置·构建链/安全/批量/业务不明 | 复杂档：方案先行 + 影响面 + 全量清单 |

## 2. 显式调用（跳过路由）

输入以 `@<子能力>` 开头（独立成段）可直接加载对应 reference，跳过关键词匹配：
`@vue` → frontend-vue｜`@element-plus` → element-plus｜`@design` → frontend-design｜
`@spec` → frontend-spec｜`@go` → go-backend｜`@go-test` → go-testing｜`@mp` → miniprogram｜
`@uniapp` → uniapp｜`@review` → code-review｜`@arch` → architecture。拼写错回退关键词。

## 3. 任务-技能不匹配提示

强冲突时提示确认，不擅自切换：实现+审查 → 问是否转 `@review`；审查+实现 → `@code-generation`；
实现+报错 → `@bug-diagnosis`（走 debugging）；重构+新功能 → 实现优先。回复"按原指定执行"即不再追问。

## 4. 多意图协同顺序

1. 先定位与评估（只读），再动手。
2. 实现类：分析 → 方案 → 执行 → **打磨 → 验证（含单测）** → 交付。
3. 审查类：加载 code-review，输出分层清单；确认后再修复（审计修复分离）。
4. 跨栈类（如"搭一个带登录的后台"）：arch → frontend-vue/element-plus（前端）+ go-backend（后端）+ 单测。
5. 命中 ≥2 专项仍受单次 ≤3 协同 reference 约束（强制加载集不计）。

## 5. 关键词 → 子能力 速查

| 关键词样例 | 子能力 |
|-----------|--------|
| vue、组件、pinia、router、nuxt、vapor、vue2 迁移 | frontend-vue |
| element plus、el-table、el-form、crud 页、avue | element-plus |
| 前端设计、落地页、视觉、动效、去 ai 味、排版 | frontend-design |
| 命名规范、目录规范、eslint、git 规范、前端最佳实践 | frontend-spec |
| gin、go 后端、rest api、jwt、cors、go 模式、并发 | go-backend |
| go 测试、表驱动、基准、模糊、覆盖率、tdd | go-testing |
| 微信小程序、云开发、微信支付、分包、skyline、内容安全 | miniprogram |
| uniapp、vue2→vue3 迁移、小程序自动化测试 | uniapp |
| 审查、review、找问题、代码质量 | code-review |
| 架构、技术选型、api 设计、数据库、鉴权、部署、测试策略 | architecture |
