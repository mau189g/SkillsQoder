# 前端 · 企业级开发规范

可落地、团队统一的前端规范。适用于中后台、移动端、Web 应用。

## 1. 项目目录（通用）

```
src/
├── api/          # 接口请求
├── assets/       # 静态资源
├── components/   # 公共组件
├── composables/  # 组合式函数
├── constants/    # 常量
├── hooks/        # 业务 hooks
├── layouts/      # 布局
├── pages/        # 页面
├── router/       # 路由
├── store/        # 状态管理
├── styles/       # 全局样式
└── utils/        # 工具函数
```

## 2. 命名

- 文件：组件大驼峰 `UserList.vue`；工具/页面短横线 `user-info.ts`；样式短横线 `index.scss`。
- 变量：小驼峰 `userList`；常量全大写下划线 `MAX_COUNT`；布尔 `is/has/should` 开头。
- 函数：动词开头 `getUserInfo()`。

## 3. HTML

语义化（header/main/section/aside/footer）；类名短横线；禁冗余标签/行内样式；图片必加 `alt` + `loading="lazy"`。

## 4. CSS / SCSS

BEM 或短横线；嵌套 ≤3 层；公共样式抽 variables/mixins；z-index 统一管理；单位优先 rem/vh/%；
颜色用变量禁硬编码。

## 5. JavaScript / TypeScript

- JS：const/let 禁 var；优先箭头函数；async/await；嵌套 <3 层；禁魔法数字；数组 map/filter/reduce。
- TS：必须定义接口/类型；禁 `any`（用 `unknown`）；接口 `I` 前缀或 `Type` 后缀；参数与返回值标类型；
  复用优先 `type`/`interface`。

## 6. Vue / React

- Vue：组件名多单词；props 定义类型/默认值/校验；指令缩写 `:` `@` `#`；computed 避免副作用；优先 computed 而非 watch。
- React：函数式 + Hooks；状态扁平化；禁循环/条件中用 Hooks；事件 `handle` 开头；样式 CSS Modules/styled-components。

## 7. Git / ESLint / Prettier

- Git：`type(scope): content`，type ∈ {feat,fix,docs,style,refactor,perf,test,chore}。
- ESLint+Prettier：2 空格缩进、单引号、句末分号、文件末空行、禁未用变量、禁 console（生产）。

## 8. 性能 / 安全

- 性能：图片压缩/WebP、懒加载、路由懒加载、防抖节流、虚拟滚动、减少冗余渲染。
- 安全：防 XSS（过滤输入）；防 CSRF（token 校验）；敏感信息不存 localStorage；接口做权限控制；
  禁前端明文存密钥/Token。
