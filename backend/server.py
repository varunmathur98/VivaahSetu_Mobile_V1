from fastapi import FastAPI, APIRouter, HTTPException, Depends, Request, Response, UploadFile, File
from fastapi.responses import JSONResponse
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
import certifi
import os
import logging
import json
import base64
import hmac
import hashlib
import httpx
from pathlib import Path
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import uuid
import bcrypt
from datetime import datetime, timezone, timedelta
from jose import JWTError, jwt
from bson import ObjectId

ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

def env_flag(name: str, default: bool = False) -> bool:
    value = os.environ.get(name)
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "on"}

# MongoDB connection
mongo_url = os.environ['MONGO_URL']
client = AsyncIOMotorClient(
    mongo_url,
    tls=True,
    tlsCAFile=certifi.where(),
    tlsAllowInvalidCertificates=env_flag("MONGO_TLS_ALLOW_INVALID_CERTS", True),
)
db = client[os.environ.get('DB_NAME', 'vivahsetu')]

# Security
SECRET_KEY = os.environ.get("JWT_SECRET", "replace-this-jwt-secret-in-env")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_DAYS = 7
security = HTTPBearer()

# Google OAuth
GOOGLE_CLIENT_ID = os.environ.get("GOOGLE_CLIENT_ID", "")

# Cashfree Payment
CASHFREE_APP_ID = os.environ.get("CASHFREE_APP_ID", "")
CASHFREE_SECRET_KEY = os.environ.get("CASHFREE_SECRET_KEY", "")
CASHFREE_ENV = os.environ.get("CASHFREE_ENVIRONMENT", "PRODUCTION")
CASHFREE_BASE_URL = "https://api.cashfree.com/pg" if CASHFREE_ENV == "PRODUCTION" else "https://sandbox.cashfree.com/pg"
CASHFREE_API_VERSION = "2023-08-01"

# Connection settings
MAX_CONNECTIONS = 5
CONNECTION_DURATION_DAYS = 15
MAX_CONNECTION_DURATION_DAYS = 30
MAX_PHOTOS = 5
DISCOUNT_PERCENT = 70
CONNECTION_REMINDER_DAYS = {5, 3, 1, 0}

CASTES_BY_RELIGION = {
    "Hindu": [
        "Brahmin", "Kshatriya", "Vaishya", "Kayastha", "Bhumihar", "Rajput", "Jat",
        "Yadav", "Agarwal", "Gupta", "Patel", "Reddy", "Kamma", "Kapu", "Maratha",
        "Nair", "Ezhava", "Chettiar", "Mudaliar", "Vanniyar", "Other",
    ],
    "Muslim": ["Sunni", "Shia", "Syed", "Pathan", "Sheikh", "Mughal", "Bohra", "Other"],
    "Christian": ["Catholic", "Protestant", "Orthodox", "Pentecostal", "CSI", "CNI", "Other"],
    "Sikh": ["Jat Sikh", "Khatri", "Arora", "Ramgarhia", "Saini", "Other"],
    "Jain": ["Digambar", "Shwetambar", "Oswal", "Porwal", "Other"],
    "Buddhist": ["Mahayana", "Theravada", "Navayana", "Other"],
}

SUBCASTES_BY_CASTE = {
    "Brahmin": ["Iyer", "Iyengar", "Saraswat", "Gaur", "Kanyakubja", "Deshastha", "Smartha", "Maithil", "Other"],
    "Kshatriya": ["Rajput", "Thakur", "Nair", "Reddy", "Maratha", "Other"],
    "Vaishya": ["Agarwal", "Gupta", "Maheshwari", "Oswal", "Bania", "Other"],
    "Kayastha": ["Srivastava", "Saxena", "Mathur", "Nigam", "Asthana", "Other"],
    "Bhumihar": ["Babhhan", "Other"],
    "Rajput": ["Chauhan", "Rathore", "Sisodiya", "Parmar", "Solanki", "Tomar", "Other"],
    "Jat": ["Dahiya", "Malik", "Hooda", "Sehrawat", "Ahlawat", "Jakhar", "Other"],
    "Yadav": ["Ahir", "Gwala", "Krishnaut", "Nandvanshi", "Other"],
    "Agarwal": ["Bisa", "Dassa", "Goyal", "Mittal", "Jindal", "Other"],
    "Gupta": ["Bania", "Agarwal", "Mahajan", "Khandelwal", "Other"],
    "Patel": ["Leuva", "Kadva", "Anjana", "Patidar", "Other"],
    "Reddy": ["Panta Reddy", "Motati", "Kapu Reddy", "Other"],
    "Kamma": ["Chowdary", "Naidu", "Other"],
    "Kapu": ["Balija", "Telaga", "Ontari", "Munnuru", "Other"],
    "Maratha": ["96 Kuli", "Kunbi", "CKP", "Deshastha", "Other"],
    "Nair": ["Menon", "Pillai", "Kurup", "Panicker", "Other"],
    "Ezhava": ["Thiyya", "Other"],
    "Chettiar": ["Nagarathar", "Vaniar", "Other"],
    "Mudaliar": ["Thuluva Vellala", "Agamudayar", "Sengunthar", "Other"],
    "Vanniyar": ["Padayachi", "Gounder", "Other"],
    "Sunni": ["Hanafi", "Shafi", "Maliki", "Hanbali", "Other"],
    "Shia": ["Ithna Ashari", "Ismaili", "Bohra", "Other"],
    "Syed": ["Hasani", "Hussaini", "Other"],
    "Pathan": ["Yousafzai", "Afridi", "Other"],
    "Sheikh": ["Qureshi", "Ansari", "Siddiqui", "Other"],
    "Mughal": ["Mirza", "Baig", "Other"],
    "Bohra": ["Dawoodi Bohra", "Sulaymani", "Other"],
    "Catholic": ["Roman Catholic", "Syro-Malabar", "Syro-Malankara", "Other"],
    "Protestant": ["CSI", "CNI", "Pentecostal", "Other"],
    "Orthodox": ["Malankara", "Jacobite", "Other"],
    "Pentecostal": ["Assemblies of God", "Independent", "Other"],
    "CSI": ["South India", "Other"],
    "CNI": ["North India", "Other"],
    "Jat Sikh": ["Sandhu", "Gill", "Brar", "Sidhu", "Other"],
    "Khatri": ["Kapoor", "Khanna", "Malhotra", "Mehra", "Other"],
    "Arora": ["Sachdeva", "Taneja", "Ahuja", "Chopra", "Other"],
    "Ramgarhia": ["Mistry", "Lohar", "Tarkhan", "Other"],
    "Saini": ["Other"],
    "Digambar": ["Bisapanthi", "Terapanthi", "Taranpanthi", "Other"],
    "Shwetambar": ["Murtipujak", "Sthanakvasi", "Terapanthi", "Other"],
    "Oswal": ["Other"],
    "Porwal": ["Other"],
    "Mahayana": ["Navayana", "Other"],
    "Theravada": ["Other"],
    "Navayana": ["Other"],
}

def default_user_settings() -> Dict[str, Any]:
    return {
        "pushNotifications": True,
        "emailNotifications": True,
        "profileVisible": True,
        "showLastSeen": True,
        "typingIndicators": True,
    }

# Create the main app
app = FastAPI(title="VivahSetu API")
api_router = APIRouter(prefix="/api")

MAX_REQUEST_BYTES = int(os.environ.get("MAX_REQUEST_BYTES", str(12 * 1024 * 1024)))

@app.middleware("http")
async def security_headers_middleware(request: Request, call_next):
    content_length = request.headers.get("content-length")
    if content_length and int(content_length) > MAX_REQUEST_BYTES:
        return JSONResponse(status_code=413, content={"detail": "Request too large"})
    response = await call_next(request)
    response.headers.setdefault("X-Content-Type-Options", "nosniff")
    response.headers.setdefault("X-Frame-Options", "DENY")
    response.headers.setdefault("Referrer-Policy", "strict-origin-when-cross-origin")
    response.headers.setdefault("Permissions-Policy", "camera=(), microphone=(), geolocation=()")
    return response

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# ============ MODELS ============

class RegisterInput(BaseModel):
    email: str
    password: str
    name: str
    gender: str = "Male"

class LoginInput(BaseModel):
    email: str
    password: str

class GoogleLoginRequest(BaseModel):
    idToken: Optional[str] = None
    email: Optional[str] = ""
    name: Optional[str] = ""
    photoUrl: Optional[str] = None

class FirebaseSessionInput(BaseModel):
    id_token: str
    gender: Optional[str] = ""
    name: Optional[str] = ""

class ProfileUpdateInput(BaseModel):
    class Config:
        extra = "allow"

    name: Optional[str] = None
    age: Optional[int] = None
    dob: Optional[str] = None
    date_of_birth: Optional[str] = None
    birthTime: Optional[str] = None
    birth_time: Optional[str] = None
    birthPlace: Optional[str] = None
    birth_place: Optional[str] = None
    profileManagedBy: Optional[str] = None
    profile_managed_by: Optional[str] = None
    gender: Optional[str] = None
    height: Optional[str] = None
    religion: Optional[str] = None
    caste: Optional[str] = None
    sub_caste: Optional[str] = None
    subCaste: Optional[str] = None
    motherTongue: Optional[str] = None
    mother_tongue: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    location: Optional[str] = None
    education: Optional[str] = None
    occupation: Optional[str] = None
    profession: Optional[str] = None
    income: Optional[str] = None
    maritalStatus: Optional[str] = None
    marital_status: Optional[str] = None
    about: Optional[str] = None
    familyDetails: Optional[str] = None
    family_details: Optional[str] = None
    phone: Optional[str] = None
    photoVisibility: Optional[str] = None
    partnerPreferences: Optional[Dict] = None
    partner_preferences: Optional[Dict] = None

class PhotoUpload(BaseModel):
    photo: str

class SendMessageInput(BaseModel):
    receiverId: Optional[str] = None
    receiver_id: Optional[str] = None
    content: str

class ConnectionExtensionRequest(BaseModel):
    connection_id: Optional[str] = None
    connectionId: Optional[str] = None

class FeedbackInput(BaseModel):
    class Config:
        extra = "allow"

    category: str = "feedback"
    subject: Optional[str] = None
    message: str
    screen: Optional[str] = None

# ============ HELPERS ============

def hash_password(password: str) -> str:
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode("utf-8"), salt).decode("utf-8")

