from fastapi import Depends, FastAPI, HTTPException, Response, status
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


@app.on_event("startup")
def startup_event() -> None:
    Base.metadata.create_all(bind=engine)


@app.get("/health")
def health_check() -> dict:
    REQUEST_COUNT.labels("GET", "/health", "200").inc()
    return {"status": "ok", "service": "inventory-api"}


@app.get("/items", response_model=list[ItemResponse])
def get_items(db: Session = Depends(get_db)) -> list[InventoryItem]:
    with REQUEST_LATENCY.labels("GET", "/items").time():
        items = db.query(InventoryItem).all()
    REQUEST_COUNT.labels("GET", "/items", "200").inc()
    return items


@app.post("/items", response_model=ItemResponse, status_code=status.HTTP_201_CREATED)
def create_item(item: ItemCreate, db: Session = Depends(get_db)) -> InventoryItem:
    with REQUEST_LATENCY.labels("POST", "/items").time():
        existing_item = db.query(InventoryItem).filter(InventoryItem.name == item.name).first()
        if existing_item:
            REQUEST_COUNT.labels("POST", "/items", "409").inc()
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Item already exists")

        db_item = InventoryItem(name=item.name, quantity=item.quantity, price=item.price)
        db.add(db_item)
        db.commit()
        db.refresh(db_item)

    REQUEST_COUNT.labels("POST", "/items", "201").inc()
    return db_item


@app.get("/metrics")
def metrics() -> Response:
    return Response(content=generate_latest(), media_type=CONTENT_TYPE_LATEST)
