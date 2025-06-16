from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
from config import Config
from utils.database import get_db_connection
from utils.auth import hash_password, verify_password, generate_token, verify_token
from utils.ml_utils import predict_audio
import os
import uuid
import logging
import datetime
from secrets import randbelow
from utils.email_utils import send_verification_code
import pytz
import threading

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', handlers=[logging.StreamHandler()])
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.config.from_object(Config)

def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in Config.ALLOWED_EXTENSIONS

@app.route("/")
def index():
    logger.info("Index route accessed")
    return jsonify({"message": "Welcome to Fake Audio Detection API"}), 200

@app.route("/signup", methods=["POST"])
def signup():
    data = request.json
    username = data.get("username")
    email = data.get("email")
    password = data.get("password")
    logger.info(f"Signup request: username={username}, email={email}")

    if not all([username, email, password]):
        logger.error("Missing fields detected")
        return jsonify({"error": "Missing fields"}), 400

    conn = get_db_connection()
    if not conn:
        logger.error("Database connection failed")
        return jsonify({"error": "Database connection failed"}), 500

    cursor = None
    try:
        cursor = conn.cursor()
        logger.info("Checking for existing user")
        cursor.execute("SELECT 1 FROM Users WHERE username = ? OR email = ?", (username, email))
        if cursor.fetchone():
            logger.error("Username or email already exists")
            return jsonify({"error": "Username or email already exists"}), 400

        password_hash = hash_password(password)
        logger.info(f"Inserting user with hash: {password_hash}")
        cursor.execute(
            "INSERT INTO Users (username, email, password_hash) VALUES (?, ?, ?)",
            (username, email, password_hash)
        )
        conn.commit()
        logger.info("User inserted successfully")

        cursor.execute("SELECT @@IDENTITY AS id")
        user_id = int(cursor.fetchone()[0])
        logger.info(f"Fetched user_id: {user_id}")

        token = generate_token(user_id)
        logger.info(f"Generated token: {token}")
        return jsonify({"token": token}), 201
    except Exception as e:
        logger.error(f"Signup error: {e}")
        return jsonify({"error": f"Signup failed: {str(e)}"}), 500
    finally:
        if cursor:
            cursor.close()
        conn.close()

@app.route("/login", methods=["POST"])
def login():
    data = request.json
    email = data.get("email")
    password = data.get("password")
    logger.info(f"Login request: email={email}")

    conn = get_db_connection()
    if not conn:
        logger.error("Database connection failed")
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute(
            "SELECT user_id, password_hash, username FROM Users WHERE email = ?",
            (email,)
        )
        user = cursor.fetchone()
        if not user or not verify_password(user[1], password):
            logger.error("Invalid credentials")
            return jsonify({"error": "Invalid credentials"}), 401

        token = generate_token(user[0])
        logger.info(f"Generated token for user_id: {user[0]}")
        return jsonify({"token": token, "username": user[2]}), 200
    except Exception as e:
        logger.error(f"Login error: {e}")
        return jsonify({"error": "Login failed"}), 500
    finally:
        conn.close()

@app.route("/upload_audio", methods=["POST"])
def upload_audio():
    logger.info("Received upload_audio request")
    token = request.headers.get("Authorization")
    if not token:
        logger.error("Authorization token missing")
        return jsonify({"error": "Authorization token required"}), 401

    user_id = verify_token(token.replace("Bearer ", ""))
    if not user_id:
        logger.error("Invalid or expired token")
        return jsonify({"error": "Invalid or expired token"}), 401

    if "audio" not in request.files:
        logger.error("No audio file provided")
        return jsonify({"error": "No audio file provided"}), 400

    file = request.files["audio"]
    if not file or not allowed_file(file.filename):
        logger.error(f"Invalid file type: {file.filename}")
        return jsonify({"error": "Invalid file type. Only WAV and MP3 allowed."}), 400

    filename = secure_filename(f"{uuid.uuid4()}_{file.filename}")
    file_path = os.path.join(app.config["UPLOAD_FOLDER"], filename)
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    logger.info(f"Saving file to: {file_path}")
    try:
        file.save(file_path)
    except Exception as e:
        logger.error(f"Failed to save file: {e}")
        return jsonify({"error": "Failed to save file"}), 500

    conn = get_db_connection()
    if not conn:
        logger.error("Database connection failed")
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO AudioRecords (user_id, audio_name, file_path) VALUES (?, ?, ?)",
            (user_id, file.filename, file_path)
        )
        conn.commit()
        audio_id = cursor.execute("SELECT @@IDENTITY").fetchone()[0]
        logger.info(f"Audio record saved, audio_id: {audio_id}")

        logger.info(f"Calling predict_audio for: {file_path}")
        prediction, confidence = predict_audio(file_path)
        if prediction is None:
            logger.error("Predict_audio returned None")
            return jsonify({"error": "Audio processing failed"}), 500

        logger.info(f"Prediction: {prediction}, Confidence: {confidence}")
        cursor.execute(
            "INSERT INTO DetectionResults (audio_id, is_fake, confidence) VALUES (?, ?, ?)",
            (audio_id, bool(prediction == 0), confidence)
        )
        conn.commit()
        logger.info("Detection result saved")

        upload_date = cursor.execute(
            "SELECT upload_date FROM AudioRecords WHERE audio_id = ?", (audio_id,)
        ).fetchone()[0].strftime("%Y-%m-%d %H:%M:%S")
        response = {
            "audio_name": file.filename,
            "is_fake": bool(prediction == 0),
            "confidence": float(confidence),
            "upload_date": upload_date
        }
        logger.info(f"Response: {response}")
        return jsonify(response), 200
    except Exception as e:
        logger.error(f"Upload error: {e}")
        return jsonify({"error": "Processing failed"}), 500
    finally:
        conn.close()

