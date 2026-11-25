# 后端 · Go 测试工程

可靠、可维护的 Go 测试套件，TDD 方法论。本文件对应 SKILL.md §五「单元测试强制」门禁。
**含业务逻辑/算法/纯函数的代码必须有配套单测**，覆盖 happy path + 边界 + 错误路径。

## 1. 核心原则

1. 测试先行：先写失败测试（RED），再写最小实现（GREEN），再重构。
2. 表驱动为默认：一个 case 切片胜过十几个复制函数。
3. 测行为非实现：走公共 API，重构不破测试。
4. 助手自报身份：每个 helper 调 `t.Helper()`，失败指向调用方。
5. 独立测试并行：`t.Parallel()`。
6. 资源必释放：`t.Cleanup()` / `t.TempDir()`。
7. 名字描述场景：子测试名是 3 a.m. 读到的 bug 报告。

## 2. TDD 循环（RED→GREEN→REFACTOR）

```go
// calculator_test.go（先写，确认 FAIL）
func TestAdd(t *testing.T) {
    if got, want := Add(2,3), 5; got != want { t.Errorf("Add(2,3)=%d; want %d", got, want) }
}
// 实现最小代码使绿，再重构。
```

## 3. 表驱动测试（默认形态）

```go
func TestParseConfig(t *testing.T) {
    tests := []struct {
        name string; input string; want *Config; wantErr bool
    }{
        {"valid", `{"host":"localhost","port":8080}`, &Config{Host:"localhost",Port:8080}, false},
        {"invalid json", `{bad}`, nil, true},
        {"empty", ``, nil, true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := ParseConfig(tt.input)
            if tt.wantErr { if err == nil { t.Error("expected error") }; return }
            if err != nil { t.Fatalf("unexpected: %v", err) }
            if !reflect.DeepEqual(got, tt.want) { t.Errorf("got %+v; want %+v", got, tt.want) }
        })
    }
}
```

## 4. 并行子测试 / 助手 / 临时目录

```go
t.Run(tt.name, func(t *testing.T) { t.Parallel(); /* ... */ })
func assertNoError(t *testing.T, err error) { t.Helper(); if err != nil { t.Fatalf("unexpected: %v", err) } }
tmpDir := t.TempDir()   // 自动清理
```

## 5. Mock（接口基类）

```go
type UserRepository interface { GetUser(id string) (*User, error); SaveUser(u *User) error }
type MockUserRepository struct {
    GetUserFunc  func(id string) (*User, error)
    SaveUserFunc func(u *User) error
}
func (m *MockUserRepository) GetUser(id string) (*User, error) { return m.GetUserFunc(id) }
```

## 6. HTTP Handler 测试（httptest）

```go
func TestHealthHandler(t *testing.T) {
    req := httptest.NewRequest(http.MethodGet, "/health", nil)
    w := httptest.NewRecorder()
    HealthHandler(w, req)
    if w.Result().StatusCode != http.StatusOK { t.Errorf("got %d; want 200", w.Code) }
}
```

## 7. 基准 / 模糊 / 覆盖率

```go
func BenchmarkProcess(b *testing.B) { data := gen(1000); b.ResetTimer(); for i:=0;i<b.N;i++ { Process(data) } }
func FuzzParseJSON(f *testing.F) { f.Add(`{"name":"t"}`); f.Fuzz(func(t *testing.T, in string){ /* 断言性质非定值 */ }) }
go test -race -coverprofile=coverage.out ./...
go tool cover -func=coverage.out | grep total
```

**覆盖率目标**：关键业务逻辑 100%｜公共 API 90%+｜一般代码 80%+｜生成代码排除。CI 门禁：低于 80% 失败。

## 8. 测试命令

```bash
go test ./...                      # 全量
go test -run TestAdd ./...         # 单个
go test -race ./...                # 竞态
go test -bench=. -benchmem ./...   # 基准
go test -fuzz=FuzzX -fuzztime=30s  # 模糊
go test -count=10 ./...            # 抖动点检测
```

## 9. 关键规则

- 私有函数经公共 API 测，禁止 `_test.go` 直接调私有。
- 禁 `time.Sleep()`（用 channel/条件同步）。
- 抖动点测试修或删；跳过 = 未来故障。
- 基准 `b.ResetTimer()` 在 setup 后；变异输入的拷贝进计时环。
- 模糊断言**性质**非定值；覆盖率来自 profile 非估算。
- CI 每次跑 `-race` 并发布 coverage。
