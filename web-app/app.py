from flask import Flask, render_template, request, jsonify
import requests
import json
import os

app = Flask(__name__)

ORCHESTRATOR_URL = os.getenv('ORCHESTRATOR_URL', 'http://orchestrator-svc:8080')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/debate', methods=['POST'])
def debate():
    data = request.json
    task = data.get('task', '')
    max_rounds = data.get('max_rounds', 2)
    
    try:
        response = requests.post(
            f"{ORCHESTRATOR_URL}/debate",
            json={"task": task, "max_rounds": max_rounds},
            timeout=300
        )
        return jsonify(response.json())
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/health', methods=['GET'])
def health():
    try:
        response = requests.get(f"{ORCHESTRATOR_URL}/health")
        return jsonify(response.json())
    except:
        return jsonify({"status": "unhealthy"}), 503

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