@app.route("/history", methods=["GET"])
def history():
    logger.info("Received history request")
    token = request.headers.get("Authorization")
    if not token:
        logger.error("Authorization token missing")
        return jsonify({"error": "Authorization token required"}), 401

    user_id = verify_token(token.replace("Bearer ", ""))
    if not user_id:
        logger.error("Invalid or expired token")
        return jsonify({"error": "Invalid or expired token"}), 401

    conn = get_db_connection()
    if not conn:
        logger.error("Database connection failed")
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute(
            """
            SELECT ar.audio_id, ar.audio_name, ar.upload_date, dr.is_fake, dr.confidence
            FROM AudioRecords ar
            LEFT JOIN DetectionResults dr ON ar.audio_id = dr.audio_id
            WHERE ar.user_id = ?
            ORDER BY ar.upload_date DESC
            """,
            (user_id,)
        )
        history = [
            {
                "audio_id": int(row[0]),
                "audio_name": row[1],
                "upload_date": row[2].strftime("%Y-%m-%d %H:%M:%S"),
                "is_fake": bool(row[3]) if row[3] is not None else None,
                "confidence": float(row[4]) if row[4] is not None else None
            }
            for row in cursor.fetchall()
        ]
        logger.info(f"History fetched: {len(history)} records")
        return jsonify(history), 200
    except Exception as e:
        logger.error(f"History error: {e}")
        return jsonify({"error": "Failed to fetch history"}), 500
    finally:
        conn.close()

@app.route("/feedback", methods=["POST"])
def feedback():
    logger.info("Received feedback request")
    token = request.headers.get("Authorization")
    if not token:
        logger.error("Authorization token missing")
        return jsonify({"error": "Authorization token required"}), 401

    user_id = verify_token(token.replace("Bearer ", ""))
    if not user_id:
        logger.error("Invalid or expired token")
        return jsonify({"error": "Invalid or expired token"}), 401

    data = request.json
    feedback_type = data.get("feedback_type")
    feedback_text = data.get("feedback_text")

    if not all([feedback_type, feedback_text]):
        logger.error("Missing feedback fields")
        return jsonify({"error": "Missing feedback fields"}), 400

    conn = get_db_connection()
    if not conn:
        logger.error("Database connection failed")
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO Feedback (user_id, feedback_type, feedback_text) VALUES (?, ?, ?)",
            (user_id, feedback_type, feedback_text)
        )
        conn.commit()
        logger.info("Feedback submitted")
        return jsonify({"message": "Feedback submitted successfully"}), 201
    except Exception as e:
        logger.error(f"Feedback error: {e}")
        return jsonify({"error": "Feedback submission failed"}), 500
    finally:
        conn.close()

def cleanup_expired_codes(conn, user_id=None):
    try:
        cursor = conn.cursor()
        now = datetime.datetime.now(pytz.UTC)
        if user_id:
            cursor.execute(
                "DELETE FROM PasswordResetCodes WHERE user_id = ? AND expires_at < ?",
                (user_id, now)
            )
            logger.info(f"Deleted {cursor.rowcount} expired codes for user_id: {user_id}")
        cursor.execute(
            "DELETE FROM PasswordResetCodes WHERE expires_at < ?",
            (now,)
        )
        logger.info(f"Deleted {cursor.rowcount} globally expired verification codes")
        conn.commit()
    except Exception as e:
        logger.error(f"Failed to clean up expired codes: {e}")
    finally:
        cursor.close()

