from flask import Flask, render_template, request, redirect, url_for
import sqlite3
import os

app = Flask(__name__)

# Database setup
DB_FILE = 'messages.db'

def init_db():
    if not os.path.exists(DB_FILE):
        conn = sqlite3.connect(DB_FILE)
        c = conn.cursor()
        c.execute('''CREATE TABLE messages (id INTEGER PRIMARY KEY, message TEXT)''')
        conn.commit()
        conn.close()

init_db()

def get_messages():
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute('SELECT message FROM messages')
    return [row[0] for row in c.fetchall()]

def add_message(message):
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute('INSERT INTO messages (message) VALUES (?)', (message,))
    conn.commit()
    conn.close()

@app.route('/')
def index():
    messages = get_messages()
    return render_template('index.html', messages=messages)

@app.route('/post', methods=['POST'])
def post_message():
    message = request.form.get('message')
    if message:
        add_message(message)
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
