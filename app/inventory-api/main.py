import time

from fastapi import Depends, FastAPI, HTTPException, Request, Response, status
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest
from sqlalchemy.orm import Session

from database import Base, engine, get_db
from models import InventoryItem, ItemCreate, ItemResponse

app = FastAPI(title="Enterprise DevOps Inventory API", version="1.0.0")

REQUEST_COUNT = Counter(
    "inventory_api_requests_total",
    "Total number of API requests",
    ["method", "endpoint", "http_status"],
)
REQUEST_LATENCY = Histogram(
    "inventory_api_request_latency_seconds",
    "Request latency in seconds",
    ["method", "endpoint"],
)
ERROR_COUNT = Counter(
    "inventory_api_errors_total",
    "Total number of error responses",
    ["method", "endpoint", "http_status"],
)


@app.middleware("http")
async def prometheus_middleware(request: Request, call_next):
    start_time = time.perf_counter()
    endpoint = request.url.path
    method = request.method
    status_code = 500

    try:
        response = await call_next(request)
        status_code = response.status_code
        return response
    except HTTPException as exc:
        status_code = exc.status_code
        raise
    except Exception:
        status_code = 500
        raise
    finally:
        REQUEST_COUNT.labels(method=method, endpoint=endpoint, http_status=str(status_code)).inc()
        REQUEST_LATENCY.labels(method=method, endpoint=endpoint).observe(time.perf_counter() - start_time)
        if status_code >= 400:
            ERROR_COUNT.labels(method=method, endpoint=endpoint, http_status=str(status_code)).inc()


@app.on_event("startup")
def startup_event() -> None:
    Base.metadata.create_all(bind=engine)


@app.get("/health")
def health_check() -> dict:
    return {"status": "ok", "service": "inventory-api"}


@app.get("/items", response_model=list[ItemResponse])
def get_items(db: Session = Depends(get_db)) -> list[InventoryItem]:
    return db.query(InventoryItem).all()


@app.post("/items", response_model=ItemResponse, status_code=status.HTTP_201_CREATED)
def create_item(item: ItemCreate, db: Session = Depends(get_db)) -> InventoryItem:
    existing_item = db.query(InventoryItem).filter(InventoryItem.name == item.name).first()
    if existing_item:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Item already exists")

    db_item = InventoryItem(name=item.name, quantity=item.quantity, price=item.price)
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item


@app.get("/metrics")
def metrics() -> Response:
    return Response(content=generate_latest(), media_type=CONTENT_TYPE_LATEST)
