from flask import Flask, redirect, url_for, request, render_template # 1. Import render_template

app = Flask(__name__)

@app.route('/success/<name>')
def success(name):
    return 'welcome %s' % name

# 2. Add a route for the home page that shows the form
@app.route('/')
def index():
    return render_template('screen1.html')

@app.route('/login', methods=['POST', 'GET'])

def login1():
    if request.method == 'POST':
        # This runs when you click "Submit" on the form
        user = request.form['nm']
        return redirect(url_for('success', name=user))
    else:
        # This runs if you go to /login directly (optional, usually / redirects here)
        user = request.args.get('nm')
        return redirect(url_for('success', name=user))

if __name__ == '__main__':
    app.run(debug=True)