import os
from pymongo import MongoClient
from pymongo.errors import ServerSelectionTimeoutError
import logging
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger(__name__)

# MongoDB Configuration
MONGO_URI = os.getenv("MONGO_URI", "mongodb+srv://username:password@cluster.mongodb.net/codehax?retryWrites=true&w=majority")
DB_NAME = "codehax"
TIMEOUT = 5000


class Database:
    """MongoDB Database Manager"""
    
    _instance = None
    _client = None
    _db = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(Database, cls).__new__(cls)
        return cls._instance
    
    def __init__(self):
        """Initialize MongoDB connection"""
        if self._client is None:
            try:
                self._client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=TIMEOUT)
                # Test connection
                self._client.admin.command('ping')
                self._db = self._client[DB_NAME]
                logger.info("✓ MongoDB connected successfully")
                self._create_indexes()
            except ServerSelectionTimeoutError:
                logger.error("✗ Failed to connect to MongoDB")
                raise Exception("MongoDB connection failed. Check MONGO_URI in .env")
            except Exception as e:
                logger.error(f"✗ MongoDB error: {e}")
                raise
    
    def _create_indexes(self):
        """Create indexes for better query performance"""
        try:
            # Users collection indexes
            self._db.users.create_index("email", unique=True)
            self._db.users.create_index("username", unique=True)
            
            # Chat history indexes
            self._db.chat_history.create_index("user_id")
            self._db.chat_history.create_index("timestamp")
            self._db.chat_history.create_index([("user_id", 1), ("timestamp", -1)])
            
            logger.info("✓ Database indexes created")
        except Exception as e:
            logger.warning(f"Index creation warning: {e}")
    
    def get_db(self):
        """Get database instance"""
        if self._db is None:
            self.__init__()
        return self._db
    
    def get_users_collection(self):
        """Get users collection"""
        return self.get_db().users
    
    def get_chat_history_collection(self):
        """Get chat history collection"""
        return self.get_db().chat_history
    
    def close(self):
        """Close database connection"""
        if self._client:
            self._client.close()
            logger.info("✓ MongoDB connection closed")

# Singleton instance
db = Database()

def get_db():
    """Get database instance"""
    return db.get_db()

def get_users_collection():
    """Get users collection"""
    return db.get_users_collection()

def get_chat_history_collection():
    """Get chat history collection"""
    return db.get_chat_history_collection()
