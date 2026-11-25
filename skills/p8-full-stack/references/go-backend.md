# 后端 · Go + Gin 全栈

Gin 是 Go 生态最流行的轻量 HTTP 框架。本文件覆盖 Gin REST API 实现 + Go 惯用法（错误/并发/接口/包/性能/工具链）。
**任何 Go 业务逻辑必须配套单元测试（见 `go-testing.md`，强制）。**

## 1. 环境前置

```bash
go mod init <module-name>
go get -u github.com/gin-gonic/gin
go get github.com/gin-contrib/cors            # CORS
go get github.com/golang-jwt/jwt/v5           # JWT (v5 用 /v5)
```
> Gin 默认用 `github.com/go-playground/validator/v10` 做校验，标签 `binding:"..."`；冲突时统一用 `binding` 标签。

## 2. Gin 核心模式

**最小服务**
```go
r := gin.Default()
r.GET("/ping", func(c *gin.Context) { c.JSON(200, gin.H{"message": "pong"}) })
_ = r.Run(":8080")
```

**参数获取**
```go
id := c.Param("id")                         // 路径 /users/:id
q := c.Query("q"); page := c.DefaultQuery("page", "1")
var req struct {
    Name  string `json:"name" binding:"required"`
    Email string `json:"email" binding:"required,email"`
}
if err := c.ShouldBindJSON(&req); err != nil { c.JSON(400, gin.H{"error": err.Error()}); return }
```

**分组路由 + 中间件 + JWT**
```go
v1 := r.Group("/api/v1")
v1.POST("/login", loginHandler)
auth := v1.Group("/"); auth.Use(AuthMiddleware())
auth.GET("/profile", profileHandler)
```
> `ShouldBind` 按 Content-Type 自动选；`ShouldBindJSON` 强制 JSON；路由参数 `ShouldBindUri`；查询 `ShouldBindQuery`。
> **`c.JSON` 后务必 `return`**，否则重复写响应。

**CORS**
```go
r.Use(cors.New(cors.Config{
    AllowOrigins: []string{"http://localhost:5173"},
    AllowMethods: []string{"GET","POST","PUT","DELETE","OPTIONS"},
    AllowHeaders: []string{"Origin","Content-Type","Authorization"},
    AllowCredentials: true,
}))
```

**生产模式**：`gin.SetMode(gin.ReleaseMode)` 关 debug 日志。超大 JSON 用 `http.MaxBytesReader` 限流。

## 3. Go 惯用法（铁律）

1. 每个返回 error 要么处理、要么 `%w` 包装、要么返回给调用方。
2. 包装加操作与关键参数：`fmt.Errorf("load config %s: %w", path, err)`。
3. sentinel errors 放领域包；typed errors 实现 `error`。
4. 用 `errors.Is` / `errors.As` 分支，**绝不字符串比较**。
5. `context.Context` 是函数**第一参数**，永不存 struct 字段。
6. 每个 goroutine 有界：WaitGroup / 取消路径 / 缓冲发送（如 `make(chan T,1)` + `select ctx.Done()`）。
7. 每个 `context.WithCancel/WithTimeout` 后紧跟 `defer cancel()`。
8. 接口在**消费方**声明且小（1–2 方法）；构造函数返回具体 struct；可选行为用类型断言。
9. **无包级可变状态**；依赖经构造函数注入。
10. 热路径：slice 预分配 `make([]T,0,len)`、`strings.Builder`/`strings.Join`、`sync.Pool` 复用缓冲。

## 4. 标准项目布局

```
cmd/myapp/main.go        # 入口
internal/handler/        # HTTP handlers
internal/service/        # 业务逻辑
internal/repository/     # 数据访问
internal/config/         # 配置
pkg/client/              # 公开 API 客户端
api/v1/                  # API 定义
go.mod / go.sum / Makefile
```

## 5. 工具链（合并前门禁）

```bash
go build ./... && go vet ./... && go test -race -cover ./...
gofmt -w . && goimports -w . && staticcheck ./... && golangci-lint run
```
推荐 `.golangci.yml` 启用：errcheck, gosimple, govet(shadow), ineffassign, staticcheck, unused, gofmt, goimports, misspell, unconvert, unparam。

## 6. 常见坑位

- Windows 静态资源路径用正斜杠即可。
- Go `time.Time` 序列化 RFC3339；前端要时间戳须自定义 MarshalJSON。
- 缓冲 channel 防 goroutine 泄漏；`panic` 不用于控制流。
- Context 作首参，勿传 struct。
