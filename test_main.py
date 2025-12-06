from main import app, init_db, DB_FILE
import pytest
import os

@pytest.fixture
def client():
    if os.path.exists(DB_FILE):
        os.remove(DB_FILE)
    init_db()
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client
    if os.path.exists(DB_FILE):
        os.remove(DB_FILE)

def test_index(client):
    rv = client.get('/')
    assert rv.status_code == 200
    assert b'Bulletin Board' in rv.data

def test_post_message(client):
    rv = client.post('/post', data={'message': 'Test message'})
    assert rv.status_code == 302
    rv = client.get('/')
    assert b'Test message' in rv.data