def verify_password(plain: str, hashed: str) -> bool:
    return bcrypt.checkpw(plain.encode("utf-8"), hashed.encode("utf-8"))

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(days=ACCESS_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        token = credentials.credentials
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        user = await find_user_by_ref(user_id)
        if user is None:
            raise HTTPException(status_code=401, detail="User not found")
        user["id"] = str(user["_id"])
        return user
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

def serialize_user(user: dict) -> dict:
    if not user:
        return {}
    u = {}
    for k, v in user.items():
        if k == "_id":
            u["id"] = str(v)
        elif k == "password_hash":
            continue
        elif isinstance(v, ObjectId):
            u[k] = str(v)
        elif isinstance(v, datetime):
            u[k] = v.isoformat()
        else:
            u[k] = v
    if "id" not in u and "_id" in user:
        u["id"] = str(user["_id"])
    # Provide snake_case and camelCase aliases to keep web/mobile clients compatible.
    city = (u.get("city") or "").strip()
    state = (u.get("state") or "").strip()
    if city or state:
        u.setdefault("location", ", ".join([part for part in [city, state] if part]))
    if u.get("location"):
        if not u.get("city") and "," in str(u["location"]):
            u["city"] = str(u["location"]).split(",", 1)[0].strip()
    if u.get("occupation"):
        u.setdefault("profession", u.get("occupation"))
    if u.get("profession"):
        u.setdefault("occupation", u.get("profession"))
    if u.get("maritalStatus"):
        u.setdefault("marital_status", u.get("maritalStatus"))
    if u.get("marital_status"):
        u.setdefault("maritalStatus", u.get("marital_status"))
    if u.get("subCaste"):
        u.setdefault("sub_caste", u.get("subCaste"))
    if u.get("sub_caste"):
        u.setdefault("subCaste", u.get("sub_caste"))
    if u.get("subcast"):
        u.setdefault("sub_caste", u.get("subcast"))
        u.setdefault("subCaste", u.get("subcast"))
    if u.get("motherTongue"):
        u.setdefault("mother_tongue", u.get("motherTongue"))
    if u.get("mother_tongue"):
        u.setdefault("motherTongue", u.get("mother_tongue"))
    if u.get("familyDetails"):
        u.setdefault("family_details", u.get("familyDetails"))
    if u.get("family_details"):
        u.setdefault("familyDetails", u.get("family_details"))
    if u.get("partnerPreferences"):
        u.setdefault("partner_preferences", u.get("partnerPreferences"))
    if u.get("partner_preferences"):
        u.setdefault("partnerPreferences", u.get("partner_preferences"))
    if u.get("dob"):
        u.setdefault("date_of_birth", u.get("dob"))
    if u.get("date_of_birth"):
        u.setdefault("dob", u.get("date_of_birth"))
    if u.get("birthTime"):
        u.setdefault("birth_time", u.get("birthTime"))
    if u.get("birth_time"):
        u.setdefault("birthTime", u.get("birth_time"))
    if u.get("birthPlace"):
        u.setdefault("birth_place", u.get("birthPlace"))
    if u.get("birth_place"):
        u.setdefault("birthPlace", u.get("birth_place"))
    if u.get("profileManagedBy"):
        u.setdefault("profile_managed_by", u.get("profileManagedBy"))
    if u.get("profile_managed_by"):
        u.setdefault("profileManagedBy", u.get("profile_managed_by"))
    photos = [str(item).strip() for item in u.get("photos", []) if str(item).strip()]
    preferred_photo = (
        str(u.get("photoUrl") or "").strip()
        or str(u.get("profile_photo") or "").strip()
        or str(u.get("profilePhoto") or "").strip()
    )
    if preferred_photo:
        photos = [preferred_photo, *[item for item in photos if item != preferred_photo]]
        u.setdefault("photoUrl", preferred_photo)
        u.setdefault("profile_photo", preferred_photo)
        u.setdefault("profilePhoto", preferred_photo)
    if photos:
        u["photos"] = photos
    settings = default_user_settings()
    settings.update(u.get("settings", {}) if isinstance(u.get("settings"), dict) else {})
    u["settings"] = settings
    u.setdefault("pushNotifications", settings["pushNotifications"])
    u.setdefault("emailNotifications", settings["emailNotifications"])
    u.setdefault("profileVisible", settings["profileVisible"])
    u.setdefault("showLastSeen", settings["showLastSeen"])
    u.setdefault("typingIndicators", settings["typingIndicators"])
    return u

def gender_regex(value: str) -> Dict[str, str]:
    return {"$regex": rf"^\s*{value}\s*$", "$options": "i"}

def normalize_ref(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, dict):
        raw = value.get("id") or value.get("_id") or ""
        return str(raw).strip()
    return str(value).strip()

def normalize_ref_list(values: Any) -> List[str]:
    items = values if isinstance(values, list) else []
    normalized: List[str] = []
    for item in items:
        ref = normalize_ref(item)
        if ref:
            normalized.append(ref)
    return normalized

def parse_utc_datetime(value: Any) -> datetime:
    if isinstance(value, datetime):
        return value if value.tzinfo else value.replace(tzinfo=timezone.utc)
    raw = str(value or "").strip()
    if not raw:
        return datetime.now(timezone.utc)
    if raw.endswith("Z"):
        raw = f"{raw[:-1]}+00:00"
    parsed = datetime.fromisoformat(raw)
    return parsed if parsed.tzinfo else parsed.replace(tzinfo=timezone.utc)

def capped_connection_expiry(value: Any, now: Optional[datetime] = None) -> datetime:
    current_now = now or datetime.now(timezone.utc)
    expiry = parse_utc_datetime(value)
    max_expiry = current_now + timedelta(days=MAX_CONNECTION_DURATION_DAYS)
    return min(expiry, max_expiry)

def connection_days_remaining(value: Any, now: Optional[datetime] = None) -> int:
    current_now = now or datetime.now(timezone.utc)
    expiry = capped_connection_expiry(value, current_now)
    seconds = int((expiry - current_now).total_seconds())
    if seconds <= 0:
        return 0
    return min(MAX_CONNECTION_DURATION_DAYS, (seconds + 86399) // 86400)

async def find_user_by_ref(value: Any, projection: Optional[Dict[str, int]] = None) -> Optional[dict]:
    ref = normalize_ref(value)
    if not ref:
        return None
    queries: List[Dict[str, Any]] = [{"id": ref}, {"_id": ref}]
    if ObjectId.is_valid(ref):
        queries.insert(0, {"_id": ObjectId(ref)})
    return await db.users.find_one({"$or": queries}, projection)

_fcm_access_token: Optional[str] = None
_fcm_access_token_expires_at: Optional[datetime] = None

def firebase_service_account() -> Optional[Dict[str, Any]]:
    raw = os.environ.get("FIREBASE_SERVICE_ACCOUNT_JSON", "").strip()
    if not raw:
        path = os.environ.get("FIREBASE_SERVICE_ACCOUNT_FILE", "").strip()
        if path and Path(path).exists():
            raw = Path(path).read_text(encoding="utf-8")
    if not raw:
        return None
    try:
        return json.loads(raw)
    except Exception:
        logger.warning("Invalid Firebase service account configuration")
        return None

async def firebase_access_token() -> Optional[str]:
    global _fcm_access_token, _fcm_access_token_expires_at
    if (
        _fcm_access_token
        and _fcm_access_token_expires_at
        and _fcm_access_token_expires_at > datetime.now(timezone.utc) + timedelta(minutes=5)
    ):
        return _fcm_access_token
    account = firebase_service_account()
    if not account:
        return None
    now = datetime.now(timezone.utc)
    claims = {
        "iss": account.get("client_email"),
        "scope": "https://www.googleapis.com/auth/firebase.messaging",
        "aud": account.get("token_uri", "https://oauth2.googleapis.com/token"),
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(minutes=55)).timestamp()),
    }
    try:
        assertion = jwt.encode(claims, account["private_key"], algorithm="RS256")
        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.post(
                claims["aud"],
                data={
                    "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                    "assertion": assertion,
                },
            )
        response.raise_for_status()
        data = response.json()
        _fcm_access_token = data.get("access_token")
        _fcm_access_token_expires_at = now + timedelta(seconds=int(data.get("expires_in", 3600)))
        return _fcm_access_token
    except Exception as exc:
        logger.warning("Unable to obtain Firebase access token: %s", exc)
        return None

async def send_push_to_user(user_ref: Any, title: str, body: str, payload: str = "notifications") -> None:
    user = await find_user_by_ref(user_ref)
    token = (user or {}).get("fcmToken")
    if not token:
        return
    account = firebase_service_account()
    project_id = (account or {}).get("project_id") or os.environ.get("FIREBASE_PROJECT_ID", "")
    access_token = await firebase_access_token()
    if not project_id or not access_token:
        return
    message = {
        "message": {
            "token": token,
            "notification": {"title": title, "body": body},
            "data": {"payload": payload, "route": payload},
            "android": {
                "priority": "HIGH",
                "notification": {
                    "channel_id": "vivaahsetu_alerts_v2",
                    "sound": "default",
                    "default_vibrate_timings": True,
                },
            },
        }
    }
    try:
        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.post(
                f"https://fcm.googleapis.com/v1/projects/{project_id}/messages:send",
                headers={"Authorization": f"Bearer {access_token}"},
                json=message,
            )
        if response.status_code >= 400:
            logger.warning("FCM send failed: %s %s", response.status_code, response.text)
    except Exception as exc:
        logger.warning("FCM send failed: %s", exc)

async def create_user_notification(user_ref: Any, notification: Dict[str, Any], payload: str = "notifications") -> None:
    user = await find_user_by_ref(user_ref)
    if not user:
        return
    await db.users.update_one({"_id": user["_id"]}, {"$push": {"notifications": notification}})
    manager = globals().get("ws_manager")
    if manager:
        await manager.send_to_user(normalize_ref(user["_id"]), {"type": "notification_created", "notification": notification})
    await send_push_to_user(
        user,
        "VivaahSetu update",
        notification.get("message", "You have a new notification."),
        payload,
    )

async def create_user_notification_once(
    user_ref: Any,
    notification: Dict[str, Any],
    payload: str = "notifications",
    *,
    unique_key: str,
) -> bool:
    user = await find_user_by_ref(user_ref)
    if not user:
        return False
    existing = await db.users.find_one(
        {"_id": user["_id"], "notifications.key": unique_key},
        {"_id": 1},
    )
    if existing:
        return False
    notification["key"] = unique_key
    await create_user_notification(user["_id"], notification, payload)
    return True

