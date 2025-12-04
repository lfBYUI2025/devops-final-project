from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

# In-memory storage for messages (we'll add a DB later)
messages = []

@app.route('/')
def index():
    return render_template('index.html', messages=messages)

@app.route('/post', methods=['POST'])
def post_message():
    message = request.form.get('message')
    if message:
        messages.append(message)
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
