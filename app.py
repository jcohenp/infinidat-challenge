from flask import Flask, render_template
import logging

app = Flask(__name__)

# Route on the hello page
@app.route('/')
@app.route('/hello')
def hello():
    logging.info('Hello endpoint accessed.')
    return render_template('hello.html')

# Route for the about page
@app.route('/about')
def about():
    logging.info('About endpoint accessed.')
    return render_template('about.html')

# Managing on page not found
@app.errorhandler(404)
def page_not_found(e):
    # Log the error
    logging.error(f"Page not found: {e}")
    return render_template('error.html'), 404

# Logging Setup
logging.basicConfig(level=logging.DEBUG)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
