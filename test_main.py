from main import app
import pytest

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_index(client):
    rv = client.get('/')
    assert rv.status_code == 200
    assert b'Bulletin Board' in rv.data  # Check for title in HTML

def test_post_message(client):
    rv = client.post('/post', data={'message': 'Test message'})
    assert rv.status_code == 302  # Redirect after post
    rv = client.get('/')
    assert b'Test message' in rv.data  # Check if message appears
