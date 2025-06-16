import os

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", os.urandom(32).hex())  # Fallback to random key
    SQL_SERVER = os.getenv("SQL_SERVER", "fakeaudiodb-server.database.windows.net")
    DATABASE = os.getenv("DATABASE", "FakeAudioDB")
    SQL_UID = os.getenv("SQL_UID", "fakeaudioadmin")
    SQL_PWD = os.getenv("SQL_PWD", "FakeAudio123!")  
    SQLALCHEMY_DATABASE_URI = (
        f"mssql+pyodbc://{SQL_UID}:{SQL_PWD}@{SQL_SERVER}/{DATABASE}"
        "?driver=ODBC+Driver+17+for+SQL+Server"
    )
    UPLOAD_FOLDER = os.getenv("UPLOAD_FOLDER", os.path.join(os.path.sep, "tmp", "Uploads"))
    ALLOWED_EXTENSIONS = {"wav", "mp3"}
    SMTP_SERVER = os.getenv("SMTP_SERVER", "smtp.gmail.com")
    SMTP_PORT = int(os.getenv("SMTP_PORT", 587))
    SMTP_EMAIL = os.getenv("SMTP_EMAIL", "walaaelnokrashy912@gmail.com")  
    SMTP_PASSWORD = os.getenv("SMTP_PASSWORD", "qxtxqrxlkauercme")  
    VERIFICATION_CODE_EXPIRY = int(os.getenv("VERIFICATION_CODE_EXPIRY", 600))