def scheduled_cleanup_specific(code_id):
    logger.info(f"Running scheduled cleanup for code_id: {code_id}")
    conn = get_db_connection()
    if not conn:
        logger.error("Database connection failed during scheduled cleanup")
        return
    try:
        cursor = conn.cursor()
        now = datetime.datetime.now(pytz.UTC)
        cursor.execute(
            "DELETE FROM PasswordResetCodes WHERE id = ? AND expires_at < ?",
            (code_id, now)
        )
        logger.info(f"Deleted {cursor.rowcount} expired code_id: {code_id}")
        conn.commit()
    except Exception as e:
        logger.error(f"Scheduled cleanup error for code_id {code_id}: {e}")
    finally:
        cursor.close()
        conn.close()

@app.route("/forgot_password", methods=["POST"])
def forgot_password():
    logger.info("Received forgot_password request")
    data = request.json
    email = data.get("email")
    if not email:
        logger.error("Missing email field")
        return jsonify({"error": "Email required"}), 400

    conn = get_db_connection()
    if not conn:
        logger.error("Database connection failed")
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("SELECT user_id FROM Users WHERE email = ?", (email,))
        user = cursor.fetchone()
        if user:
            user_id = user[0]
            cleanup_expired_codes(conn, user_id=user_id)

            code = str(randbelow(1000000)).zfill(6)
            now = datetime.datetime.now(pytz.UTC)
            expires_at = now + datetime.timedelta(seconds=Config.VERIFICATION_CODE_EXPIRY)

            cursor.execute(
                """
                INSERT INTO PasswordПосмотреть остальные таблицыResetCodes (user_id, code, created_at, expires_at)
                VALUES (?, ?, ?, ?)
                """,
                (user_id, code, now, expires_at)
            )
            conn.commit()
            cursor.execute("SELECT @@IDENTITY AS id")
            code_id = int(cursor.fetchone()[0])
            logger.info(f"Verification code generated for user_id: {user_id}, code_id: {code_id}")

            cleanup_delay = Config.VERIFICATION_CODE_EXPIRY + 10
            threading.Timer(cleanup_delay, scheduled_cleanup_specific, args=[code_id]).start()
            logger.info(f"Scheduled cleanup for code_id: {code_id} in {cleanup_delay} seconds")

            if not send_verification_code(email, code):
                logger.error(f"Failed to send verification code to {email}")
                return jsonify({"error": "Failed to send verification code"}), 500

        return jsonify({"message": "Verification code sent to your email"}), 200
    except Exception as e:
        logger.error(f"Forgot password error: {e}")
        return jsonify({"error": "Failed to process request"}), 500
    finally:
        conn.close()

@app.route("/verify_code", methods=["POST"])
def verify_code():
    logger.info("Received verify_code request")
    data = request.json
    email = data.get("email")
    code = data.get("code")
    if not all([email, code]):
        logger.error("Missing email or code")
        return jsonify({"error": "Email and code required"}), 400

    conn = get_db_connection()
    if not conn:
        logger.error("Database connection failed")
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cleanup_expired_codes(conn)

        cursor = conn.cursor()
        now = datetime.datetime.now(pytz.UTC)
        cursor.execute(
            """
            SELECT prc.id, prc.user_id
            FROM PasswordResetCodes prc
            JOIN Users u ON prc.user_id = u.user_id
            WHERE u.email = ? AND prc.code = ? AND prc.expires_at > ?
            """,
            (email, code, now)
        )
        result = cursor.fetchone()
        if not result:
            logger.error(f"Invalid or expired code for email: {email}")
            return jsonify({"error": "Invalid or expired code"}), 400

        cursor.execute("DELETE FROM PasswordResetCodes WHERE id = ?", (result[0],))
        conn.commit()
        logger.info(f"Code verified for user_id: {result[1]}")

        reset_token = generate_token(result[1])
        return jsonify({"reset_token": reset_token}), 200
    except Exception as e:
        logger.error(f"Verify code error: {e}")
        return jsonify({"error": "Failed to verify code"}), 500
    finally:
        conn.close()

@app.route("/reset_password", methods=["POST"])
def reset_password():
    logger.info("Received reset_password request")
    data = request.json
    reset_token = data.get("reset_token")
    new_password = data.get("new_password")
    if not all([reset_token, new_password]):
        logger.error("Missing reset token or new password")
        return jsonify({"error": "Reset token and new password required"}), 400

    user_id = verify_token(reset_token)
    if not user_id:
        logger.error("Invalid or expired reset token")
        return jsonify({"error": "Invalid or expired reset token"}), 401

    conn = get_db_connection()
    if not conn:
        logger.error("Database connection failed")
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        password_hash = hash_password(new_password)
        cursor.execute(
            "UPDATE Users SET password_hash = ? WHERE user_id = ?",
            (password_hash, user_id)
        )
        if cursor.rowcount == 0:
            logger.error(f"No user found with user_id: {user_id}")
            return jsonify({"error": "User not found"}), 404

        conn.commit()
        logger.info(f"Password updated for user_id: {user_id}")
        return jsonify({"message": "Password updated successfully"}), 200
    except Exception as e:
        logger.error(f"Reset password error: {e}")
        return jsonify({"error": "Failed to update password"}), 500
    finally:
        conn.close()

