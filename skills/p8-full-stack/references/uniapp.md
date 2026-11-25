# uni-app 跨平台（Vue2/3 · 迁移 · 小程序自动化测试）

uni-app 全栈开发：Vue2/Vue3 双版本、Vue2→Vue3 迁移、微信小程序自动化测试。

## 1. Vue3 开发指南

- 新项目用 Composition API（`<script setup>`）：更好的类型推导与逻辑复用。
- 响应式：`ref`/`reactive`；大对象用 `reactive`；`const {count}=toRefs(obj)` 解构保响应性。
- Props 定义类型（TS 或 propTypes）；事件用 `emit`（建议常量名）；逻辑 >50 行抽 Composable。
- 常用 composables：`useRequest`（请求+loading）、`useLoading`、`useToast`、`useModal`。
- `uni.request` 推荐 Promise/async-await；注意 `let [err,res]=await uni.request()` 非标准写法。

## 2. Vue2 → Vue3 迁移清单（强制逐项）

| 项 | Vue2 | Vue3 | 注意 |
|----|------|------|------|
| 生命周期 | `destroyed`/`beforeDestroy` | `unmounted`/`beforeUnmount` | **uni-app 页面生命周期 onLoad/onShow/onUnload 保留不变** |
| 全局 API | `new Vue()` | `createSSRApp()` | `Vue.prototype`→`app.config.globalProperties` |
| 模板 | `v-model:value` | `v-model:modelValue` | `.sync`→`v-model:xxx`；过滤器移除改计算属性 |
| 状态 | Vuex | Pinia | `createPinia()`+`app.use(pinia)`+`useStore()` |
| 样式 | `/deep/` | `:deep()` | Mixins 推荐改 Composables |

迁移策略：简单页面可保留 Options API；复杂（多 mixin/复杂响应式）才转 Composition；复杂 JS（闭包/动态 require/循环依赖）CommonJS→ESM 易错，先人工 review；超长字符串（base64/data URI）转写易截断，转换后验证完整性。

## 3. 微信小程序自动化测试

**环境检查清单**（执行前必须确认）：
- 微信开发者工具 → 安全设置 → 开启"允许自动化"。
- 开发阶段关闭"校验合法域名"。
- 自动化端口：PowerShell `cli.bat auto --project <dist/mp-weixin> --auto-port 9421`；`netstat -ano | findstr 9421` 验证 LISTENING。
- 编译输出目录：`unpackage/dist/dev/mp-weixin`（自动化测试用 dev）。

**WXML 选择器**：class（`.x`）最稳定 ⭐⭐⭐⭐⭐；id 会加前缀 `id-`；tag 泛用不推荐。
```python
from weapp_automation import AutomationConfig, WeappTestRunner
cfg = AutomationConfig(project_path=r".../dist/dev/mp-weixin", ws_endpoint="ws://localhost:9421")
runner = WeappTestRunner(cfg)
runner.navigate("pages/home/home").wait(2).click(".category-item").input("input","test").screenshot("r.png").get_results()
```
> 注意：点击用 `.click()`（非 `tap`）；输入参数名是 `text`（非 `value`）。
> 常见报错：`WebSocket connection failed`（端口未开）、`unknown error`（selector 找不到）。

## 4. 项目结构

```
pages/  components/  static/  utils/  store/(Pinia)  common/js/
uni_modules/(Vue2 语法保持不变)  App.vue  main.js  pages.json  manifest.json  vue.config.js
```

## 5. 经验教训

- 收到迁移文档：先提取【易错点/注意事项】→ 转检查清单 → 执行时同步检查。
- 创建文件后验证是否被引用、引用文件是否存在、同名 `.min.js` 与 `.js` 区分。
- 排查顺序：文档/日志 → 文件引用关系 → 最后才凭经验猜测。
