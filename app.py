import os
from flask import Flask, render_template, jsonify
import json

app = Flask(__name__, template_folder='templates')
app.debug = True


@app.route('/health', methods=['GET'])
def get_data_from_db():
    """
     This method will return healthcheck information
    """
    return json.dumps({'success':True}), 200, {'ContentType':'application/json'}


@app.route('/myinfo', methods=['GET'])
def myinfo():
    """
     This method serves /myinfo endpoint and give index.html in response.
    """
    return render_template('feature.html')


@app.route('/', methods=['GET'])
def index():
    """
     This method serves / endpoint and give index.html in response.
    """
    return render_template('index.html')


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
