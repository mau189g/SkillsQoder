# 前端 · Element Plus 速查与代码生成

Element Plus（Vue 3 版，**不适用于 Element UI / Vue 2**）。两种模式：**组件速查**与**代码生成**。
布局借鉴 Avue（搜索栏 + 操作按钮 + 表格 + 分页），全量原生 Element Plus 实现。

## 1. 代码规范（生成必须遵守）

- 框架：Vue 3 + Element Plus，`<script setup>`（Composition API）。
- 语言：**JavaScript**（非 TS，除非用户要求）；样式默认不加 `scoped`。
- 图标：`@element-plus/icons-vue`，`<el-icon><Search /></el-icon>`。
- API：axios 封装，import 调用；分页后端返回 `{ records, total, current, size }`（MyBatis-Plus Page）。
- 加载：`v-loading`；提示：`ElMessage`/`ElMessageBox`/`ElNotification`。
- 不添加权限指令；关键逻辑加中文注释。

## 2. 组件速查

查询某组件用法时，返回：核心 Attributes + Events + Methods + Slots + 最小示例 + 官网链接。
全量分类（速查手册按此组织）：
- Basic：Container/Row/Col/Button/Link/Divider/Avatar/Badge/Tag
- Form：Input/InputNumber/Textarea/Select/TreeSelect/Cascader/Checkbox/Radio/Switch/Slider/Rate/ColorPicker/Date/Time/Upload/Form
- Data：Table/TableV2/Pagination/Tree/Collapse/Image/Calendar
- Feedback：Dialog/Drawer/Message/MessageBox/Notification/Loading/Popover/Tooltip/Popconfirm
- Navigation：Menu/Breadcrumb/Tabs/PageHeader/Steps/Dropdown/Affix/Backtop
- Others：Carousel/Card/Timeline/VirtualList/Watermark/Skeleton/InfiniteScroll/Anchor/Scrollbar/Splitter

## 3. CRUD 列表页（Avue 布局，默认模板）

```
搜索栏（el-form inline，可折叠 showSearch）
  └─ 输入框/下拉/日期等 + [搜索][重置]
操作按钮栏
  └─ [新增][批量删除][导出][刷新]
数据表格（el-table，v-loading）
  └─ 多选列/序号列/数据列/操作列（编辑/删除，文字按钮）
分页（el-pagination）layout="total, sizes, prev, pager, next, jumper"
弹窗（el-dialog）
  └─ 新增/编辑表单（el-form）
```

## 4. 代码生成流程

1. 判断类型：CRUD 列表页 / 表单页 / 详情页 / 单组件示例。
2. 按用户需求定制：字段名、搜索条件、表格列、操作按钮、表单字段。
3. 生成完整 `.vue`：`<template>` + `<script setup>` + `<style>`。
4. 业务字段不明 → 用合理占位符并注释说明。
5. 用户说"只生成 template"/"只要片段" → 按需缩减。

## 5. 注意事项

- 表格操作列默认文字按钮（编辑/删除），不用图标，除非要求。
- 搜索栏默认可折叠（`showSearch` 控制）。
- 所有变量 `ref`/`reactive` 声明，方法定义为顶层函数。
- 图标从 `@element-plus/icons-vue` 导入，用 `<el-icon>` 包裹。
- 以 Element Plus 2.4.x 为基准。