async def create_profile_view_notification(viewed_user: dict, visitor: dict) -> None:
    now = datetime.now(timezone.utc)
    day_key = now.date().isoformat()
    visitor_id = normalize_ref(visitor.get("_id"))
    if not visitor_id:
        return
    visitor_name = visitor.get("name") or "Someone"
    await create_user_notification_once(
        viewed_user["_id"],
        {
            "id": str(uuid.uuid4()),
            "type": "profile_visitor",
            "fromUserId": visitor_id,
            "fromUserName": visitor_name,
            "message": f"{visitor_name} viewed your profile",
            "read": False,
            "createdAt": now.isoformat(),
        },
        f"profile:{visitor_id}",
        unique_key=f"profile_view:{visitor_id}:{day_key}",
    )

def user_match_query_for(user: dict) -> Dict[str, Any]:
    user_gender = (user.get("gender") or "").strip().lower()
    blocked = normalize_ref_list(user.get("blockedUsers", []))
    exclude_ids = [user["_id"]]
    exclude_ids.extend(ObjectId(uid) for uid in set(blocked) if ObjectId.is_valid(uid))
    query: Dict[str, Any] = {
        "_id": {"$nin": exclude_ids},
        "$and": [{"$or": visible_profile_or_conditions()}],
    }
    if user_gender == "male":
        query["gender"] = gender_regex("female")
    elif user_gender == "female":
        query["gender"] = gender_regex("male")
    return query

async def ensure_daily_match_notification(current_user: dict, now: datetime) -> int:
    day_key = now.date().isoformat()
    query = user_match_query_for(current_user)
    total = await db.users.count_documents(query)
    if total <= 0:
        return 0
    sample = await db.users.find_one(query, {"name": 1})
    sample_name = (sample or {}).get("name") or "a compatible profile"
    created = await create_user_notification_once(
        current_user["_id"],
        {
            "id": str(uuid.uuid4()),
            "type": "daily_match",
            "message": f"{total} compatible profiles are waiting today, including {sample_name}.",
            "read": False,
            "createdAt": now.isoformat(),
        },
        "matches",
        unique_key=f"daily_match:{day_key}",
    )
    return 1 if created else 0

async def ensure_connection_due_notifications(current_user: dict, now: datetime) -> int:
    user_id = normalize_ref(current_user["_id"])
    active_conns = await db.connections_data.find(
        {"users": user_id, "status": "active", "expiresAt": {"$gt": now.isoformat()}},
        {"_id": 0},
    ).to_list(100)
    created_count = 0
    for conn in active_conns:
        days = connection_days_remaining(conn.get("expiresAt"), now)
        if days not in CONNECTION_REMINDER_DAYS:
            continue
        users_in_conn = normalize_ref_list(conn.get("users", []))
        partner_id = next((ref for ref in users_in_conn if ref != user_id), "")
        if not partner_id:
            continue
        partner = await find_user_by_ref(partner_id, {"name": 1})
        partner_name = (partner or {}).get("name") or "your match"
        label = "expires today" if days == 0 else f"has {days} day{'s' if days != 1 else ''} left"
        created = await create_user_notification_once(
            current_user["_id"],
            {
                "id": str(uuid.uuid4()),
                "type": "connection_expiring",
                "connectionId": conn.get("id", ""),
                "fromUserId": partner_id,
                "fromUserName": partner_name,
                "message": f"Your connection with {partner_name} {label}. Request an extension if you need more time.",
                "read": False,
                "createdAt": now.isoformat(),
            },
            "connections",
            unique_key=f"connection_due:{conn.get('id', '')}:{days}:{now.date().isoformat()}",
        )
        if created:
            created_count += 1
    return created_count

async def ensure_user_notification_digest(current_user: dict) -> int:
    now = datetime.now(timezone.utc)
    created = 0
    created += await ensure_daily_match_notification(current_user, now)
    created += await ensure_connection_due_notifications(current_user, now)
    return created

def visible_profile_or_conditions() -> List[Dict[str, Any]]:
    return [
        {"settings.profileVisible": {"$exists": False}},
        {"settings.profileVisible": True},
        {"profileVisible": {"$exists": False}},
        {"profileVisible": True},
        {"profileVisibility": {"$exists": False}},
        {"profileVisibility": {"$regex": r"^(public|visible|yes|all)$", "$options": "i"}},
    ]

def merge_auth_provider(existing_provider: Optional[str], new_provider: str) -> str:
    providers = {
        provider.strip()
        for provider in (existing_provider or "").split("+")
        if provider and provider.strip()
    }
    providers.add(new_provider)
    ordered = [provider for provider in ["google", "email"] if provider in providers]
    return "+".join(ordered) if ordered else new_provider

def check_feature_access(plan: str, feature: str) -> bool:
    access = {
        "free": {"chat": False, "contacts": False, "visitors": False, "advanced_filters": False, "extension": False},
        "focus": {"chat": True, "contacts": True, "visitors": True, "advanced_filters": True, "extension": True},
        "commit": {"chat": True, "contacts": True, "visitors": True, "advanced_filters": True, "extension": True},
    }
    return access.get(plan or "free", access["free"]).get(feature, False)

# ============ AUTH ROUTES ============

@api_router.post("/auth/register")
async def register(input: RegisterInput):
    email = input.email.strip().lower()
    if not email:
        raise HTTPException(status_code=400, detail="Email is required")
    if len(input.password) < 6:
        raise HTTPException(status_code=400, detail="Password must be at least 6 characters")

    existing = await db.users.find_one({"email": email})
    if existing:
        if not existing.get("password_hash"):
            update_doc = {
                "password_hash": hash_password(input.password),
                "auth_provider": merge_auth_provider(existing.get("auth_provider"), "email"),
                "updatedAt": datetime.now(timezone.utc),
            }
            if input.name.strip():
                update_doc["name"] = input.name.strip()
            if input.gender:
                update_doc["gender"] = input.gender

            await db.users.update_one({"_id": existing["_id"]}, {"$set": update_doc})
            updated_user = await db.users.find_one({"_id": existing["_id"]})
            token = create_access_token({"sub": str(existing["_id"])})
            return {"token": token, "user": serialize_user(updated_user)}

        raise HTTPException(status_code=400, detail="Email already registered")

    now = datetime.now(timezone.utc)
    user_doc = {
        "email": email,
        "password_hash": hash_password(input.password),
        "name": input.name.strip(),
        "gender": input.gender,
        "auth_provider": "email",
        "plan": "free",
        "profileComplete": False,
        "photos": [],
        "age": None,
        "religion": "",
        "caste": "",
        "motherTongue": "",
        "city": "",
        "state": "",
        "education": "",
        "occupation": "",
        "income": "",
        "height": "",
        "about": "",
        "maritalStatus": "",
        "phone": "",
        "familyDetails": "",
        "partnerPreferences": {},
        "connections": [],
        "connectionRequestsSent": [],
        "connectionRequestsReceived": [],
        "blockedUsers": [],
        "profileVisitors": [],
        "notifications": [],
        "settings": default_user_settings(),
        "createdAt": now,
        "updatedAt": now,
    }
    result = await db.users.insert_one(user_doc)
    user_doc["_id"] = result.inserted_id
    token = create_access_token({"sub": str(result.inserted_id)})
    return {"token": token, "user": serialize_user(user_doc)}

