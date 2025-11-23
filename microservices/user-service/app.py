from flask import Flask, request, jsonify
import mysql.connector
import os

app = Flask(__name__)

db = mysql.connector.connect(
    host=os.getenv("DB_HOST"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    database=os.getenv("DB_NAME")
)

@app.get("/health")
def health():
    return {"status": "user-service OK"}

@app.post("/register")
def register():
    data = request.json
    cursor = db.cursor()
    cursor.execute("INSERT INTO users (name,email,password) VALUES (%s,%s,%s)",
                   (data["name"], data["email"], data["password"]))
    db.commit()
    return {"message": "User registered"}

@app.post("/login")
def login():
    data = request.json
    cursor = db.cursor()
    cursor.execute("SELECT id FROM users WHERE email=%s AND password=%s",
                   (data["email"], data["password"]))
    user = cursor.fetchone()
    return {"valid": bool(user)}

app.run(host="0.0.0.0", port=5000)
