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
    return {"status": "course-service OK"}

@app.get("/courses")
def list_courses():
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM courses")
    return jsonify(cursor.fetchall())

@app.post("/course")
def create_course():
    data = request.json
    cursor = db.cursor()
    cursor.execute("INSERT INTO courses (title, description) VALUES (%s, %s)",
                   (data["title"], data["description"]))
    db.commit()
    return {"message": "Course created"}

app.run(host="0.0.0.0", port=5001)