@app.route("/update_user", methods=["POST"])
def update_user():
    logger.info("Received update_user request")
    token = request.headers.get("Authorization")
    if not token:
        logger.error("Authorization token missing")
        return jsonify({"error": "Authorization token required"}), 401

    user_id = verify_token(token.replace("Bearer ", ""))
    if not user_id:
        logger.error("Invalid or expired token")
        return jsonify({"error": "Invalid or expired token"}), 401

    data = request.json
    username = data.get("username")
    email = data.get("email")
    password = data.get("password")

    if not any([username, email, password]):
        logger.error("No fields provided for update")
        return jsonify({"error": "At least one field (username, email, password) required"}), 400

    conn = get_db_connection()
    if not conn:
        logger.error("Database connection failed")
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()

        if username or email:
            check_params = []
            check_query_parts = []
            if username:
                check_query_parts.append("username = ?")
                check_params.append(username)
            if email:
                check_query_parts.append("email = ?")
                check_params.append(email)
            check_query = f"SELECT 1 FROM Users WHERE ({' OR '.join(check_query_parts)}) AND user_id != ?"
            check_params.append(user_id)
            cursor.execute(check_query, check_params)
            if cursor.fetchone():
                logger.error("Username or email already exists")
                return jsonify({"error": "Username or email already exists"}), 400

        update_params = []
        update_query_parts = []
        if username:
            update_query_parts.append("username = ?")
            update_params.append(username)
        if email:
            update_query_parts.append("email = ?")
            update_params.append(email)
        if password:
            update_query_parts.append("password_hash = ?")
            update_params.append(hash_password(password))

        if update_query_parts:
            update_query = f"UPDATE Users SET {', '.join(update_query_parts)} WHERE user_id = ?"
            update_params.append(user_id)
            cursor.execute(update_query, update_params)
            if cursor.rowcount == 0:
                logger.error(f"No user found with user_id: {user_id}")
                return jsonify({"error": "User not found"}), 404
            conn.commit()
            logger.info(f"User updated: user_id={user_id}, updated_fields={update_query_parts}")

        token = generate_token(user_id)
        logger.info(f"Generated new token for user_id: {user_id}")
        return jsonify({"message": "User updated successfully", "token": token}), 200
    except Exception as e:
        logger.error(f"Update user error: {e}")
        return jsonify({"error": "Failed to update user"}), 500
    finally:
        conn.close()

@app.route("/delete_history/<int:audio_id>", methods=["DELETE"])
def delete_history(audio_id):
    logger.info(f"Received delete_history request for audio_id: {audio_id}")
    token = request.headers.get("Authorization")
    if not token:
        logger.error("Authorization token missing")
        return jsonify({"error": "Authorization token required"}), 401

    user_id = verify_token(token.replace("Bearer ", ""))
    if not user_id:
        logger.error("Invalid or expired token")
        return jsonify({"error": "Invalid or expired token"}), 401

    conn = get_db_connection()
    if not conn:
        logger.error("Database connection failed")
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute(
            "SELECT file_path FROM AudioRecords WHERE audio_id = ? AND user_id = ?",
            (audio_id, user_id)
        )
        record = cursor.fetchone()
        if not record:
            logger.error(f"Audio record not found or not owned by user_id: {user_id}, audio_id: {audio_id}")
            return jsonify({"error": "Audio record not found or unauthorized"}), 404

        cursor.execute("DELETE FROM DetectionResults WHERE audio_id = ?", (audio_id,))
        logger.info(f"Deleted {cursor.rowcount} detection results for audio_id: {audio_id}")

        cursor.execute("DELETE FROM AudioRecords WHERE audio_id = ?", (audio_id,))
        if cursor.rowcount == 0:
            logger.error(f"Failed to delete audio record: audio_id={audio_id}")
            return jsonify({"error": "Failed to delete audio record"}), 500
        logger.info(f"Deleted audio record: audio_id={audio_id}")

        file_path = record[0]
        if os.path.exists(file_path):
            try:
                os.remove(file_path)
                logger.info(f"Deleted file: {file_path}")
            except Exception as e:
                logger.warning(f"Failed to delete file {file_path}: {e}")
        else:
            logger.warning(f"File not found: {file_path}")

        conn.commit()
        return jsonify({"message": "Audio record deleted successfully"}), 200
    except Exception as e:
        logger.error(f"Delete history error: {e}")
        return jsonify({"error": "Failed to delete audio record"}), 500
    finally:
        conn.close()

if __name__ == "__main__":
    os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)
    try:
        app.run(debug=True, host="0.0.0.0", port=5000)
    except Exception as e:
        logger.error(f"Failed to start server: {e}")
        raise