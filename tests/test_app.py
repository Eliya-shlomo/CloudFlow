import pytest
from flask import Flask
from app import app 

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health(client):
    response = client.get('/')
    assert response.status_code == 200
    assert b"Hello" in response.data 