@api_router.post("/auth/login")
async def login(input: LoginInput):
    email = input.email.strip().lower()
    user = await db.users.find_one({"email": email})
    if not user:
        raise HTTPException(status_code=401, detail="Invalid email or password")
    if not user.get("password_hash"):
        raise HTTPException(
            status_code=401,
            detail="This email is linked to Google sign-in only. Use Google or tap Create Account with the same email once to add a password.",
        )
    if not verify_password(input.password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = create_access_token({"sub": str(user["_id"])})
    await db.users.update_one({"_id": user["_id"]}, {"$set": {"updatedAt": datetime.now(timezone.utc)}})
    return {"token": token, "user": serialize_user(user)}

@api_router.post("/auth/google-login")
async def google_login(login_data: GoogleLoginRequest):
    try:
        email = (login_data.email or "").strip().lower()
        name = (login_data.name or "").strip()
        photo_url = login_data.photoUrl

        # If mobile/web client only sends idToken, resolve user profile from Google.
        if login_data.idToken and (not email or not name):
            async with httpx.AsyncClient() as client_http:
                token_resp = await client_http.get(
                    "https://oauth2.googleapis.com/tokeninfo",
                    params={"id_token": login_data.idToken},
                    timeout=10,
                )
                if token_resp.status_code != 200:
                    raise HTTPException(status_code=401, detail="Invalid Google token")
                token_data = token_resp.json()

            aud = token_data.get("aud", "")
            if aud and GOOGLE_CLIENT_ID and aud != GOOGLE_CLIENT_ID:
                raise HTTPException(status_code=401, detail="Google token audience mismatch")

            email = (token_data.get("email") or email or "").strip().lower()
            name = (token_data.get("name") or name or "").strip()
            photo_url = token_data.get("picture") or photo_url

        if not email:
            raise HTTPException(status_code=400, detail="Google email not available")
        if not name:
            name = email.split("@")[0]

        user = await db.users.find_one({"email": email})

        if user is None:
            now = datetime.now(timezone.utc)
            user_doc = {
                "email": email,
                "password_hash": "",
                "name": name,
                "auth_provider": "google",
                "photoUrl": photo_url,
                "plan": "free",
                "profileComplete": False,
                "photos": [photo_url] if photo_url else [],
                "age": None,
                "gender": "",
                "religion": "",
                "caste": "",
                "motherTongue": "",
                "city": "",
                "state": "",
                "education": "",
                "occupation": "",
                "income": "",
                "height": "",
                "about": "",
                "maritalStatus": "",
                "phone": "",
                "familyDetails": "",
                "partnerPreferences": {},
                "connections": [],
                "connectionRequestsSent": [],
                "connectionRequestsReceived": [],
                "blockedUsers": [],
                "profileVisitors": [],
                "notifications": [],
                "settings": default_user_settings(),
                "createdAt": now,
                "updatedAt": now,
            }
            result = await db.users.insert_one(user_doc)
            user_doc["_id"] = result.inserted_id
            user = user_doc
        else:
            update_doc = {
                "auth_provider": merge_auth_provider(user.get("auth_provider"), "google"),
                "updatedAt": datetime.now(timezone.utc),
            }
            if photo_url and not user.get("photoUrl"):
                update_doc["photoUrl"] = photo_url
            await db.users.update_one({"_id": user["_id"]}, {"$set": update_doc})
            user = await db.users.find_one({"_id": user["_id"]})

        token = create_access_token({"sub": str(user["_id"])})
        return {"token": token, "user": serialize_user(user)}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Google login error: {e}")
        raise HTTPException(status_code=500, detail=f"Authentication failed: {str(e)}")

@api_router.post("/auth/firebase/session")
async def firebase_session(payload: FirebaseSessionInput):
    try:
        return await google_login(
            GoogleLoginRequest(
                idToken=payload.id_token,
                email="",
                name=payload.name or "",
                photoUrl=None,
            )
        )
    except Exception:
        # Fallback for local/dev tokens: parse claims without signature verification.
        claims = jwt.get_unverified_claims(payload.id_token)
        email = (claims.get("email") or "").strip().lower()
        if not email:
            raise HTTPException(status_code=401, detail="Invalid Firebase token")
        name = (payload.name or claims.get("name") or email.split("@")[0]).strip()
        photo_url = claims.get("picture")

        user = await db.users.find_one({"email": email})
        now = datetime.now(timezone.utc)
        if user is None:
            user_doc = {
                "email": email,
                "password_hash": "",
                "name": name,
                "auth_provider": "google",
                "photoUrl": photo_url,
                "firebase_uid": claims.get("sub"),
                "plan": "free",
                "profileComplete": False,
                "photos": [photo_url] if photo_url else [],
                "age": None,
                "gender": payload.gender or "",
                "religion": "",
                "caste": "",
                "sub_caste": "",
                "motherTongue": "",
                "city": "",
                "state": "",
                "location": "",
                "education": "",
                "occupation": "",
                "profession": "",
                "income": "",
                "height": "",
                "about": "",
                "maritalStatus": "",
                "phone": "",
                "familyDetails": "",
                "partnerPreferences": {},
                "connections": [],
                "connectionRequestsSent": [],
                "connectionRequestsReceived": [],
                "blockedUsers": [],
                "profileVisitors": [],
                "notifications": [],
                "settings": default_user_settings(),
                "createdAt": now,
                "updatedAt": now,
            }
            result = await db.users.insert_one(user_doc)
            user_doc["_id"] = result.inserted_id
            user = user_doc
        else:
            await db.users.update_one(
                {"_id": user["_id"]},
                {
                    "$set": {
                        "auth_provider": merge_auth_provider(user.get("auth_provider"), "google"),
                        "firebase_uid": claims.get("sub") or user.get("firebase_uid"),
                        "updatedAt": now,
                    }
                },
            )
            user = await db.users.find_one({"_id": user["_id"]})

        token = create_access_token({"sub": str(user["_id"])})
        return {"token": token, "user": serialize_user(user)}

@api_router.get("/auth/me")
async def get_me(current_user: dict = Depends(get_current_user)):
    return {"user": serialize_user(current_user)}

# ============ PROFILE ROUTES ============

@api_router.get("/profile/me")
async def get_my_profile(current_user: dict = Depends(get_current_user)):
    profile = serialize_user(current_user)
    return {"user": profile, **profile}

@api_router.put("/profile")
@api_router.put("/profile/update")
async def update_profile(data: ProfileUpdateInput, current_user: dict = Depends(get_current_user)):
    update = {k: v for k, v in data.model_dump().items() if v is not None}
    # Normalize snake_case/camelCase variants used across clients.
    update["dob"] = update.get("dob") or update.get("date_of_birth")
    update["date_of_birth"] = update.get("date_of_birth") or update.get("dob")
    update["birthTime"] = update.get("birthTime") or update.get("birth_time")
    update["birth_time"] = update.get("birth_time") or update.get("birthTime")
    update["birthPlace"] = update.get("birthPlace") or update.get("birth_place")
    update["birth_place"] = update.get("birth_place") or update.get("birthPlace")
    update["profileManagedBy"] = update.get("profileManagedBy") or update.get("profile_managed_by")
    update["profile_managed_by"] = update.get("profile_managed_by") or update.get("profileManagedBy")
    update["sub_caste"] = update.get("sub_caste") or update.get("subCaste")
    update["subCaste"] = update.get("subCaste") or update.get("sub_caste")
    update["motherTongue"] = update.get("motherTongue") or update.get("mother_tongue")
    update["mother_tongue"] = update.get("mother_tongue") or update.get("motherTongue")
    update["maritalStatus"] = update.get("maritalStatus") or update.get("marital_status")
    update["marital_status"] = update.get("marital_status") or update.get("maritalStatus")
    update["familyDetails"] = update.get("familyDetails") or update.get("family_details")
    update["family_details"] = update.get("family_details") or update.get("familyDetails")
    update["occupation"] = update.get("occupation") or update.get("profession")
    update["profession"] = update.get("profession") or update.get("occupation")
    update["partnerPreferences"] = update.get("partnerPreferences") or update.get("partner_preferences")
    update["partner_preferences"] = update.get("partner_preferences") or update.get("partnerPreferences")
    if update.get("location") and not update.get("city"):
        city_part = str(update["location"]).split(",", 1)[0].strip()
        if city_part:
            update["city"] = city_part
    if update.get("city") and update.get("state"):
        update["location"] = f"{update['city']}, {update['state']}"
    elif update.get("city") and not update.get("location"):
        update["location"] = str(update["city"]).strip()
    update = {k: v for k, v in update.items() if v is not None}
    update["updatedAt"] = datetime.now(timezone.utc)
    required = ["name", "age", "gender", "city", "occupation"]
    merged = {**{k: current_user.get(k) for k in required}, **update}
    update["profileComplete"] = all(merged.get(f) for f in required)
    await db.users.update_one({"_id": current_user["_id"]}, {"$set": update})
    updated = await db.users.find_one({"_id": current_user["_id"]})
    return serialize_user(updated)

@api_router.get("/settings")
async def get_settings(current_user: dict = Depends(get_current_user)):
    settings = default_user_settings()
    settings.update(current_user.get("settings", {}) if isinstance(current_user.get("settings"), dict) else {})
    return {"settings": settings, **settings}

@api_router.put("/settings")
async def update_settings(data: SettingsInput, current_user: dict = Depends(get_current_user)):
    update = {k: v for k, v in data.model_dump().items() if v is not None}
    settings = default_user_settings()
    settings.update(current_user.get("settings", {}) if isinstance(current_user.get("settings"), dict) else {})
    settings.update(update)
    await db.users.update_one(
        {"_id": current_user["_id"]},
        {"$set": {"settings": settings, "updatedAt": datetime.now(timezone.utc)}},
    )
    return {"settings": settings, **settings}

@api_router.put("/profile")
async def update_profile_v2(data: ProfileUpdateInput, current_user: dict = Depends(get_current_user)):
    updated = await update_profile(data, current_user)
    return {"user": updated, **updated}

@api_router.post("/profile/upload-photo")
async def upload_photo(
    request: Request,
    file: Optional[UploadFile] = File(default=None),
    current_user: dict = Depends(get_current_user),
):
    photo_value: Optional[str] = None
    if file is not None:
        file_bytes = await file.read()
        if not file_bytes:
            raise HTTPException(status_code=400, detail="Uploaded file is empty")
        content_type = file.content_type or "image/jpeg"
        photo_value = f"data:{content_type};base64,{base64.b64encode(file_bytes).decode('utf-8')}"
    else:
        try:
            payload = await request.json()
        except Exception:
            payload = {}
        if isinstance(payload, dict):
            photo_value = payload.get("photo")
        if not photo_value:
            raise HTTPException(status_code=422, detail="file or photo is required")

    photos = current_user.get("photos", []) or []
    if len(photos) >= MAX_PHOTOS:
        raise HTTPException(status_code=400, detail=f"Maximum {MAX_PHOTOS} photos allowed")
    photos.append(photo_value)
    primary_photo = photos[0] if photos else ""
    await db.users.update_one(
        {"_id": current_user["_id"]},
        {"$set": {"photos": photos, "photoUrl": primary_photo, "profile_photo": primary_photo, "updatedAt": datetime.now(timezone.utc)}}
    )
    return {"photos": photos}

@api_router.post("/profile/photo/{index}/primary")
async def set_primary_photo(index: int, current_user: dict = Depends(get_current_user)):
    photos = current_user.get("photos", []) or []
    if index < 0 or index >= len(photos):
        raise HTTPException(status_code=400, detail="Invalid photo index")
    selected = photos[index]
    ordered = [selected, *[photo for i, photo in enumerate(photos) if i != index]]
    await db.users.update_one(
        {"_id": current_user["_id"]},
        {"$set": {"photos": ordered, "photoUrl": selected, "profile_photo": selected, "updatedAt": datetime.now(timezone.utc)}}
    )
    return {"photos": ordered, "photoUrl": selected, "profile_photo": selected}

@api_router.delete("/profile/photo/{index}")
async def delete_photo(index: int, current_user: dict = Depends(get_current_user)):
    photos = current_user.get("photos", []) or []
    if index < 0 or index >= len(photos):
        raise HTTPException(status_code=400, detail="Invalid photo index")
    photos.pop(index)
    primary_photo = photos[0] if photos else ""
    await db.users.update_one(
        {"_id": current_user["_id"]},
        {"$set": {"photos": photos, "photoUrl": primary_photo, "profile_photo": primary_photo, "updatedAt": datetime.now(timezone.utc)}}
    )
    return {"photos": photos}

@api_router.get("/profile/{user_id}")
async def get_user_profile(user_id: str, current_user: dict = Depends(get_current_user)):
    target = await find_user_by_ref(user_id)
    if not target:
        raise HTTPException(status_code=404, detail="User not found")
    # Track profile visit
    target_ref = str(target["_id"])
    if str(current_user["_id"]) != target_ref:
        await db.users.update_one(
            {"_id": target["_id"]},
            {"$addToSet": {"profileVisitors": {
                "visitorId": str(current_user["_id"]),
                "visitedAt": datetime.now(timezone.utc).isoformat()
            }}}
        )
        await create_profile_view_notification(target, current_user)
    profile = serialize_user(target)
    return {"user": profile, **profile}

# ============ MATCHES ROUTES ============

@api_router.get("/matches")
async def get_matches(
    page: int = 1, limit: int = 20,
    minAge: Optional[int] = None, maxAge: Optional[int] = None,
    age_min: Optional[int] = None, age_max: Optional[int] = None,
    gender: Optional[str] = None, religion: Optional[str] = None,
    caste: Optional[str] = None, city: Optional[str] = None,
    location: Optional[str] = None, profession: Optional[str] = None,
    occupation: Optional[str] = None,
    profileManagedBy: Optional[str] = None,
    profile_managed_by: Optional[str] = None,
    current_user: dict = Depends(get_current_user)
):
    try:
        min_age = age_min if age_min is not None else minAge
        max_age = age_max if age_max is not None else maxAge
        city_or_location = (location or city or "").strip()
        user_gender = (current_user.get("gender") or "").strip().lower()
        blocked = normalize_ref_list(current_user.get("blockedUsers", []))
        exclude_ids = [ObjectId(uid) for uid in set(blocked) if ObjectId.is_valid(uid)]
        connected = normalize_ref_list(current_user.get("connections", []))
        sent = normalize_ref_list(current_user.get("connectionRequestsSent", []))
        received = normalize_ref_list(current_user.get("connectionRequestsReceived", []))

        def base_query() -> Dict[str, Any]:
            query: Dict[str, Any] = {
                "_id": {"$ne": current_user["_id"]},
                "$and": [
                    {
                        "$or": visible_profile_or_conditions()
                    }
                ],
            }
            if exclude_ids:
                query["_id"]["$nin"] = exclude_ids
            if gender:
                query["gender"] = gender_regex(gender.strip())
            elif user_gender == "male":
                query["gender"] = gender_regex("female")
            elif user_gender == "female":
                query["gender"] = gender_regex("male")
            return query

        def apply_filters(query: Dict[str, Any], *, include_age: bool, include_location: bool, include_religion: bool, include_caste: bool, include_profession: bool) -> Dict[str, Any]:
            if include_age and (min_age is not None or max_age is not None):
                age_q: Dict[str, Any] = {}
                if min_age is not None:
                    age_q["$gte"] = min_age
                if max_age is not None:
                    age_q["$lte"] = max_age
                query["age"] = age_q
            if include_religion and religion:
                query["religion"] = {"$regex": religion, "$options": "i"}
            if include_caste and caste:
                query["caste"] = {"$regex": caste, "$options": "i"}
            if include_location and city_or_location:
                query["$and"] = query.get("$and", [])
                query["$and"].append(
                    {"$or": [
                        {"city": {"$regex": city_or_location, "$options": "i"}},
                        {"location": {"$regex": city_or_location, "$options": "i"}},
                        {"state": {"$regex": city_or_location, "$options": "i"}},
                    ]}
                )
            profession_or_occupation = (profession or occupation or "").strip()
            if include_profession and profession_or_occupation:
                query["$and"] = query.get("$and", [])
                query["$and"].append(
                    {
                        "$or": [
                            {"occupation": {"$regex": profession_or_occupation, "$options": "i"}},
                            {"profession": {"$regex": profession_or_occupation, "$options": "i"}},
                        ]
                    }
                )
            managed_by = (profileManagedBy or profile_managed_by or "").strip()
            if managed_by:
                query["$and"] = query.get("$and", [])
                query["$and"].append(
                    {
                        "$or": [
                            {"profileManagedBy": {"$regex": managed_by, "$options": "i"}},
                            {"profile_managed_by": {"$regex": managed_by, "$options": "i"}},
                        ]
                    }
                )
            return query

        query_attempts = [
            apply_filters(base_query(), include_age=True, include_location=True, include_religion=True, include_caste=True, include_profession=True),
            apply_filters(base_query(), include_age=True, include_location=False, include_religion=True, include_caste=True, include_profession=True),
            apply_filters(base_query(), include_age=True, include_location=False, include_religion=False, include_caste=False, include_profession=False),
            apply_filters(base_query(), include_age=False, include_location=False, include_religion=False, include_caste=False, include_profession=False),
        ]

        query = query_attempts[0]
        users = []
        total = 0
        skip = (page - 1) * limit
        for attempt in query_attempts:
            attempt_total = await db.users.count_documents(attempt)
            if attempt_total > 0:
                query = attempt
                total = attempt_total
                users = await db.users.find(attempt, {"password_hash": 0}).skip(skip).limit(limit).to_list(limit)
                break
        if not users and total == 0:
            relaxed = {
                "_id": {"$ne": current_user["_id"]},
                "$and": [
                    {"$or": visible_profile_or_conditions()}
                ],
            }
            if exclude_ids:
                relaxed["_id"]["$nin"] = exclude_ids
            total = await db.users.count_documents(relaxed)
            if total > 0:
                query = relaxed
                users = await db.users.find(relaxed, {"password_hash": 0}).skip(skip).limit(limit).to_list(limit)
        if not users and total == 0:
            users = []

        matches = []
        for u in users:
            su = serialize_user(u)
            profile_id = normalize_ref(su.get("id"))
            su["alreadyConnected"] = profile_id in connected
            su["requestSent"] = profile_id in sent
            su["requestReceived"] = profile_id in received
            su["already_connected"] = su["alreadyConnected"]
            su["request_sent"] = su["requestSent"]
            su["request_received"] = su["requestReceived"]
            matches.append(su)

        return {"matches": matches, "total": total, "page": page, "pages": (total + limit - 1) // limit if total else 0}
    except Exception as e:
        logger.exception("Matches query failed")
        return {"matches": [], "total": 0, "page": page, "pages": 0, "error": str(e)}

# ============ CONNECTIONS ROUTES ============

@api_router.post("/connections/request/{target_id}")
async def send_connection_request(target_id: str, current_user: dict = Depends(get_current_user)):
    user_id = normalize_ref(current_user["_id"])
    target_ref = normalize_ref(target_id)
    if user_id == target_ref:
        raise HTTPException(status_code=400, detail="Cannot connect with yourself")

    connections = normalize_ref_list(current_user.get("connections", []))
    if target_ref in connections:
        raise HTTPException(status_code=400, detail="Already connected")

    sent = normalize_ref_list(current_user.get("connectionRequestsSent", []))
    if target_ref in sent:
        raise HTTPException(status_code=400, detail="Request already sent")

    active_count = len(connections)
    if active_count >= MAX_CONNECTIONS:
        raise HTTPException(status_code=400, detail=f"Maximum {MAX_CONNECTIONS} connections reached")

    target = await find_user_by_ref(target_ref)
    if not target:
        raise HTTPException(status_code=404, detail="User not found")

    target_db_id = target["_id"]
    target_ref = normalize_ref(target_db_id)
    await db.users.update_one({"_id": current_user["_id"]}, {"$addToSet": {"connectionRequestsSent": target_ref}})
    await db.users.update_one({"_id": target_db_id}, {"$addToSet": {"connectionRequestsReceived": user_id}})

    notification = {
        "id": str(uuid.uuid4()),
        "type": "connection_request",
        "fromUserId": user_id,
        "fromUserName": current_user.get("name", "Someone"),
        "message": f"{current_user.get('name', 'Someone')} sent you a connection request",
        "read": False,
        "createdAt": datetime.now(timezone.utc).isoformat()
    }
    await create_user_notification(target_db_id, notification, "connections")
    return {"message": "Connection request sent"}

@api_router.post("/connections/accept/{requester_id}")
async def accept_connection(requester_id: str, current_user: dict = Depends(get_current_user)):
    user_id = normalize_ref(current_user["_id"])
    requester_ref = normalize_ref(requester_id)
    received = normalize_ref_list(current_user.get("connectionRequestsReceived", []))
    if requester_ref not in received:
        raise HTTPException(status_code=400, detail="No pending request from this user")

    active = len(normalize_ref_list(current_user.get("connections", [])))
    if active >= MAX_CONNECTIONS:
        raise HTTPException(status_code=400, detail=f"Maximum {MAX_CONNECTIONS} connections reached")

    now = datetime.now(timezone.utc)
    expires_at = now + timedelta(days=CONNECTION_DURATION_DAYS)

    conn_doc = {
        "id": str(uuid.uuid4()),
        "users": [user_id, requester_ref],
        "status": "active",
        "createdAt": now.isoformat(),
        "expiresAt": expires_at.isoformat(),
        "extensions": 0,
    }
    await db.connections_data.insert_one(conn_doc)

    await db.users.update_one({"_id": current_user["_id"]}, {
        "$addToSet": {"connections": requester_ref},
        "$pull": {"connectionRequestsReceived": requester_ref}
    })
    requester_user = await find_user_by_ref(requester_ref)
    if not requester_user:
        raise HTTPException(status_code=404, detail="Requester not found")
    await db.users.update_one({"_id": requester_user["_id"]}, {
        "$addToSet": {"connections": user_id},
        "$pull": {"connectionRequestsSent": user_id}
    })

    notification = {
        "id": str(uuid.uuid4()),
        "type": "connection_accepted",
        "fromUserId": user_id,
        "fromUserName": current_user.get("name", "Someone"),
        "message": f"{current_user.get('name', 'Someone')} accepted your connection request",
        "read": False,
        "createdAt": now.isoformat()
    }
    await create_user_notification(requester_user["_id"], notification, "connections")
    return {"message": "Connection accepted", "expiresAt": expires_at.isoformat()}

@api_router.post("/connections/reject/{requester_id}")
async def reject_connection(requester_id: str, current_user: dict = Depends(get_current_user)):
    user_id = normalize_ref(current_user["_id"])
    requester_ref = normalize_ref(requester_id)
    await db.users.update_one({"_id": current_user["_id"]}, {"$pull": {"connectionRequestsReceived": requester_ref}})
    requester_user = await find_user_by_ref(requester_ref)
    if requester_user:
        await db.users.update_one({"_id": requester_user["_id"]}, {"$pull": {"connectionRequestsSent": user_id}})
    return {"message": "Connection rejected"}

@api_router.post("/connections/cancel/{target_id}")
async def cancel_connection(target_id: str, current_user: dict = Depends(get_current_user)):
    user_id = normalize_ref(current_user["_id"])
    target_ref = normalize_ref(target_id)
    await db.users.update_one({"_id": current_user["_id"]}, {"$pull": {"connectionRequestsSent": target_ref}})
    target_user = await find_user_by_ref(target_ref)
    if target_user:
        await db.users.update_one({"_id": target_user["_id"]}, {"$pull": {"connectionRequestsReceived": user_id}})
    return {"message": "Connection request cancelled"}

@api_router.post("/connections/remove/{target_id}")
async def remove_connection(target_id: str, current_user: dict = Depends(get_current_user)):
    user_id = normalize_ref(current_user["_id"])
    target_ref = normalize_ref(target_id)
    await db.connections_data.update_many(
        {"users": {"$all": [user_id, target_ref]}, "status": "active"},
        {"$set": {"status": "removed"}}
    )
    await db.users.update_one({"_id": current_user["_id"]}, {"$pull": {"connections": target_ref}})
    target_user = await find_user_by_ref(target_ref)
    if target_user:
        await db.users.update_one({"_id": target_user["_id"]}, {"$pull": {"connections": user_id}})
    return {"message": "Connection removed"}

@api_router.post("/connections/extend/request")
async def request_connection_extension(payload: ConnectionExtensionRequest, current_user: dict = Depends(get_current_user)):
    user_id = normalize_ref(current_user["_id"])
    connection_id = (payload.connection_id or payload.connectionId or "").strip()
    if not connection_id:
        raise HTTPException(status_code=400, detail="connection_id is required")

    now = datetime.now(timezone.utc)
    conn = await db.connections_data.find_one(
        {"id": connection_id, "users": user_id, "status": "active", "expiresAt": {"$gt": now.isoformat()}},
        {"_id": 0},
    )
    if not conn:
        raise HTTPException(status_code=404, detail="Active connection not found")
    days_remaining = connection_days_remaining(conn.get("expiresAt"), now)
    if days_remaining >= CONNECTION_DURATION_DAYS:
        raise HTTPException(status_code=400, detail="Extension can be requested only when fewer than 15 days remain")

    extension_request = conn.get("extensionRequest") or conn.get("extension_request") or {}
    if extension_request.get("status") == "pending":
        raise HTTPException(status_code=400, detail="Extension request is already pending")

    users_in_conn = normalize_ref_list(conn.get("users", []))
    partner_id = next((ref for ref in users_in_conn if ref != user_id), "")
    if not partner_id:
        raise HTTPException(status_code=400, detail="Connection partner not found")

    request_doc = {
        "status": "pending",
        "requestedBy": user_id,
        "requested_by": user_id,
        "requestedAt": now.isoformat(),
        "requested_at": now.isoformat(),
    }
    await db.connections_data.update_one(
        {"id": connection_id},
        {"$set": {"extensionRequest": request_doc, "extension_request": request_doc}},
    )

    partner = await find_user_by_ref(partner_id)
    if partner:
        notification = {
            "id": str(uuid.uuid4()),
            "type": "connection_extension_request",
            "fromUserId": user_id,
            "fromUserName": current_user.get("name", "Someone"),
            "message": f"{current_user.get('name', 'Someone')} requested more time for your connection",
            "read": False,
            "createdAt": now.isoformat(),
        }
        await create_user_notification(partner["_id"], notification, "connections")

    return {"message": "Extension request sent", "extensionRequest": request_doc, "extension_request": request_doc}

@api_router.post("/connections/extend/approve/{connection_id}")
async def approve_connection_extension(connection_id: str, current_user: dict = Depends(get_current_user)):
    user_id = normalize_ref(current_user["_id"])
    now = datetime.now(timezone.utc)
    conn = await db.connections_data.find_one(
        {"id": connection_id, "users": user_id, "status": "active", "expiresAt": {"$gt": now.isoformat()}},
        {"_id": 0},
    )
    if not conn:
        raise HTTPException(status_code=404, detail="Active connection not found")

    extension_request = conn.get("extensionRequest") or conn.get("extension_request") or {}
    requested_by = normalize_ref(extension_request.get("requestedBy") or extension_request.get("requested_by"))
    if extension_request.get("status") != "pending":
        raise HTTPException(status_code=400, detail="No pending extension request")
    if requested_by == user_id:
        raise HTTPException(status_code=400, detail="The other user must approve this extension")

    current_expiry = capped_connection_expiry(conn.get("expiresAt"), now)
    new_expiry = min(
        current_expiry + timedelta(days=CONNECTION_DURATION_DAYS),
        now + timedelta(days=MAX_CONNECTION_DURATION_DAYS),
    )
    approved_doc = {
        **extension_request,
        "status": "approved",
        "approvedBy": user_id,
        "approved_by": user_id,
        "approvedAt": now.isoformat(),
        "approved_at": now.isoformat(),
    }
    await db.connections_data.update_one(
        {"id": connection_id},
        {
            "$set": {
                "expiresAt": new_expiry.isoformat(),
                "extensionRequest": approved_doc,
                "extension_request": approved_doc,
            },
            "$inc": {"extensions": 1},
        },
    )

    requester = await find_user_by_ref(requested_by)
    if requester:
        notification = {
            "id": str(uuid.uuid4()),
            "type": "connection_extension_approved",
            "fromUserId": user_id,
            "fromUserName": current_user.get("name", "Someone"),
            "message": f"{current_user.get('name', 'Someone')} approved your connection extension",
            "read": False,
            "createdAt": now.isoformat(),
        }
        await create_user_notification(requester["_id"], notification, "connections")

    return {
        "message": "Connection extended",
        "expiresAt": new_expiry.isoformat(),
        "expires_at": new_expiry.isoformat(),
        "extensionRequest": approved_doc,
        "extension_request": approved_doc,
    }

@api_router.get("/connections")
async def get_connections(current_user: dict = Depends(get_current_user)):
    user_id = normalize_ref(current_user["_id"])
    now_iso = datetime.now(timezone.utc).isoformat()

    # Active connections with timer
    active_conns = await db.connections_data.find(
        {"users": user_id, "status": "active", "expiresAt": {"$gt": now_iso}},
        {"_id": 0}
    ).to_list(100)

    connections = []
    for conn in active_conns:
        users_in_conn = normalize_ref_list(conn.get("users", []))
        if len(users_in_conn) < 2:
            continue
        other_id = users_in_conn[1] if users_in_conn[0] == user_id else users_in_conn[0]
        u = await find_user_by_ref(other_id, {"password_hash": 0})
        if u:
            capped_expiry = capped_connection_expiry(conn["expiresAt"])
            if capped_expiry.isoformat() != conn["expiresAt"]:
                await db.connections_data.update_one(
                    {"id": conn["id"]},
                    {"$set": {"expiresAt": capped_expiry.isoformat()}},
                )
            ud = serialize_user(u)
            ud["connectionId"] = conn["id"]
            ud["connection_id"] = conn["id"]
            ud["connectedAt"] = conn["createdAt"]
            ud["connected_at"] = conn["createdAt"]
            ud["expiresAt"] = capped_expiry.isoformat()
            ud["expires_at"] = capped_expiry.isoformat()
            ud["daysRemaining"] = connection_days_remaining(capped_expiry)
            ud["days_remaining"] = ud["daysRemaining"]
            extension_request = conn.get("extensionRequest") or conn.get("extension_request")
            if extension_request:
                ud["extensionRequest"] = extension_request
                ud["extension_request"] = extension_request
            ud["extensions"] = conn.get("extensions", 0)
            connections.append(ud)

    # Pending received
    pending_received = []
    for rid in normalize_ref_list(current_user.get("connectionRequestsReceived", [])):
        u = await find_user_by_ref(rid, {"password_hash": 0})
        if u:
            pending_received.append(serialize_user(u))

    # Pending sent
    pending_sent = []
    for sid in normalize_ref_list(current_user.get("connectionRequestsSent", [])):
        u = await find_user_by_ref(sid, {"password_hash": 0})
        if u:
            pending_sent.append(serialize_user(u))

    return {
        "connections": connections,
        "pendingReceived": pending_received,
        "pendingSent": pending_sent,
        "pending_received": pending_received,
        "pending_sent": pending_sent,
        "count": len(connections),
        "max": MAX_CONNECTIONS
    }

# ============ CHAT ROUTES ============

@api_router.post("/chat/send")
async def send_message(msg: SendMessageInput, current_user: dict = Depends(get_current_user)):
    user_id = str(current_user["_id"])
    receiver_id = (msg.receiverId or msg.receiver_id or "").strip()
    if not receiver_id:
        raise HTTPException(status_code=422, detail="receiverId or receiver_id is required")
    user_plan = current_user.get("plan", "free")
    if user_plan == "free":
        raise HTTPException(status_code=403, detail="Chat requires Focus or Commit plan")

    conn = await db.connections_data.find_one({
        "users": {"$all": [user_id, receiver_id]},
        "status": "active",
        "expiresAt": {"$gt": datetime.now(timezone.utc).isoformat()}
    })
    if not conn:
        raise HTTPException(status_code=403, detail="Only active mutual connections can chat")

    message_doc = {
        "id": str(uuid.uuid4()),
        "senderId": user_id,
        "receiverId": receiver_id,
        "content": msg.content,
        "read": False,
        "createdAt": datetime.now(timezone.utc).isoformat()
    }
    await db.messages.insert_one(message_doc)
    message_doc.pop("_id", None)
    manager = globals().get("ws_manager")
    if manager:
        await manager.send_to_user(user_id, {"type": "new_message", "message": message_doc})
        await manager.send_to_user(receiver_id, {"type": "new_message", "message": message_doc})
    await create_user_notification(
        receiver_id,
        {
            "id": str(uuid.uuid4()),
            "type": "chat_message",
            "senderId": user_id,
            "sender_id": user_id,
            "fromUserName": current_user.get("name", "VivaahSetu"),
            "message": f"New message from {current_user.get('name', 'VivaahSetu')}",
            "preview": msg.content,
            "read": False,
            "createdAt": message_doc["createdAt"],
        },
        f"chat:{user_id}",
    )
    return {"message": message_doc}

@api_router.get("/chat/{partner_id}")
async def get_chat(partner_id: str, page: int = 1, limit: int = 50, current_user: dict = Depends(get_current_user)):
    user_id = str(current_user["_id"])
    if current_user.get("plan", "free") == "free":
        raise HTTPException(status_code=403, detail="Chat requires Focus or Commit plan")

    query = {"$or": [
        {"senderId": user_id, "receiverId": partner_id},
        {"senderId": partner_id, "receiverId": user_id}
    ]}
    skip = (page - 1) * limit
    messages = await db.messages.find(query, {"_id": 0}).sort("createdAt", 1).skip(skip).limit(limit).to_list(limit)
    await db.messages.update_many(
        {"senderId": partner_id, "receiverId": user_id, "read": False},
        {"$set": {"read": True}}
    )
    return {"messages": messages}

@api_router.get("/chat/unread/count")
async def get_unread_count(current_user: dict = Depends(get_current_user)):
    count = await db.messages.count_documents({"receiverId": str(current_user["_id"]), "read": False})
    return {"unreadCount": count, "unread_count": count}

# ============ NOTIFICATIONS ============

@api_router.get("/notifications")
async def get_notifications(current_user: dict = Depends(get_current_user)):
    await ensure_connection_due_notifications(current_user, datetime.now(timezone.utc))
    current_user = await db.users.find_one({"_id": current_user["_id"]}) or current_user
    user_id = normalize_ref(current_user["_id"])
    unread_chat_count = await db.messages.count_documents({"receiverId": user_id, "read": False})
    notifications = current_user.get("notifications", []) or []
    if unread_chat_count > 0:
        latest_chat = await db.messages.find_one(
            {"receiverId": user_id, "read": False},
            sort=[("createdAt", -1)],
        )
        sender_id = (latest_chat or {}).get("senderId", "")
        sender = await find_user_by_ref(sender_id, {"name": 1}) if sender_id else None
        sender_name = (sender or {}).get("name", "your match")
        notifications = [
            {
                "id": "chat_unread",
                "type": "chat_unread",
                "senderId": sender_id,
                "sender_id": sender_id,
                "message": f"You have {unread_chat_count} unread chat message{'s' if unread_chat_count != 1 else ''} from {sender_name}",
                "read": False,
                "createdAt": (latest_chat or {}).get("createdAt", datetime.now(timezone.utc).isoformat()),
            },
            *notifications,
        ]
    notifications.sort(key=lambda x: x.get("createdAt", ""), reverse=True)
    return {"notifications": notifications[:50]}

@api_router.post("/notifications/read")
async def mark_notifications_read(current_user: dict = Depends(get_current_user)):
    await db.users.update_one(
        {"_id": current_user["_id"]},
        {"$set": {"notifications.$[].read": True}}
    )
    return {"message": "Notifications marked as read"}

# ============ SUBSCRIPTIONS ============

PLANS = {
    "free": {
        "id": "free", "name": "Explore", "price": 0, "discountedPrice": 0, "period": None,
        "tagline": "For discovery", "available": True,
        "features": ["Create profile", "Unlimited browsing", "Send interests", "Max 5 connections", "15-day timer applies"],
        "excluded": ["No chat", "No contact details"],
    },
    "focus": {
        "id": "focus", "name": "Focus", "price": 699, "discountedPrice": 210, "period": "month",
        "tagline": "For serious matchmaking", "badge": "MOST POPULAR", "available": True,
        "features": ["Chat unlock after mutual connection", "View contact details", "See who viewed profile", "Advanced filters", "Connection expiry alerts", "Request extension", "Serious Intent badge"],
    },
    "commit": {
        "id": "commit", "name": "Commit", "price": 1499, "discountedPrice": 450, "period": "month",
        "tagline": "Top-tier plan is launching in next phase", "badge": "COMING SOON", "available": False,
        "features": ["All Focus features", "Priority match ranking", "Higher visibility", "Verified badge included", "Smart match suggestions", "Response probability insights", "Highlighted profile in search"],
    },
}

@api_router.get("/subscriptions/plans")
async def get_plans():
    return {"plans": list(PLANS.values()), "discount_percent": DISCOUNT_PERCENT}

@api_router.get("/plans")
async def get_plans_alias():
    plans = []
    for plan in PLANS.values():
        plans.append(
            {
                "id": plan["id"],
                "name": plan["name"],
                "price": float(plan["price"]),
                "currency": "inr",
                "period": plan.get("period"),
                "tagline": plan.get("tagline"),
                "badge": plan.get("badge"),
                "features": plan.get("features", []),
                "excluded": plan.get("excluded", []),
                "original_price": plan.get("price", 0),
                "discount_percent": DISCOUNT_PERCENT,
                "discounted_price": plan.get("discountedPrice", 0),
                "is_available_for_checkout": bool(plan.get("available", False)),
                "coming_soon": not bool(plan.get("available", False)),
            }
        )
    return {"plans": plans, "discount_percent": DISCOUNT_PERCENT}

# ============ CASHFREE PAYMENT ============

class CheckoutRequest(BaseModel):
    planId: str
    returnUrl: Optional[str] = None

class SettingsInput(BaseModel):
    pushNotifications: Optional[bool] = None
    emailNotifications: Optional[bool] = None
    profileVisible: Optional[bool] = None
    showLastSeen: Optional[bool] = None
    typingIndicators: Optional[bool] = None

def get_cashfree_headers():
    return {
        "x-client-id": CASHFREE_APP_ID,
        "x-client-secret": CASHFREE_SECRET_KEY,
        "x-api-version": CASHFREE_API_VERSION,
        "Content-Type": "application/json",
    }

@api_router.post("/payment/create-order")
async def create_payment_order(req: CheckoutRequest, current_user: dict = Depends(get_current_user)):
    plan = PLANS.get(req.planId)
    if not plan or plan["price"] == 0:
        raise HTTPException(status_code=400, detail="Invalid plan")
    if not plan.get("available"):
        raise HTTPException(status_code=400, detail="This plan is not available yet")

    user_id = str(current_user["_id"])
    order_id = f"VS_{user_id[:8]}_{uuid.uuid4().hex[:8]}"
    amount = plan["discountedPrice"]

    order_payload = {
        "order_id": order_id,
        "order_amount": amount,
        "order_currency": "INR",
        "customer_details": {
            "customer_id": user_id,
            "customer_email": current_user.get("email", ""),
            "customer_phone": current_user.get("phone", "9999999999") or "9999999999",
            "customer_name": current_user.get("name", "User"),
        },
        "order_meta": {
            "return_url": req.returnUrl or "https://vivaahsetu.in/payment/success?order_id={order_id}",
            "payment_methods": "cc,dc,upi,nb,paylater",
        },
        "order_note": f"VivahSetu {plan['name']} Plan Subscription",
    }

    cf_data = {}
    try:
        async with httpx.AsyncClient() as client_http:
            resp = await client_http.post(
                f"{CASHFREE_BASE_URL}/orders",
                headers=get_cashfree_headers(),
                json=order_payload,
                timeout=15,
            )
            if resp.status_code not in (200, 201):
                logger.error(f"Cashfree create order failed: {resp.text}")
                raise HTTPException(status_code=500, detail="Payment order creation failed")
            cf_data = resp.json()
    except httpx.RequestError as e:
        logger.error(f"Cashfree request error: {e}")
        raise HTTPException(status_code=500, detail="Payment service unavailable")

    payment_session_id = cf_data.get("payment_session_id") or ""
    payment_link = ""
    payment_link_id = ""
    link_id = f"VSLINK_{uuid.uuid4().hex[:18]}"
    link_payload = {
        "link_id": link_id,
        "link_amount": amount,
        "link_currency": "INR",
        "link_purpose": f"VivahSetu {plan['name']} Plan Subscription",
        "link_auto_reminders": True,
        "customer_details": {
            "customer_name": current_user.get("name", "User"),
            "customer_phone": current_user.get("phone", "9999999999") or "9999999999",
            "customer_email": current_user.get("email", ""),
        },
        "link_meta": {
            "return_url": req.returnUrl or "https://vivaahsetu.in/payment/success?order_id={order_id}",
        },
        "link_notes": {
            "vivahsetu_order_id": order_id,
            "plan_id": req.planId,
            "user_id": user_id,
        },
    }
    try:
        async with httpx.AsyncClient() as client_http:
            link_resp = await client_http.post(
                f"{CASHFREE_BASE_URL}/links",
                headers=get_cashfree_headers(),
                json=link_payload,
                timeout=15,
            )
            if link_resp.status_code in (200, 201):
                link_data = link_resp.json()
                payment_link = link_data.get("link_url") or ""
                payment_link_id = link_data.get("link_id") or link_id
            else:
                logger.error(f"Cashfree create link failed: {link_resp.text}")
    except httpx.RequestError as e:
        logger.error(f"Cashfree payment link request error: {e}")

    # Store in DB
    tx = {
        "id": order_id,
        "userId": user_id,
        "planId": req.planId,
        "amount": amount,
        "status": "pending",
        "cfOrderId": cf_data.get("cf_order_id"),
        "paymentSessionId": payment_session_id,
        "paymentLinkId": payment_link_id,
        "createdAt": datetime.now(timezone.utc).isoformat(),
    }
    await db.payment_transactions.insert_one(tx)
    if not payment_link:
        raise HTTPException(status_code=500, detail="Unable to create hosted payment link")

    return {
        "orderId": order_id,
        "paymentSessionId": payment_session_id,
        "cfOrderId": cf_data.get("cf_order_id"),
        "amount": amount,
        "currency": "INR",
        "paymentLink": payment_link,
        "paymentLinkId": payment_link_id,
    }

@api_router.post("/cashfree/checkout")
async def create_payment_order_alias(req: CheckoutRequest, current_user: dict = Depends(get_current_user)):
    return await create_payment_order(req, current_user)

@api_router.get("/payment/verify/{order_id}")
async def verify_payment(order_id: str, current_user: dict = Depends(get_current_user)):
    tx = await db.payment_transactions.find_one({"id": order_id})
    if tx and tx.get("paymentLinkId"):
        try:
            async with httpx.AsyncClient() as client_http:
                resp = await client_http.get(
                    f"{CASHFREE_BASE_URL}/links/{tx['paymentLinkId']}/orders",
                    headers=get_cashfree_headers(),
                    timeout=15,
                )
                if resp.status_code == 200:
                    payload = resp.json()
                    orders = payload if isinstance(payload, list) else []
                    paid_order = next(
                        (
                            item
                            for item in orders
                            if str(item.get("order_status", "")).upper() == "PAID"
                        ),
                        None,
                    )
                    if paid_order:
                        plan_id = tx.get("planId", "focus")
                        now_iso = datetime.now(timezone.utc).isoformat()
                        expires = (datetime.now(timezone.utc) + timedelta(days=30)).isoformat()
                        await db.payment_transactions.update_one(
                            {"id": order_id},
                            {"$set": {"status": "paid", "verifiedAt": now_iso, "cfOrderId": paid_order.get("cf_order_id")}},
                        )
                        await db.users.update_one(
                            {"_id": current_user["_id"]},
                            {"$set": {"plan": plan_id, "planUpdatedAt": now_iso, "planExpiresAt": expires}},
                        )
                        return {"orderId": order_id, "status": "PAID", "amount": paid_order.get("order_amount")}
        except httpx.RequestError:
            pass

    try:
        async with httpx.AsyncClient() as client_http:
            resp = await client_http.get(
                f"{CASHFREE_BASE_URL}/orders/{order_id}",
                headers=get_cashfree_headers(),
                timeout=15,
            )
            if resp.status_code != 200:
                raise HTTPException(status_code=500, detail="Payment verification failed")
            cf_data = resp.json()
    except httpx.RequestError:
        raise HTTPException(status_code=500, detail="Payment service unavailable")

    order_status = cf_data.get("order_status", "")

    if order_status == "PAID":
        if tx:
            plan_id = tx.get("planId", "focus")
            now_iso = datetime.now(timezone.utc).isoformat()
            expires = (datetime.now(timezone.utc) + timedelta(days=30)).isoformat()

            await db.payment_transactions.update_one(
                {"id": order_id},
                {"$set": {"status": "paid", "verifiedAt": now_iso}}
            )
            await db.users.update_one(
                {"_id": current_user["_id"]},
                {"$set": {"plan": plan_id, "planUpdatedAt": now_iso, "planExpiresAt": expires}}
            )

    return {"orderId": order_id, "status": order_status, "amount": cf_data.get("order_amount")}

@api_router.post("/cashfree/verify")
async def verify_payment_alias(orderId: str, current_user: dict = Depends(get_current_user)):
    return await verify_payment(orderId, current_user)

@api_router.post("/payment/webhook")
async def payment_webhook(request: Request):
    try:
        raw_body = await request.body()
        payload = json.loads(raw_body)
        event_type = payload.get("type", "")
        order_data = payload.get("data", {}).get("order", {})
        order_id = order_data.get("order_id", "")

        if event_type == "PAYMENT_SUCCESS_WEBHOOK" and order_id:
            tx = await db.payment_transactions.find_one({"id": order_id})
            if tx:
                now_iso = datetime.now(timezone.utc).isoformat()
                expires = (datetime.now(timezone.utc) + timedelta(days=30)).isoformat()
                await db.payment_transactions.update_one(
                    {"id": order_id},
                    {"$set": {"status": "paid", "verifiedAt": now_iso}}
                )
                await db.users.update_one(
                    {"_id": ObjectId(tx["userId"])},
                    {"$set": {"plan": tx["planId"], "planUpdatedAt": now_iso, "planExpiresAt": expires}}
                )
        return {"status": "received"}
    except Exception as e:
        logger.error(f"Webhook error: {e}")
        return {"status": "error"}

# ============ SUCCESS STORIES ============

@api_router.get("/success-stories")
async def get_success_stories():
    stories = [
        {
            "id": "1",
            "names": "Priya & Rahul",
            "location": "Mumbai",
            "story": "VivahSetu helped us find each other when our families were looking for the perfect match. The platform's focus on meaningful connections made all the difference.",
            "image": "https://images.pexels.com/photos/4307719/pexels-photo-4307719.jpeg?auto=compress&cs=tinysrgb&w=400",
        },
        {
            "id": "2",
            "names": "Ananya & Vikram",
            "location": "Delhi",
            "story": "What stood out about VivahSetu was the quality of profiles and the limited connection feature. It made us both take each match seriously.",
            "image": "https://images.pexels.com/photos/4307646/pexels-photo-4307646.jpeg?auto=compress&cs=tinysrgb&w=400",
        },
        {
            "id": "3",
            "names": "Meera & Karthik",
            "location": "Bangalore",
            "story": "The 15-day timer created a sense of urgency that made us communicate better. Within weeks, we knew we were meant to be together.",
            "image": "https://images.pexels.com/photos/3014856/pexels-photo-3014856.jpeg?auto=compress&cs=tinysrgb&w=400",
        },
    ]
    return {"stories": stories}

# ============ CASTE DATA ============

@api_router.get("/castes/{religion}")
async def get_castes(religion: str):
    return {"castes": CASTES_BY_RELIGION.get(religion, [])}

@api_router.get("/subcastes/{caste}")
async def get_subcastes(caste: str):
    if not caste:
        return {"subcastes": []}
    if caste in SUBCASTES_BY_CASTE:
        return {"subcastes": SUBCASTES_BY_CASTE[caste]}
    lowered = caste.strip().lower()
    for key, value in SUBCASTES_BY_CASTE.items():
        if key.lower() == lowered:
            return {"subcastes": value}
    return {"subcastes": ["Other"]}

# ============ HEALTH ============

@api_router.get("/")
async def root():
    return {"message": "VivahSetu API", "status": "ok"}

@api_router.get("/health")
async def health():
    return {"status": "healthy", "timestamp": datetime.now(timezone.utc).isoformat()}

# ============ PUSH NOTIFICATION TOKEN STORAGE ============

class FCMTokenInput(BaseModel):
    token: str
    platform: Optional[str] = None

@api_router.post("/notifications/register-token")
async def register_fcm_token(data: FCMTokenInput, current_user: dict = Depends(get_current_user)):
    await db.users.update_one(
        {"_id": current_user["_id"]},
        {"$set": {
            "fcmToken": data.token,
            "fcmPlatform": data.platform or "unknown",
            "fcmTokenUpdatedAt": datetime.now(timezone.utc).isoformat(),
        }}
    )
    return {"message": "Token registered"}

@api_router.post("/notifications/device-token")
async def register_device_token(data: FCMTokenInput, current_user: dict = Depends(get_current_user)):
    return await register_fcm_token(data, current_user)

@api_router.post("/notifications/digest")
async def create_notification_digest(current_user: dict = Depends(get_current_user)):
    created = await ensure_user_notification_digest(current_user)
    return {"message": "Digest queued", "created": created}

# ============ FEEDBACK ============

@api_router.post("/feedback")
@api_router.post("/feedback/report")
@api_router.post("/bug-report")
async def submit_feedback(data: FeedbackInput, current_user: dict = Depends(get_current_user)):
    category = (data.category or "feedback").strip().lower()
    if category not in {"feedback", "bug"}:
        category = "feedback"
    message = (data.message or "").strip()
    if len(message) < 5:
        raise HTTPException(status_code=400, detail="Please enter more details")
    now = datetime.now(timezone.utc).isoformat()
    doc = {
        "id": str(uuid.uuid4()),
        "userId": normalize_ref(current_user["_id"]),
        "userName": current_user.get("name", ""),
        "userEmail": current_user.get("email", ""),
        "category": category,
        "subject": (data.subject or "").strip(),
        "message": message,
        "screen": (data.screen or "").strip(),
        "status": "open",
        "createdAt": now,
    }
    await db.feedback.insert_one(doc)
    notification = {
        "id": str(uuid.uuid4()),
        "type": "feedback_received" if category == "feedback" else "bug_report_received",
        "message": "Thanks for your feedback. Our team will review it." if category == "feedback" else "Bug report received. We will investigate it.",
        "read": False,
        "createdAt": now,
    }
    await create_user_notification(current_user["_id"], notification, "notifications")
    doc.pop("_id", None)
    return {"message": "Submitted", "item": doc}

# ============ WEBSOCKET CHAT ============

from fastapi import WebSocket, WebSocketDisconnect

class ConnectionManager:
    def __init__(self):
        self.active: Dict[str, WebSocket] = {}

    async def connect(self, user_id: str, websocket: WebSocket):
        await websocket.accept()
        self.active[user_id] = websocket

    def disconnect(self, user_id: str):
        self.active.pop(user_id, None)

    async def send_to_user(self, user_id: str, message: dict):
        ws = self.active.get(user_id)
        if ws:
            try:
                await ws.send_json(message)
            except Exception:
                self.disconnect(user_id)

ws_manager = ConnectionManager()

@app.websocket("/ws/chat/{token}")
async def websocket_chat(websocket: WebSocket, token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if not user_id:
            await websocket.close(code=4001)
            return
    except JWTError:
        await websocket.close(code=4001)
        return

    await ws_manager.connect(user_id, websocket)
    try:
        while True:
            data = await websocket.receive_json()
            action = data.get("action")

            if action == "send_message":
                receiver_id = data.get("receiverId")
                content = data.get("content", "")
                if not receiver_id or not content:
                    continue

                msg_doc = {
                    "id": str(uuid.uuid4()),
                    "senderId": user_id,
                    "receiverId": receiver_id,
                    "content": content,
                    "read": False,
                    "createdAt": datetime.now(timezone.utc).isoformat()
                }
                await db.messages.insert_one(msg_doc)
                msg_doc.pop("_id", None)

                # Send to both sender and receiver
                await ws_manager.send_to_user(user_id, {"type": "new_message", "message": msg_doc})
                await ws_manager.send_to_user(receiver_id, {"type": "new_message", "message": msg_doc})
                sender = await find_user_by_ref(user_id)
                sender_name = (sender or {}).get("name", "VivaahSetu")
                await create_user_notification(
                    receiver_id,
                    {
                        "id": str(uuid.uuid4()),
                        "type": "chat_message",
                        "senderId": user_id,
                        "sender_id": user_id,
                        "fromUserName": sender_name,
                        "message": f"New message from {sender_name}",
                        "preview": content,
                        "read": False,
                        "createdAt": msg_doc["createdAt"],
                    },
                    f"chat:{user_id}",
                )

            elif action == "mark_read":
                partner_id = data.get("partnerId")
                if partner_id:
                    await db.messages.update_many(
                        {"senderId": partner_id, "receiverId": user_id, "read": False},
                        {"$set": {"read": True}}
                    )
                    await ws_manager.send_to_user(user_id, {"type": "messages_read", "partnerId": partner_id})

            elif action == "typing":
                receiver_id = data.get("receiverId")
                if receiver_id:
                    await ws_manager.send_to_user(receiver_id, {"type": "typing", "senderId": user_id})

    except WebSocketDisconnect:
        ws_manager.disconnect(user_id)
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        ws_manager.disconnect(user_id)

# ============ GOOGLE AUTH PROFILE COMPLETION ============

class GoogleProfileCompleteInput(BaseModel):
    name: str
    gender: str

@api_router.post("/auth/google-complete-profile")
async def google_complete_profile(data: GoogleProfileCompleteInput, current_user: dict = Depends(get_current_user)):
    await db.users.update_one(
        {"_id": current_user["_id"]},
        {"$set": {
            "name": data.name.strip(),
            "gender": data.gender,
            "profileComplete": False,
            "updatedAt": datetime.now(timezone.utc).isoformat()
        }}
    )
    updated = await db.users.find_one({"_id": current_user["_id"]})
    return {"user": serialize_user(updated)}

# Include router & middleware
app.include_router(api_router)
app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("shutdown")
async def shutdown_db_client():
    client.close()



