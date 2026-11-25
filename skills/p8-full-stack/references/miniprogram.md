# 微信小程序全栈（云开发 / 支付 / 分包 / Skyline）

微信小程序从初始化到生产发布的全链路。基础库 ≥2.2.3（云开发）/ ≥3.0（Skyline）。

## 1. 激活场景

提及"微信小程序 / 小程序 / wxml / wxss / miniprogram"；需分包（≤2MB）/ 云开发 / 登录（openid/unionid）/
微信支付（JSAPI/退款）/ 直播(TRTC) / 数据分析埋点 / 分享海报 / TypeScript / 云托管 / 客服订阅消息 /
内容安全 / 互跳 / 蓝牙GPSNFC / Skyline 动画 / WXS / CI/CD。

## 2. 项目初始化（骨架）

```
project.config.json   # cloudfunctionRoot + miniprogramRoot
app.json              # pages + subpackages + tabBar + usingComponents
app.js                # wx.cloud.init + 静默登录
pages/  components/  cloudfunctions/  miniprogram_npm/
```

## 3. 云开发（DB / 存储 / 云函数）

```javascript
wx.cloud.init({ env: 'your-env-id', traceUser: true });   // 小程序端用字符串 env
const db = wx.cloud.database();
await db.collection('posts').add({ data: { title:'标题', _openid, createdAt: db.serverDate() } });
await db.collection('posts').where({ _openid }).get();
```
- 云函数内 **自动** 获取 openid：`cloud.getWXContext().OPENID`，**不要** 前端传回再传回。
- env：云函数内用 `cloud.DYNAMIC_CURRENT_ENV`；小程序端用字符串 env（DYNAMIC_CURRENT_ENV 在端上为 undefined）。
- 聚合查询、事务、权限规则见云开发文档。

## 4. 登录鉴权（2024+ 标准）

```html
<button open-type="chooseAvatar" bindchooseavatar="onChooseAvatar"><image src="{{avatarUrl}}"/></button>
<input type="nickname" bindinput="onNicknameInput" />
```
> 已废弃 `wx.getUserInfo` / `getUserProfile`，改用"头像昵称"按钮组合。手机号登录走 `button open-type="getPhoneNumber"`。

## 5. 微信支付（JSAPI / 退款）

- 统一下单（服务端/云函数）→ 前端 `wx.requestPayment({timeStamp, nonceStr, package, signType, paySign})`。
- 支付通知：服务端校验签名；退款走 API。密钥/商户号不进前端。

## 6. 分包（上线前必做，每个包 ≤2MB）

```
主包保持 ≤1.5MB；pages.json/app.json 的 subpackages 拆页面；预加载跨包资源。
```
分包规则：主包不能引用分包组件；跨分包用 `wx.cloud.callFunction` 或 eventBus 解耦。

## 7. Skyline / Worklet 动画

```javascript
onReady(){ const { shared, spring } = wx.worklet; this._scale = shared(1);
  this.applyAnimatedStyle('#box', ()=>{ 'worklet'; return { transform:`scale(${this._scale.value})` }; }); }
handleTap(){ 'worklet'; this._scale.value = spring(1.2,{damping:15,stiffness:200}); }
```
> 所有 worklet 函数第一行必须 `'worklet'`；Worklet 内只能 `runOnJS()` 回调到 JS 线程调 wx API。

## 8. 常见错误速查

| 错误 | 原因 | 解决 |
|------|------|------|
| `app.json not found` | 工作目录/root 错 | 确保根目录，miniprogramRoot 指向正确 |
| 云函数 500 | env 未初始化/未部署 | 云函数内 `cloud.init({env: DYNAMIC_CURRENT_ENV})` |
| 包超 2MB | 资源过大 | 压缩/移动分包/CDN |
| 分包 404 | root 不匹配 | 路径不带 `/` 前缀，与实际目录一致 |
| setData 卡顿 | 滚动中频繁 setData | 用 Worklet SharedValue 精准更新 |
| chooseAvatar 取消 | 用户取消 | 引导或默认头像 |

## 9. 内容安全 / 互跳 / 硬件 / CI

- 内容安全：`msgSecCheck`/`imgSecCheck` 审核用户内容（文本/图片/音视频）。
- 互跳：APP↔小程序用 URL Scheme / 开放标签；扫一扫 sun 码。
- 硬件：BLE/NFC/GPS/Wi-Fi 需用户授权，提供降级。
- CI/CD：miniprogram-ci 自动构建上传；GitHub Actions 提交审核。
- **自我进化**：同类错误 ≥3 次沉淀为固定解法。
