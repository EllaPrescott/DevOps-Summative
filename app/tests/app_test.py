import pytest
from app.app import app
@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_dashboard_get_content(client):
    response = client.get("/")
    assert response.status_code == 200
    assert b"Monthly Spend" in response.data
    assert b"Monthly Transactions" in response.data
    assert b"Fraud Rate" in response.data
    assert b"Declines" in response.data

def test_dashboard_post_valid_amount(client): 
    response = client.post("/", data={"amount": "100"})
    assert response.status_code == 200
    assert b"1350" in response.data  # Updated monthly spend
    assert b"43" in response.data    # Updated monthly transactions

def test_dashboard_post_invalid_amount(client):
    response = client.post("/", data={"amount": "invalid"})
    assert response.status_code == 200
    assert b"1250" in response.data  # Monthly spend should remain unchanged
    assert b"42" in response.data     # Monthly transactions should remain unchanged