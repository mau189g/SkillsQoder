# 后端 · 多语言与多框架（Spring Boot 对等 Go+Gin）

除 Go+Gin（见 `go-backend.md` / `go-testing.md`）外，本文件覆盖其他主流后端栈。
**所有栈统一遵循 SKILL.md 的工程纪律：单元测试强制、五维打磨、证据化验证。**
选型原则：按团队栈与场景匹配，不盲目追新；任一栈都坚持分层、DTO、统一错误、契约优先。

## 栈速查矩阵

| 语言/框架 | 定位 | 适用 | 测试基线 |
|-----------|------|------|----------|
| Java / Spring Boot | 企业级全栈、强生态 | 中大型业务、强事务、微服务 | JUnit5 + Mockito + @SpringBootTest |
| Python / FastAPI | 高性能异步 API、AI 服务 | 数据/ML 接口、轻量服务 | pytest + httpx + TestClient |
| Node.js / NestJS | 同构全栈、TS 优先 | BFF、实时、SSR 配套 | Jest + Supertest |
| Node.js / Express | 轻量、灵活 | 小服务、原型 | Jest + Supertest |
| Go / Gin | 高并发、低延迟 | 网关、基础设施 | 见 go-backend / go-testing |

---

## 1. Java · Spring Boot（对等 Go+Gin）

### 项目结构与分层
```
src/main/java/com/example/demo/
├── controller/   # @RestController，仅做参数校验与响应封装
├── service/      # 业务逻辑，事务边界（@Transactional）
├── repository/   # Spring Data JPA / MyBatis，数据访问
├── model/        # 实体（Entity）与 DTO/VO
├── config/       # 安全、CORS、Swagger
└── exception/    # 全局异常处理
```

### REST 控制器 + 校验
```java
@RestController
@RequestMapping("/api/v1/users")
@Validated
public class UserController {
    private final UserService userService;
    public UserController(UserService userService) { this.userService = userService; } // 构造注入

    @PostMapping
    public ResponseEntity<ApiResp<UserVO>> create(@Valid @RequestBody CreateUserReq req) {
        UserVO vo = userService.create(req);
        return ResponseEntity.ok(ApiResp.ok(vo));
    }
}
```

### 统一响应与全局异常
```java
@Data
public class ApiResp<T> {
    private int code; private String msg; private T data;
    public static <T> ApiResp<T> ok(T d){ ApiResp<T> r=new ApiResp<>(); r.code=0; r.msg="ok"; r.data=d; return r; }
}
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResp<Void>> handleValid(MethodArgumentNotValidException e) {
        String msg = e.getBindingResult().getFieldErrors().stream()
                .map(f -> f.getField() + ":" + f.getDefaultMessage()).findFirst().orElse("invalid");
        return ResponseEntity.badRequest().body(ApiResp.fail(400, msg));
    }
}
```

### 安全（Spring Security + JWT）
- 密码用 `BCryptPasswordEncoder` 哈希，禁止明文/弱哈希（MD5/SHA1）。
- JWT 在过滤器链校验；密钥存配置/环境变量，不进代码。
- 接口方法级鉴权用 `@PreAuthorize("hasRole('ADMIN')")`（RBAC）。

### 测试（强制）
```java
@WebMvcTest(UserController.class)              // 切片测试 controller
class UserControllerTest {
    @Autowired MockMvc mvc;
    @MockBean UserService svc;
    @Test void create_ok() throws Exception {
        when(svc.create(any())).thenReturn(new UserVO(1L,"a"));
        mvc.perform(post("/api/v1/users").contentType(APPLICATION_JSON).content("{\"name\":\"a\"}"))
           .andExpect(status().isOk()).andExpect(jsonPath("$.code").value(0));
    }
}
// 业务层：JUnit5 + Mockito；集成：@SpringBootTest + Testcontainers（真实 DB）
```
**覆盖率目标同 go-testing.md（关键逻辑 100% / 公共 API 90%+ / 一般 80%+）。**

### 常见坑位
- 事务方法自调用（同类内调用）导致 `@Transactional` 失效 → 拆到另一个 bean 或用 AOP 代理。
- N+1：JPA 关联懒加载未用 `@EntityGraph`/批量抓取 → 引发大量查询。
- 大 JSON/`@JsonIgnore` 误用泄漏敏感字段；日期序列化时区不一致。
- 异常被吞：`catch` 后只打日志不抛或返回 200。

