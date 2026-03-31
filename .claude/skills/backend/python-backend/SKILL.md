---
name: python-backend
description: "Python backend with FastAPI, Django, SQLAlchemy. Type-safe, async-first, production patterns."
paths:
  - "**/*.py"
  - "**/requirements.txt"
  - "**/pyproject.toml"
  - "**/alembic/**"
---

# Python Backend Expert

Modern Python backend patterns. Type hints everywhere, async by default.

## Framework Detection

- `fastapi` → FastAPI
- `django` → Django
- `flask` → Flask
- `sqlalchemy` → SQLAlchemy ORM
- `alembic` → Database migrations
- `celery` → Task queue

## FastAPI Patterns

### Project Structure
```
src/
├── main.py                    # App entry point
├── config.py                  # Settings with Pydantic
├── database.py                # DB session management
├── modules/
│   ├── users/
│   │   ├── router.py          # API endpoints
│   │   ├── service.py         # Business logic
│   │   ├── schemas.py         # Pydantic models
│   │   ├── models.py          # SQLAlchemy models
│   │   └── dependencies.py    # DI providers
│   └── orders/
│       └── ...
├── middleware/
│   ├── auth.py
│   └── error_handler.py
├── lib/
│   ├── exceptions.py          # Custom exceptions
│   └── pagination.py          # Reusable pagination
└── tests/
    ├── conftest.py
    └── modules/
        └── users/
            └── test_router.py
```

### Configuration (Fail Fast)
```python
# config.py
from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    database_url: str
    redis_url: str | None = None
    jwt_secret: str
    cors_origins: list[str] = ["http://localhost:3000"]
    debug: bool = False

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}

@lru_cache
def get_settings() -> Settings:
    return Settings()
```

### Router Pattern
```python
# modules/users/router.py
from fastapi import APIRouter, Depends, HTTPException, status
from .schemas import CreateUser, UserResponse, UserListResponse
from .service import UsersService
from ..auth.dependencies import get_current_user

router = APIRouter(prefix="/api/users", tags=["users"])

@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(body: CreateUser, service: UsersService = Depends()):
    return await service.create(body)

@router.get("/", response_model=UserListResponse)
async def list_users(
    page: int = 1,
    per_page: int = 20,
    service: UsersService = Depends(),
    current_user = Depends(get_current_user),
):
    return await service.list(page=page, per_page=per_page)

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(user_id: str, service: UsersService = Depends()):
    user = await service.find_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
```

### Pydantic Schemas
```python
# modules/users/schemas.py
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime

class CreateUser(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)

class UpdateUser(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=100)
    email: EmailStr | None = None

class UserResponse(BaseModel):
    id: str
    name: str
    email: str
    role: str
    created_at: datetime

    model_config = {"from_attributes": True}

class UserListResponse(BaseModel):
    data: list[UserResponse]
    meta: PaginationMeta
```

### SQLAlchemy Async Pattern
```python
# database.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from config import get_settings

engine = create_async_engine(
    get_settings().database_url,
    pool_size=20,
    max_overflow=10,
    pool_pre_ping=True,
)

async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

async def get_db():
    async with async_session() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

### Error Handling
```python
# lib/exceptions.py
class AppError(Exception):
    def __init__(self, status_code: int, code: str, message: str, details=None):
        self.status_code = status_code
        self.code = code
        self.message = message
        self.details = details

# middleware/error_handler.py
from fastapi import Request
from fastapi.responses import JSONResponse

async def app_error_handler(request: Request, exc: AppError):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": exc.code,
                "message": exc.message,
                "details": exc.details,
            }
        },
    )

# main.py
app.add_exception_handler(AppError, app_error_handler)
```

### Testing
```python
# tests/conftest.py
import pytest
from httpx import AsyncClient, ASGITransport
from main import app
from database import engine

@pytest.fixture
async def client():
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as ac:
        yield ac

# tests/modules/users/test_router.py
@pytest.mark.anyio
async def test_create_user(client: AsyncClient):
    response = await client.post("/api/users/", json={
        "name": "Test User",
        "email": "test@example.com",
        "password": "securepassword123",
    })
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Test User"
    assert "password" not in data
```

## Python Best Practices

- Type hints on ALL function signatures (parameters + return)
- Use `async/await` for I/O operations (DB, HTTP, file)
- Use `ruff` for linting + formatting (replaces black, isort, flake8)
- Use `mypy` for type checking in CI
- Use `pytest` with `anyio` for async tests
- Use `alembic` for database migrations
- Use `structlog` for structured logging
- Pin dependencies with exact versions in production
