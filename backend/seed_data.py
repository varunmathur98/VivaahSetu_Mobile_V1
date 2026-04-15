import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
import certifi
from datetime import datetime
import os
from dotenv import load_dotenv
from pathlib import Path

ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# MongoDB connection
mongo_url = os.environ['MONGO_URL']
client = AsyncIOMotorClient(
    mongo_url,
    tls=True,
    tlsCAFile=certifi.where(),
    tlsAllowInvalidCertificates=True,
)
db = client[os.environ.get('DB_NAME', 'vivahsetu')]

async def seed_database():
    print("🌱 Seeding database...")
    
    # Clear existing data
    await db.users.delete_many({})
    await db.connections.delete_many({})
    await db.messages.delete_many({})
    print("✅ Cleared existing data")
    
    # Create sample users
    users = [
        {
            "email": "priya.sharma@example.com",
            "name": "Priya Sharma",
            "age": 26,
            "gender": "Female",
            "height": "5'4\"",
            "religion": "Hindu",
            "caste": "Brahmin",
            "motherTongue": "Hindi",
            "city": "Mumbai",
            "state": "Maharashtra",
            "education": "Masters",
            "occupation": "Software Engineer",
            "income": "10 - 15 Lakhs",
            "maritalStatus": "Never Married",
            "about": "Looking for a caring and understanding life partner.",
            "plan": "free",
            "profileComplete": True,
            "photos": [],
            "createdAt": datetime.utcnow(),
            "updatedAt": datetime.utcnow(),
        },
        {
            "email": "rahul.verma@example.com",
            "name": "Rahul Verma",
            "age": 28,
            "gender": "Male",
            "height": "5'10\"",
            "religion": "Hindu",
            "caste": "Kshatriya",
            "motherTongue": "Hindi",
            "city": "Delhi",
            "state": "Delhi",
            "education": "Bachelors",
            "occupation": "Business Analyst",
            "income": "7 - 10 Lakhs",
            "maritalStatus": "Never Married",
            "about": "Family-oriented person looking for a compatible partner.",
            "plan": "free",
            "profileComplete": True,
            "photos": [],
            "createdAt": datetime.utcnow(),
            "updatedAt": datetime.utcnow(),
        },
        {
            "email": "ananya.patel@example.com",
            "name": "Ananya Patel",
            "age": 25,
            "gender": "Female",
            "height": "5'3\"",
            "religion": "Hindu",
            "caste": "Patel",
            "motherTongue": "Gujarati",
            "city": "Ahmedabad",
            "state": "Gujarat",
            "education": "Bachelors",
            "occupation": "Teacher",
            "income": "5 - 7 Lakhs",
            "maritalStatus": "Never Married",
            "about": "Simple and traditional girl looking for a loving family.",
            "plan": "focus",
            "profileComplete": True,
            "photos": [],
            "createdAt": datetime.utcnow(),
            "updatedAt": datetime.utcnow(),
        },
        {
            "email": "vikram.singh@example.com",
            "name": "Vikram Singh",
            "age": 30,
            "gender": "Male",
            "height": "6'0\"",
            "religion": "Sikh",
            "motherTongue": "Punjabi",
            "city": "Chandigarh",
            "state": "Punjab",
            "education": "Masters",
            "occupation": "Doctor",
            "income": "15 - 20 Lakhs",
            "maritalStatus": "Never Married",
            "about": "Medical professional seeking an educated and independent partner.",
            "plan": "commit",
            "profileComplete": True,
            "photos": [],
            "createdAt": datetime.utcnow(),
            "updatedAt": datetime.utcnow(),
        },
        {
            "email": "sneha.reddy@example.com",
            "name": "Sneha Reddy",
            "age": 27,
            "gender": "Female",
            "height": "5'5\"",
            "religion": "Hindu",
            "caste": "Reddy",
            "motherTongue": "Telugu",
            "city": "Hyderabad",
            "state": "Telangana",
            "education": "Masters",
            "occupation": "Data Scientist",
            "income": "15 - 20 Lakhs",
            "maritalStatus": "Never Married",
            "about": "Tech enthusiast looking for someone who values both career and family.",
            "plan": "free",
            "profileComplete": True,
            "photos": [],
            "createdAt": datetime.utcnow(),
            "updatedAt": datetime.utcnow(),
        },
        {
            "email": "arjun.nair@example.com",
            "name": "Arjun Nair",
            "age": 29,
            "gender": "Male",
            "height": "5'9\"",
            "religion": "Hindu",
            "caste": "Nair",
            "motherTongue": "Malayalam",
            "city": "Kochi",
            "state": "Kerala",
            "education": "Bachelors",
            "occupation": "Chartered Accountant",
            "income": "10 - 15 Lakhs",
            "maritalStatus": "Never Married",
            "about": "Looking for a simple and understanding life partner.",
            "plan": "free",
            "profileComplete": True,
            "photos": [],
            "createdAt": datetime.utcnow(),
            "updatedAt": datetime.utcnow(),
        },
    ]
    
    result = await db.users.insert_many(users)
    print(f"✅ Created {len(result.inserted_ids)} sample users")
    
    print("\n🎉 Database seeding completed!")
    print("\n📝 Sample Users:")
    for i, user in enumerate(users):
        print(f"{i+1}. {user['name']} ({user['gender']}, {user['age']}) - {user['city']}, {user['state']}")
    
    client.close()

if __name__ == "__main__":
    asyncio.run(seed_database())