---

## 2. Python · FastAPI（高性能异步）

### 结构
```
app/
├── main.py          # FastAPI 实例 + 路由挂载
├── routers/         # 路由（APIRouter）
├── services/        # 业务
├── models/          # Pydantic 模型（请求/响应）
├── db/              # 连接与 ORM（SQLAlchemy）
└── deps.py          # 依赖注入（DB session、当前用户）
```

### 路由 + 校验 + 依赖
```python
from fastapi import FastAPI, Depends, HTTPException
from pydantic import BaseModel, EmailStr, Field

class CreateUserReq(BaseModel):
    name: str = Field(..., min_length=1, max_length=50)
    email: EmailStr

@app.post("/api/v1/users", response_model=ApiResp)
async def create_user(req: CreateUserReq, db=Depends(get_db), user=Depends(get_current_user)):
    if not user.is_admin:
        raise HTTPException(status_code=403, detail="forbidden")
    return ApiResp.ok(service.create(db, req))
```

### 测试（强制）
```python
from fastx import TestClient
def test_create_user(client: TestClient):
    r = client.post("/api/v1/users", json={"name":"a","email":"a@b.com"})
    assert r.status_code == 200 and r.json()["code"] == 0
# pytest；异步用 httpx.AsyncClient；DB 用 fixture 建内存库/事务回滚。
```

### 常见坑位
- 同步阻塞调用（requests/重 CPU）放进线程池 `await run_in_threadpool`，否则阻塞事件循环。
- Pydantic v2 校验行为与 v1 不同；`orm_mode`→`from_attributes`。
- 不要在路径函数中直接吞异常返回 200。

---

## 3. Node.js · NestJS（TS 优先，企业级） / Express（轻量）

### NestJS 分层
```
src/
├── users/users.controller.ts   # @Controller，参数用 DTO + class-validator 管道校验
├── users/users.service.ts      # @Injectable，业务逻辑
├── users/users.module.ts       # @Module 组装
├── common/guards/              # JWT 守卫
└── main.ts
```
```typescript
@Controller('api/v1/users')
export class UsersController {
  constructor(private readonly svc: UsersService) {}
  @Post() @HttpCode(201)
  create(@Body() dto: CreateUserDto) { return this.svc.create(dto); } // DTO 经 ValidationPipe
}
```
### Express（轻量）
```javascript
app.post('/api/v1/users', validate(createSchema), async (req,res,next)=>{
  try { const u = await svc.create(req.body); res.json(apiResp.ok(u)); }
  catch(e){ next(e); }      // 统一 error 中间件
});
```

### 测试（强制）
```typescript
// NestJS: Jest + Supertest；服务层单测 mock 依赖；e2e 用 app.init() + request
it('create user returns 201', async () => {
  const res = await request(app.getHttpServer()).post('/api/v1/users').send({name:'a'});
  expect(res.status).toBe(201);
});
```

### 常见坑位
- 回调地狱/未处理 Promise rejection（加 `unhandledRejection` 监听）；async handler 漏 `await`。
- `var` 泄露、魔法数字；用 ESLint（见 frontend-spec 规则）。
- 密钥/`.env` 不进仓库；JWT 密钥强度与过期。

---

## 4. 跨栈通用后端模式（所有语言适用）

- **分层架构**：controller/router 只做校验与封装；service 承载逻辑与事务；repository 只管数据。
- **DTO 隔离**：入参/出参模型与数据库实体分离，禁止把 Entity 直接序列化外吐（防越权/泄漏）。
- **统一响应与错误码**：`{code,msg,data}` 信封；业务异常映射为明确错误码，不抛堆栈给前端。
- **分页**：游标或 offset+limit，返回 `{records,total,page,size}`（与前端 Element Plus 对齐）。
- **幂等**：写操作（支付/下单）带幂等键或唯一约束，防重复提交。
- **事务边界**：在 service 层声明，跨服务用 Saga/消息最终一致。
- **安全基线**（呼应 quality-gates）：参数化查询防注入、密码哈希、JWT 不存前端、敏感字段脱敏、最小权限。
- **可观测**：结构化日志、请求 traceId、关键路径 metrics；部署见 `architecture.md`。
