import pytest
import sys
import os

# Add parent folder to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

# Import flask app object directly
from app import app as flask_app


@pytest.fixture
def client():
    flask_app.config['TESTING'] = True
    with flask_app.test_client() as client:
        yield client


def test_home_endpoint(client):
    response = client.get('/')
    assert response.status_code == 200
    data = response.get_json()
    assert data['app'] == 'azure-cicd-zerotrust-aks'
    assert data['status'] == 'running'


def test_health_endpoint(client):
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'healthy'


def test_secret_endpoint_no_keyvault(client):
    response = client.get('/secret')
    assert response.status_code == 500
    data = response.get_json()
    assert 'error' in data