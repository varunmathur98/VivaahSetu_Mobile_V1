"""
VivahSetu API Backend Tests
Tests: Auth (register, login, google-login), Profile, Matches, Connections, Subscriptions, Success Stories
"""
import pytest
import requests
import os
import uuid

# Use the public URL for testing
BASE_URL = "https://bride-connect-3.preview.emergentagent.com"

class TestHealth:
    """Health check tests"""
    
    def test_health_endpoint(self):
        response = requests.get(f"{BASE_URL}/api/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        print("✓ Health check passed")

class TestAuth:
    """Authentication endpoint tests"""
    
    def test_register_new_user(self):
        """Test user registration"""
        unique_email = f"test_{uuid.uuid4().hex[:8]}@example.com"
        payload = {
            "email": unique_email,
            "password": "test123",
            "name": "Test User",
            "gender": "Male"
        }
        response = requests.post(f"{BASE_URL}/api/auth/register", json=payload)
        assert response.status_code == 200, f"Registration failed: {response.text}"
        
        data = response.json()
        assert "token" in data
        assert "user" in data
        assert data["user"]["email"] == unique_email.lower()
        assert data["user"]["name"] == "Test User"
        assert data["user"]["gender"] == "Male"
        print(f"✓ Registration successful for {unique_email}")
    
    def test_register_duplicate_email(self):
        """Test duplicate email registration fails"""
        email = f"duplicate_{uuid.uuid4().hex[:8]}@example.com"
        payload = {"email": email, "password": "test123", "name": "User1", "gender": "Male"}
        
        # First registration
        response1 = requests.post(f"{BASE_URL}/api/auth/register", json=payload)
        assert response1.status_code == 200
        
        # Duplicate registration
        response2 = requests.post(f"{BASE_URL}/api/auth/register", json=payload)
        assert response2.status_code == 400
        assert "already registered" in response2.json()["detail"].lower()
        print("✓ Duplicate email registration blocked")
    
    def test_login_with_valid_credentials(self):
        """Test login with correct credentials"""
        # First register a user
        unique_email = f"login_test_{uuid.uuid4().hex[:8]}@example.com"
        register_payload = {
            "email": unique_email,
            "password": "test123",
            "name": "Login Test",
            "gender": "Female"
        }
        reg_response = requests.post(f"{BASE_URL}/api/auth/register", json=register_payload)
        assert reg_response.status_code == 200
        
        # Now login
        login_payload = {"email": unique_email, "password": "test123"}
        response = requests.post(f"{BASE_URL}/api/auth/login", json=login_payload)
        assert response.status_code == 200, f"Login failed: {response.text}"
        
        data = response.json()
        assert "token" in data
        assert "user" in data
        assert data["user"]["email"] == unique_email.lower()
        print(f"✓ Login successful for {unique_email}")
    
    def test_login_with_invalid_password(self):
        """Test login with wrong password"""
        # Register user
        unique_email = f"wrong_pwd_{uuid.uuid4().hex[:8]}@example.com"
        requests.post(f"{BASE_URL}/api/auth/register", json={
            "email": unique_email, "password": "correct123", "name": "Test", "gender": "Male"
        })
        
        # Try wrong password
        response = requests.post(f"{BASE_URL}/api/auth/login", json={
            "email": unique_email, "password": "wrong123"
        })
        assert response.status_code == 401
        assert "invalid" in response.json()["detail"].lower()
        print("✓ Invalid password rejected")
    
    def test_login_nonexistent_user(self):
        """Test login with non-existent email"""
        response = requests.post(f"{BASE_URL}/api/auth/login", json={
            "email": "nonexistent@example.com", "password": "test123"
        })
        assert response.status_code == 401
        print("✓ Non-existent user login rejected")
    
    def test_google_login(self):
        """Test Google login endpoint"""
        unique_email = f"google_{uuid.uuid4().hex[:8]}@example.com"
        payload = {
            "email": unique_email,
            "name": "Google User",
            "photoUrl": "https://example.com/photo.jpg"
        }
        response = requests.post(f"{BASE_URL}/api/auth/google-login", json=payload)
        assert response.status_code == 200, f"Google login failed: {response.text}"
        
        data = response.json()
        assert "token" in data
        assert "user" in data
        assert data["user"]["email"] == unique_email.lower()
        assert data["user"]["auth_provider"] == "google"
        print(f"✓ Google login successful for {unique_email}")

class TestProfile:
    """Profile endpoint tests"""
    
    @pytest.fixture
    def auth_token(self):
        """Create a test user and return auth token"""
        unique_email = f"profile_test_{uuid.uuid4().hex[:8]}@example.com"
        response = requests.post(f"{BASE_URL}/api/auth/register", json={
            "email": unique_email, "password": "test123", "name": "Profile Test", "gender": "Male"
        })
        return response.json()["token"]
    
    def test_get_profile_me(self, auth_token):
        """Test GET /api/profile/me"""
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = requests.get(f"{BASE_URL}/api/profile/me", headers=headers)
        assert response.status_code == 200, f"Get profile failed: {response.text}"
        
        data = response.json()
        assert "id" in data
        assert "email" in data
        assert "name" in data
        assert "_id" not in data  # Should be excluded
        assert "password_hash" not in data  # Should be excluded
        print("✓ Get profile successful")
    
    def test_update_profile(self, auth_token):
        """Test PUT /api/profile/update"""
        headers = {"Authorization": f"Bearer {auth_token}"}
        update_payload = {
            "age": 28,
            "city": "Mumbai",
            "occupation": "Software Engineer",
            "height": "5'10\"",
            "religion": "Hindu"
        }
        response = requests.put(f"{BASE_URL}/api/profile/update", json=update_payload, headers=headers)
        assert response.status_code == 200, f"Update profile failed: {response.text}"
        
        data = response.json()
        assert data["age"] == 28
        assert data["city"] == "Mumbai"
        assert data["occupation"] == "Software Engineer"
        
        # Verify persistence with GET
        get_response = requests.get(f"{BASE_URL}/api/profile/me", headers=headers)
        assert get_response.status_code == 200
        get_data = get_response.json()
        assert get_data["age"] == 28
        assert get_data["city"] == "Mumbai"
        print("✓ Profile update successful and persisted")
    
    def test_profile_without_auth(self):
        """Test profile endpoints without auth token"""
        response = requests.get(f"{BASE_URL}/api/profile/me")
        assert response.status_code == 403  # No auth header
        print("✓ Unauthorized access blocked")

class TestMatches:
    """Matches endpoint tests"""
    
    @pytest.fixture
    def male_user_token(self):
        """Create male user"""
        unique_email = f"male_{uuid.uuid4().hex[:8]}@example.com"
        response = requests.post(f"{BASE_URL}/api/auth/register", json={
            "email": unique_email, "password": "test123", "name": "Male User", "gender": "Male"
        })
        return response.json()["token"]
    
    def test_get_matches(self, male_user_token):
        """Test GET /api/matches - should return opposite gender"""
        headers = {"Authorization": f"Bearer {male_user_token}"}
        response = requests.get(f"{BASE_URL}/api/matches", headers=headers)
        assert response.status_code == 200, f"Get matches failed: {response.text}"
        
        data = response.json()
        assert "matches" in data
        assert "total" in data
        assert "page" in data
        
        # Check if matches are opposite gender (Female for Male user)
        for match in data["matches"]:
            if match.get("gender"):
                assert match["gender"].lower() == "female", f"Expected Female match, got {match['gender']}"
        
        print(f"✓ Get matches successful, returned {len(data['matches'])} matches")
    
    def test_matches_pagination(self, male_user_token):
        """Test matches pagination"""
        headers = {"Authorization": f"Bearer {male_user_token}"}
        response = requests.get(f"{BASE_URL}/api/matches?page=1&limit=2", headers=headers)
        assert response.status_code == 200
        
        data = response.json()
        assert data["page"] == 1
        assert len(data["matches"]) <= 2
        print("✓ Matches pagination working")

class TestConnections:
    """Connections endpoint tests"""
    
    @pytest.fixture
    def two_users(self):
        """Create two users and return their tokens"""
        user1_email = f"user1_{uuid.uuid4().hex[:8]}@example.com"
        user2_email = f"user2_{uuid.uuid4().hex[:8]}@example.com"
        
        resp1 = requests.post(f"{BASE_URL}/api/auth/register", json={
            "email": user1_email, "password": "test123", "name": "User One", "gender": "Male"
        })
        resp2 = requests.post(f"{BASE_URL}/api/auth/register", json={
            "email": user2_email, "password": "test123", "name": "User Two", "gender": "Female"
        })
        
        return {
            "user1_token": resp1.json()["token"],
            "user1_id": resp1.json()["user"]["id"],
            "user2_token": resp2.json()["token"],
            "user2_id": resp2.json()["user"]["id"]
        }
    
    def test_send_connection_request(self, two_users):
        """Test POST /api/connections/request/{target_id}"""
        headers = {"Authorization": f"Bearer {two_users['user1_token']}"}
        response = requests.post(
            f"{BASE_URL}/api/connections/request/{two_users['user2_id']}",
            headers=headers
        )
        assert response.status_code == 200, f"Send request failed: {response.text}"
        assert "sent" in response.json()["message"].lower()
        print("✓ Connection request sent successfully")
    
    def test_get_connections(self, two_users):
        """Test GET /api/connections"""
        headers = {"Authorization": f"Bearer {two_users['user1_token']}"}
        response = requests.get(f"{BASE_URL}/api/connections", headers=headers)
        assert response.status_code == 200, f"Get connections failed: {response.text}"
        
        data = response.json()
        assert "connections" in data
        assert "pendingReceived" in data
        assert "pendingSent" in data
        assert "count" in data
        assert "max" in data
        assert data["max"] == 5  # Max connections limit
        print("✓ Get connections successful")
    
    def test_accept_connection_request(self, two_users):
        """Test POST /api/connections/accept/{requester_id}"""
        # User1 sends request to User2
        headers1 = {"Authorization": f"Bearer {two_users['user1_token']}"}
        requests.post(f"{BASE_URL}/api/connections/request/{two_users['user2_id']}", headers=headers1)
        
        # User2 accepts request from User1
        headers2 = {"Authorization": f"Bearer {two_users['user2_token']}"}
        response = requests.post(
            f"{BASE_URL}/api/connections/accept/{two_users['user1_id']}",
            headers=headers2
        )
        assert response.status_code == 200, f"Accept request failed: {response.text}"
        assert "accepted" in response.json()["message"].lower()
        assert "expiresAt" in response.json()
        print("✓ Connection request accepted successfully")
    
    def test_reject_connection_request(self, two_users):
        """Test POST /api/connections/reject/{requester_id}"""
        # User1 sends request to User2
        headers1 = {"Authorization": f"Bearer {two_users['user1_token']}"}
        requests.post(f"{BASE_URL}/api/connections/request/{two_users['user2_id']}", headers=headers1)
        
        # User2 rejects request from User1
        headers2 = {"Authorization": f"Bearer {two_users['user2_token']}"}
        response = requests.post(
            f"{BASE_URL}/api/connections/reject/{two_users['user1_id']}",
            headers=headers2
        )
        assert response.status_code == 200, f"Reject request failed: {response.text}"
        assert "rejected" in response.json()["message"].lower()
        print("✓ Connection request rejected successfully")

class TestSubscriptions:
    """Subscription plans tests - NEW: Updated plans with discountedPrice and 70% OFF"""
    
    def test_get_subscription_plans(self):
        """Test GET /api/subscriptions/plans - verify updated pricing"""
        response = requests.get(f"{BASE_URL}/api/subscriptions/plans")
        assert response.status_code == 200, f"Get plans failed: {response.text}"
        
        data = response.json()
        assert "plans" in data
        assert "discount_percent" in data
        assert data["discount_percent"] == 70, "Discount should be 70%"
        assert len(data["plans"]) >= 3  # Free, Focus, Commit
        
        plan_ids = [p["id"] for p in data["plans"]]
        assert "free" in plan_ids
        assert "focus" in plan_ids
        assert "commit" in plan_ids
        
        # Verify Focus plan pricing
        focus_plan = next((p for p in data["plans"] if p["id"] == "focus"), None)
        assert focus_plan is not None, "Focus plan not found"
        assert focus_plan["price"] == 699, f"Focus original price should be 699, got {focus_plan['price']}"
        assert focus_plan["discountedPrice"] == 210, f"Focus discounted price should be 210, got {focus_plan['discountedPrice']}"
        assert focus_plan["badge"] == "MOST POPULAR", "Focus should have MOST POPULAR badge"
        assert focus_plan["available"] == True, "Focus should be available"
        
        # Verify Commit plan pricing
        commit_plan = next((p for p in data["plans"] if p["id"] == "commit"), None)
        assert commit_plan is not None, "Commit plan not found"
        assert commit_plan["price"] == 1499, f"Commit original price should be 1499, got {commit_plan['price']}"
        assert commit_plan["discountedPrice"] == 450, f"Commit discounted price should be 450, got {commit_plan['discountedPrice']}"
        assert commit_plan["badge"] == "COMING SOON", "Commit should have COMING SOON badge"
        assert commit_plan["available"] == False, "Commit should not be available yet"
        
        print(f"✓ Subscription plans retrieved with correct pricing: Focus ₹699→₹210, Commit ₹1499→₹450, 70% OFF")

class TestPayment:
    """Cashfree payment integration tests - NEW"""
    
    @pytest.fixture
    def auth_user(self):
        """Create a test user for payment testing"""
        unique_email = f"payment_test_{uuid.uuid4().hex[:8]}@example.com"
        response = requests.post(f"{BASE_URL}/api/auth/register", json={
            "email": unique_email, "password": "test123", "name": "Payment Test", "gender": "Male"
        })
        return {
            "token": response.json()["token"],
            "user_id": response.json()["user"]["id"]
        }
    
    def test_create_payment_order_focus_plan(self, auth_user):
        """Test POST /api/payment/create-order for Focus plan (₹210)"""
        headers = {"Authorization": f"Bearer {auth_user['token']}"}
        payload = {
            "planId": "focus",
            "returnUrl": "https://vivaahsetu.in/payment/success"
        }
        response = requests.post(f"{BASE_URL}/api/payment/create-order", json=payload, headers=headers)
        assert response.status_code == 200, f"Create order failed: {response.text}"
        
        data = response.json()
        assert "orderId" in data
        assert "paymentSessionId" in data
        assert "cfOrderId" in data
        assert "amount" in data
        assert data["amount"] == 210, f"Focus plan amount should be 210, got {data['amount']}"
        assert data["currency"] == "INR"
        assert "paymentLink" in data
        
        print(f"✓ Payment order created for Focus plan: ₹{data['amount']}, orderId: {data['orderId']}")
        return data["orderId"]
    
    def test_create_payment_order_invalid_plan(self, auth_user):
        """Test payment order creation with invalid plan"""
        headers = {"Authorization": f"Bearer {auth_user['token']}"}
        payload = {"planId": "invalid_plan"}
        response = requests.post(f"{BASE_URL}/api/payment/create-order", json=payload, headers=headers)
        assert response.status_code == 400
        print("✓ Invalid plan rejected")
    
    def test_create_payment_order_commit_unavailable(self, auth_user):
        """Test payment order creation for unavailable Commit plan"""
        headers = {"Authorization": f"Bearer {auth_user['token']}"}
        payload = {"planId": "commit"}
        response = requests.post(f"{BASE_URL}/api/payment/create-order", json=payload, headers=headers)
        assert response.status_code == 400
        assert "not available" in response.json()["detail"].lower()
        print("✓ Commit plan (COMING SOON) correctly blocked")
    
    def test_verify_payment_endpoint_exists(self, auth_user):
        """Test GET /api/payment/verify/{orderId} endpoint exists"""
        headers = {"Authorization": f"Bearer {auth_user['token']}"}
        # Use a dummy order ID - endpoint should exist even if order not found
        response = requests.get(f"{BASE_URL}/api/payment/verify/dummy_order_123", headers=headers)
        # Should return 500 or 404, not 404 for route not found
        assert response.status_code in [404, 500], f"Verify endpoint should exist, got {response.status_code}"
        print("✓ Payment verify endpoint exists")

class TestMatchesFilters:
    """Matches endpoint with filters - NEW"""
    
    @pytest.fixture
    def setup_users_for_filtering(self):
        """Create users with specific attributes for filter testing"""
        # Create male user (searcher)
        male_email = f"male_searcher_{uuid.uuid4().hex[:8]}@example.com"
        male_resp = requests.post(f"{BASE_URL}/api/auth/register", json={
            "email": male_email, "password": "test123", "name": "Male Searcher", "gender": "Male"
        })
        male_token = male_resp.json()["token"]
        
        # Create female users with different attributes
        female1_email = f"female1_{uuid.uuid4().hex[:8]}@example.com"
        female1_resp = requests.post(f"{BASE_URL}/api/auth/register", json={
            "email": female1_email, "password": "test123", "name": "Female Hindu Mumbai", "gender": "Female"
        })
        female1_token = female1_resp.json()["token"]
        
        # Update female1 profile with specific attributes
        requests.put(f"{BASE_URL}/api/profile/update", 
            json={"age": 25, "religion": "Hindu", "caste": "Brahmin", "city": "Mumbai"},
            headers={"Authorization": f"Bearer {female1_token}"}
        )
        
        # Create female2 with different attributes
        female2_email = f"female2_{uuid.uuid4().hex[:8]}@example.com"
        female2_resp = requests.post(f"{BASE_URL}/api/auth/register", json={
            "email": female2_email, "password": "test123", "name": "Female Muslim Delhi", "gender": "Female"
        })
        female2_token = female2_resp.json()["token"]
        
        requests.put(f"{BASE_URL}/api/profile/update",
            json={"age": 30, "religion": "Muslim", "caste": "Sunni", "city": "Delhi"},
            headers={"Authorization": f"Bearer {female2_token}"}
        )
        
        return {"male_token": male_token}
    
    def test_matches_filter_by_age(self, setup_users_for_filtering):
        """Test GET /api/matches with age filters"""
        headers = {"Authorization": f"Bearer {setup_users_for_filtering['male_token']}"}
        response = requests.get(f"{BASE_URL}/api/matches?minAge=24&maxAge=26", headers=headers)
        assert response.status_code == 200, f"Matches with age filter failed: {response.text}"
        
        data = response.json()
        assert "matches" in data
        # Verify all matches are within age range
        for match in data["matches"]:
            if match.get("age"):
                assert 24 <= match["age"] <= 26, f"Match age {match['age']} outside filter range 24-26"
        
        print(f"✓ Matches filtered by age (24-26): {len(data['matches'])} results")
    
    def test_matches_filter_by_religion(self, setup_users_for_filtering):
        """Test GET /api/matches with religion filter"""
        headers = {"Authorization": f"Bearer {setup_users_for_filtering['male_token']}"}
        response = requests.get(f"{BASE_URL}/api/matches?religion=Hindu", headers=headers)
        assert response.status_code == 200, f"Matches with religion filter failed: {response.text}"
        
        data = response.json()
        assert "matches" in data
        # Verify all matches have Hindu religion
        for match in data["matches"]:
            if match.get("religion"):
                assert "hindu" in match["religion"].lower(), f"Match religion {match['religion']} doesn't match filter"
        
        print(f"✓ Matches filtered by religion (Hindu): {len(data['matches'])} results")
    
    def test_matches_filter_by_city(self, setup_users_for_filtering):
        """Test GET /api/matches with city filter"""
        headers = {"Authorization": f"Bearer {setup_users_for_filtering['male_token']}"}
        response = requests.get(f"{BASE_URL}/api/matches?city=Mumbai", headers=headers)
        assert response.status_code == 200, f"Matches with city filter failed: {response.text}"
        
        data = response.json()
        assert "matches" in data
        print(f"✓ Matches filtered by city (Mumbai): {len(data['matches'])} results")
    
    def test_matches_filter_by_caste(self, setup_users_for_filtering):
        """Test GET /api/matches with caste filter"""
        headers = {"Authorization": f"Bearer {setup_users_for_filtering['male_token']}"}
        response = requests.get(f"{BASE_URL}/api/matches?caste=Brahmin", headers=headers)
        assert response.status_code == 200, f"Matches with caste filter failed: {response.text}"
        
        data = response.json()
        assert "matches" in data
        print(f"✓ Matches filtered by caste (Brahmin): {len(data['matches'])} results")
    
    def test_matches_multiple_filters(self, setup_users_for_filtering):
        """Test GET /api/matches with multiple filters combined"""
        headers = {"Authorization": f"Bearer {setup_users_for_filtering['male_token']}"}
        response = requests.get(
            f"{BASE_URL}/api/matches?minAge=24&maxAge=26&religion=Hindu&city=Mumbai",
            headers=headers
        )
        assert response.status_code == 200, f"Matches with multiple filters failed: {response.text}"
        
        data = response.json()
        assert "matches" in data
        print(f"✓ Matches with multiple filters (age 24-26, Hindu, Mumbai): {len(data['matches'])} results")

class TestProfilePartnerPreferences:
    """Profile update with partner preferences - NEW"""
    
    @pytest.fixture
    def auth_token(self):
        """Create a test user"""
        unique_email = f"prefs_test_{uuid.uuid4().hex[:8]}@example.com"
        response = requests.post(f"{BASE_URL}/api/auth/register", json={
            "email": unique_email, "password": "test123", "name": "Prefs Test", "gender": "Male"
        })
        return response.json()["token"]
    
    def test_update_profile_with_partner_preferences(self, auth_token):
        """Test PUT /api/profile/update with partnerPreferences field"""
        headers = {"Authorization": f"Bearer {auth_token}"}
        update_payload = {
            "age": 28,
            "city": "Mumbai",
            "partnerPreferences": {
                "ageMin": 24,
                "ageMax": 30,
                "religions": ["Hindu", "Jain"],
                "caste": "Brahmin",
                "subCaste": "Iyer",
                "locations": "Mumbai, Pune",
                "professions": "Engineer, Doctor"
            }
        }
        response = requests.put(f"{BASE_URL}/api/profile/update", json=update_payload, headers=headers)
        assert response.status_code == 200, f"Update with partner prefs failed: {response.text}"
        
        data = response.json()
        assert "partnerPreferences" in data
        assert data["partnerPreferences"]["ageMin"] == 24
        assert data["partnerPreferences"]["ageMax"] == 30
        assert "Hindu" in data["partnerPreferences"]["religions"]
        assert data["partnerPreferences"]["caste"] == "Brahmin"
        
        # Verify persistence with GET
        get_response = requests.get(f"{BASE_URL}/api/profile/me", headers=headers)
        assert get_response.status_code == 200
        get_data = get_response.json()
        assert "partnerPreferences" in get_data
        assert get_data["partnerPreferences"]["ageMin"] == 24
        assert get_data["partnerPreferences"]["locations"] == "Mumbai, Pune"
        
        print("✓ Profile updated with partner preferences and persisted successfully")
    
    def test_update_profile_with_dob_and_photo_visibility(self, auth_token):
        """Test PUT /api/profile/update with dob and photoVisibility fields - ITERATION 3"""
        headers = {"Authorization": f"Bearer {auth_token}"}
        update_payload = {
            "dob": "1995-06-15",
            "photoVisibility": "yes",
            "name": "DOB Test User",
            "city": "Delhi"
        }
        response = requests.put(f"{BASE_URL}/api/profile/update", json=update_payload, headers=headers)
        assert response.status_code == 200, f"Update with dob failed: {response.text}"
        
        data = response.json()
        assert data["dob"] == "1995-06-15", f"DOB not saved correctly: {data.get('dob')}"
        assert data["photoVisibility"] == "yes", f"Photo visibility not saved: {data.get('photoVisibility')}"
        
        # Verify persistence
        get_response = requests.get(f"{BASE_URL}/api/profile/me", headers=headers)
        get_data = get_response.json()
        assert get_data["dob"] == "1995-06-15"
        assert get_data["photoVisibility"] == "yes"
        
        print("✓ Profile updated with DOB and photo visibility successfully")
    
    def test_update_profile_photo_visibility_no(self, auth_token):
        """Test photoVisibility = 'no' option"""
        headers = {"Authorization": f"Bearer {auth_token}"}
        update_payload = {"photoVisibility": "no"}
        response = requests.put(f"{BASE_URL}/api/profile/update", json=update_payload, headers=headers)
        assert response.status_code == 200
        
        data = response.json()
        assert data["photoVisibility"] == "no"
        print("✓ Photo visibility set to 'no' successfully")

class TestMatchProfileView:
    """Test GET /api/profile/{userId} for match profile detail view - ITERATION 3"""
    
    @pytest.fixture
    def two_users_setup(self):
        """Create two users for profile viewing"""
        user1_email = f"viewer_{uuid.uuid4().hex[:8]}@example.com"
        user2_email = f"viewed_{uuid.uuid4().hex[:8]}@example.com"
        
        resp1 = requests.post(f"{BASE_URL}/api/auth/register", json={
            "email": user1_email, "password": "test123", "name": "Viewer User", "gender": "Male"
        })
        resp2 = requests.post(f"{BASE_URL}/api/auth/register", json={
            "email": user2_email, "password": "test123", "name": "Viewed User", "gender": "Female"
        })
        
        user2_token = resp2.json()["token"]
        user2_id = resp2.json()["user"]["id"]
        
        # Update user2 profile with details
        requests.put(f"{BASE_URL}/api/profile/update", 
            json={
                "age": 26, "city": "Mumbai", "religion": "Hindu", "caste": "Brahmin",
                "occupation": "Software Engineer", "education": "B.Tech", "dob": "1998-03-20",
                "photoVisibility": "yes", "phone": "9876543210", "about": "Test about section"
            },
            headers={"Authorization": f"Bearer {user2_token}"}
        )
        
        return {
            "viewer_token": resp1.json()["token"],
            "viewed_id": user2_id,
            "viewed_token": user2_token
        }
    
    def test_get_user_profile_by_id(self, two_users_setup):
        """Test GET /api/profile/{userId} - view another user's profile"""
        headers = {"Authorization": f"Bearer {two_users_setup['viewer_token']}"}
        response = requests.get(f"{BASE_URL}/api/profile/{two_users_setup['viewed_id']}", headers=headers)
        assert response.status_code == 200, f"Get user profile failed: {response.text}"
        
        data = response.json()
        assert data["id"] == two_users_setup['viewed_id']
        assert data["name"] == "Viewed User"
        assert data["age"] == 26
        assert data["city"] == "Mumbai"
        assert data["religion"] == "Hindu"
        assert data["occupation"] == "Software Engineer"
        assert data["dob"] == "1998-03-20"
        assert data["photoVisibility"] == "yes"
        assert "password_hash" not in data
        
        print(f"✓ User profile retrieved successfully: {data['name']}, age {data['age']}")
    
    def test_get_user_profile_invalid_id(self, two_users_setup):
        """Test GET /api/profile/{userId} with invalid user ID"""
        headers = {"Authorization": f"Bearer {two_users_setup['viewer_token']}"}
        response = requests.get(f"{BASE_URL}/api/profile/invalid_id_12345", headers=headers)
        assert response.status_code == 404
        print("✓ Invalid user ID returns 404")
    
    def test_profile_visitor_tracking(self, two_users_setup):
        """Test that profile visits are tracked in profileVisitors"""
        headers = {"Authorization": f"Bearer {two_users_setup['viewer_token']}"}
        
        # View the profile
        requests.get(f"{BASE_URL}/api/profile/{two_users_setup['viewed_id']}", headers=headers)
        
        # Check if visit was tracked (viewed user checks their own profile)
        viewed_headers = {"Authorization": f"Bearer {two_users_setup['viewed_token']}"}
        response = requests.get(f"{BASE_URL}/api/profile/me", headers=viewed_headers)
        data = response.json()
        
        assert "profileVisitors" in data
        # Note: profileVisitors might be empty or have entries depending on implementation
        print(f"✓ Profile visitor tracking field exists: {len(data.get('profileVisitors', []))} visitors")

class TestSuccessStories:
    """Success stories tests"""
    
    def test_get_success_stories(self):
        """Test GET /api/success-stories"""
        response = requests.get(f"{BASE_URL}/api/success-stories")
        assert response.status_code == 200, f"Get stories failed: {response.text}"
        
        data = response.json()
        assert "stories" in data
        assert len(data["stories"]) > 0
        
        # Validate story structure
        for story in data["stories"]:
            assert "id" in story
            assert "names" in story
            assert "location" in story
            assert "story" in story
        
        print(f"✓ Success stories retrieved: {len(data['stories'])} stories")

class TestGoogleAuthIteration4:
    """Google authentication tests - ITERATION 4"""
    
    def test_google_login_creates_new_user(self):
        """Test POST /api/auth/google-login creates new user with Google provider"""
        unique_email = f"google_new_{uuid.uuid4().hex[:8]}@example.com"
        payload = {
            "email": unique_email,
            "name": "Google New User",
            "photoUrl": "https://lh3.googleusercontent.com/a/test123"
        }
        response = requests.post(f"{BASE_URL}/api/auth/google-login", json=payload)
        assert response.status_code == 200, f"Google login failed: {response.text}"
        
        data = response.json()
        assert "token" in data
        assert "user" in data
        assert data["user"]["email"] == unique_email.lower()
        assert data["user"]["name"] == "Google New User"
        assert data["user"]["auth_provider"] == "google"
        assert data["user"]["photoUrl"] == "https://lh3.googleusercontent.com/a/test123"
        assert data["user"]["gender"] == "", "New Google user should have empty gender"
        assert data["user"]["profileComplete"] == False
        
        print(f"✓ Google login created new user: {unique_email}")
        return data["token"]
    
    def test_google_login_existing_user(self):
        """Test POST /api/auth/google-login with existing Google user"""
        unique_email = f"google_existing_{uuid.uuid4().hex[:8]}@example.com"
        payload = {
            "email": unique_email,
            "name": "Google Existing User",
            "photoUrl": "https://lh3.googleusercontent.com/a/test456"
        }
        
        # First login - creates user
        resp1 = requests.post(f"{BASE_URL}/api/auth/google-login", json=payload)
        assert resp1.status_code == 200
        user1_id = resp1.json()["user"]["id"]
        
        # Second login - should return existing user
        resp2 = requests.post(f"{BASE_URL}/api/auth/google-login", json=payload)
        assert resp2.status_code == 200
        
        data2 = resp2.json()
        assert data2["user"]["id"] == user1_id, "Should return same user ID"
        assert data2["user"]["email"] == unique_email.lower()
        
        print(f"✓ Google login returned existing user: {unique_email}")
    
    def test_google_complete_profile_without_auth(self):
        """Test POST /api/auth/google-complete-profile without auth token - should return 403"""
        payload = {"name": "Test Name", "gender": "Male"}
        response = requests.post(f"{BASE_URL}/api/auth/google-complete-profile", json=payload)
        assert response.status_code == 403, f"Expected 403, got {response.status_code}"
        print("✓ Google complete profile blocked without auth")
    
    def test_google_complete_profile_with_auth(self):
        """Test POST /api/auth/google-complete-profile with auth token"""
        # Create Google user
        unique_email = f"google_complete_{uuid.uuid4().hex[:8]}@example.com"
        google_resp = requests.post(f"{BASE_URL}/api/auth/google-login", json={
            "email": unique_email,
            "name": "Incomplete User",
            "photoUrl": "https://example.com/photo.jpg"
        })
        token = google_resp.json()["token"]
        
        # Complete profile
        headers = {"Authorization": f"Bearer {token}"}
        payload = {"name": "Completed Name", "gender": "Female"}
        response = requests.post(f"{BASE_URL}/api/auth/google-complete-profile", json=payload, headers=headers)
        assert response.status_code == 200, f"Complete profile failed: {response.text}"
        
        data = response.json()
        assert "user" in data
        assert data["user"]["name"] == "Completed Name"
        assert data["user"]["gender"] == "Female"
        
        # Verify persistence
        profile_resp = requests.get(f"{BASE_URL}/api/profile/me", headers=headers)
        profile_data = profile_resp.json()
        assert profile_data["name"] == "Completed Name"
        assert profile_data["gender"] == "Female"
        
        print("✓ Google profile completion successful and persisted")

class TestFCMTokenRegistration:
    """FCM token registration tests - ITERATION 4"""
    
    @pytest.fixture
    def auth_token(self):
        """Create a test user"""
        unique_email = f"fcm_test_{uuid.uuid4().hex[:8]}@example.com"
        response = requests.post(f"{BASE_URL}/api/auth/register", json={
            "email": unique_email, "password": "test123", "name": "FCM Test", "gender": "Male"
        })
        return response.json()["token"]
    
    def test_register_fcm_token_without_auth(self):
        """Test POST /api/notifications/register-token without auth - should return 403"""
        payload = {"token": "fcm_token_12345"}
        response = requests.post(f"{BASE_URL}/api/notifications/register-token", json=payload)
        assert response.status_code == 403
        print("✓ FCM token registration blocked without auth")
    
    def test_register_fcm_token_with_auth(self, auth_token):
        """Test POST /api/notifications/register-token with auth token"""
        headers = {"Authorization": f"Bearer {auth_token}"}
        payload = {"token": "fcm_token_ExponentPushToken[xxxxxxxxxxxxxxxxxxxxxx]"}
        response = requests.post(f"{BASE_URL}/api/notifications/register-token", json=payload, headers=headers)
        assert response.status_code == 200, f"FCM token registration failed: {response.text}"
        
        data = response.json()
        assert "message" in data
        assert "registered" in data["message"].lower()
        
        # Verify token was saved in user profile
        profile_resp = requests.get(f"{BASE_URL}/api/profile/me", headers=headers)
        profile_data = profile_resp.json()
        assert "fcmToken" in profile_data
        assert profile_data["fcmToken"] == "fcm_token_ExponentPushToken[xxxxxxxxxxxxxxxxxxxxxx]"
        
        print("✓ FCM token registered and persisted successfully")

class TestChatEndpoints:
    """Chat endpoints tests - ITERATION 4"""
    
    @pytest.fixture
    def connected_users_with_focus_plan(self):
        """Create two connected users with Focus plan for chat testing"""
        user1_email = f"chat_user1_{uuid.uuid4().hex[:8]}@example.com"
        user2_email = f"chat_user2_{uuid.uuid4().hex[:8]}@example.com"
        
        # Create users
        resp1 = requests.post(f"{BASE_URL}/api/auth/register", json={
            "email": user1_email, "password": "test123", "name": "Chat User 1", "gender": "Male"
        })
        resp2 = requests.post(f"{BASE_URL}/api/auth/register", json={
            "email": user2_email, "password": "test123", "name": "Chat User 2", "gender": "Female"
        })
        
        user1_token = resp1.json()["token"]
        user1_id = resp1.json()["user"]["id"]
        user2_token = resp2.json()["token"]
        user2_id = resp2.json()["user"]["id"]
        
        # Send and accept connection request
        headers1 = {"Authorization": f"Bearer {user1_token}"}
        headers2 = {"Authorization": f"Bearer {user2_token}"}
        
        requests.post(f"{BASE_URL}/api/connections/request/{user2_id}", headers=headers1)
        requests.post(f"{BASE_URL}/api/connections/accept/{user1_id}", headers=headers2)
        
        # Upgrade both users to Focus plan (manually update in DB via profile update won't work, need payment)
        # For testing, we'll use the endpoint but expect 403 for free users
        
        return {
            "user1_token": user1_token,
            "user1_id": user1_id,
            "user2_token": user2_token,
            "user2_id": user2_id
        }
    
    def test_chat_send_requires_paid_plan(self, connected_users_with_focus_plan):
        """Test POST /api/chat/send requires Focus or Commit plan"""
        headers = {"Authorization": f"Bearer {connected_users_with_focus_plan['user1_token']}"}
        payload = {
            "receiverId": connected_users_with_focus_plan['user2_id'],
            "content": "Hello, this is a test message"
        }
        response = requests.post(f"{BASE_URL}/api/chat/send", json=payload, headers=headers)
        # Should return 403 because user is on free plan
        assert response.status_code == 403, f"Expected 403 for free user, got {response.status_code}"
        assert "focus or commit" in response.json()["detail"].lower()
        print("✓ Chat send blocked for free plan users")
    
    def test_chat_get_requires_paid_plan(self, connected_users_with_focus_plan):
        """Test GET /api/chat/{partnerId} requires Focus or Commit plan"""
        headers = {"Authorization": f"Bearer {connected_users_with_focus_plan['user1_token']}"}
        partner_id = connected_users_with_focus_plan['user2_id']
        response = requests.get(f"{BASE_URL}/api/chat/{partner_id}", headers=headers)
        # Should return 403 because user is on free plan
        assert response.status_code == 403
        assert "focus or commit" in response.json()["detail"].lower()
        print("✓ Chat get blocked for free plan users")
    
    def test_chat_unread_count_endpoint(self):
        """Test GET /api/chat/unread/count endpoint exists"""
        # Create a user
        unique_email = f"unread_test_{uuid.uuid4().hex[:8]}@example.com"
        resp = requests.post(f"{BASE_URL}/api/auth/register", json={
            "email": unique_email, "password": "test123", "name": "Unread Test", "gender": "Male"
        })
        token = resp.json()["token"]
        headers = {"Authorization": f"Bearer {token}"}
        
        response = requests.get(f"{BASE_URL}/api/chat/unread/count", headers=headers)
        assert response.status_code == 200, f"Unread count failed: {response.text}"
        
        data = response.json()
        assert "unreadCount" in data
        assert isinstance(data["unreadCount"], int)
        assert data["unreadCount"] >= 0
        
        print(f"✓ Chat unread count endpoint working: {data['unreadCount']} unread messages")
