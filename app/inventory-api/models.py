from pydantic import BaseModel, Field
from sqlalchemy import Column, Float, Integer, String

from database import Base


class InventoryItem(Base):
    __tablename__ = "inventory_items"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False, index=True)
    quantity = Column(Integer, nullable=False, default=0)
    price = Column(Float, nullable=False, default=0.0)


class ItemCreate(BaseModel):
    name: str = Field(..., example="laptop")
    quantity: int = Field(..., ge=0, example=10)
    price: float = Field(..., ge=0, example=999.99)


class ItemResponse(BaseModel):
    id: int
    name: str
    quantity: int
    price: float

    class Config:
        from_attributes = True
