-- =============================================
-- MallBuddy Database Schema
-- Complete SQL Commands for PostgreSQL/MySQL/SQLite
-- Generated for hosting deployment
-- =============================================

-- =============================================
-- TABLE CREATION (Schema Definition)
-- =============================================

-- 1. MALLS TABLE
CREATE TABLE IF NOT EXISTS malls (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    operating_hours JSON,
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. CATEGORIES TABLE
CREATE TABLE IF NOT EXISTS categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 3. STORES TABLE
CREATE TABLE IF NOT EXISTS stores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mall_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    name VARCHAR(200) NOT NULL,
    floor VARCHAR(20) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    description TEXT,
    logo_url VARCHAR(500),
    status VARCHAR(20) DEFAULT 'open',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mall_id) REFERENCES malls (id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories (id)
);

CREATE INDEX idx_stores_name ON stores (name);

-- 4. OFFERS TABLE
CREATE TABLE IF NOT EXISTS offers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    store_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_featured BOOLEAN DEFAULT 0,
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (store_id) REFERENCES stores (id) ON DELETE CASCADE
);

-- 5. FACILITIES TABLE
CREATE TABLE IF NOT EXISTS facilities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mall_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    floor VARCHAR(20),
    unit VARCHAR(50),
    description TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mall_id) REFERENCES malls (id) ON DELETE CASCADE
);

-- 6. EVENTS TABLE
CREATE TABLE IF NOT EXISTS events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mall_id INTEGER NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    event_date DATETIME NOT NULL,
    location VARCHAR(200),
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mall_id) REFERENCES malls (id) ON DELETE CASCADE
);

-- 7. ROUTES TABLE (Navigation)
CREATE TABLE IF NOT EXISTS routes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mall_id INTEGER NOT NULL,
    from_location VARCHAR(200) NOT NULL,
    to_location VARCHAR(200) NOT NULL,
    steps JSON NOT NULL,
    estimated_time INTEGER,
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mall_id) REFERENCES malls (id) ON DELETE CASCADE
);

-- 8. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT 1
);

CREATE INDEX idx_users_email ON users (email);

-- 9. ADMINS TABLE
CREATE TABLE IF NOT EXISTS admins (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT 1
);

CREATE INDEX idx_admins_email ON admins (email);

-- 10. CHAT_SESSIONS TABLE
CREATE TABLE IF NOT EXISTS chat_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id VARCHAR(100) UNIQUE NOT NULL,
    user_id INTEGER,
    mall_id INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (mall_id) REFERENCES malls (id)
);

CREATE INDEX idx_chat_sessions_session_id ON chat_sessions (session_id);

-- 11. CHAT_MESSAGES TABLE
CREATE TABLE IF NOT EXISTS chat_messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id INTEGER NOT NULL,
    role VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    intent VARCHAR(50),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES chat_sessions (id) ON DELETE CASCADE
);

CREATE INDEX idx_chat_messages_timestamp ON chat_messages (timestamp);

-- 12. FEEDBACK TABLE
CREATE TABLE IF NOT EXISTS feedback (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    session_id VARCHAR(100),
    type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'open',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    resolved_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

-- 13. KNOWLEDGE_DOCS TABLE
CREATE TABLE IF NOT EXISTS knowledge_docs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mall_id INTEGER NOT NULL,
    filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    doc_type VARCHAR(50),
    is_active BOOLEAN DEFAULT 1,
    uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    indexed_at DATETIME,
    FOREIGN KEY (mall_id) REFERENCES malls (id) ON DELETE CASCADE
);

-- 14. CHATBOT_SETTINGS TABLE
CREATE TABLE IF NOT EXISTS chatbot_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT NOT NULL,
    description TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 15. AUDIT_LOGS TABLE
CREATE TABLE IF NOT EXISTS audit_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    admin_id INTEGER NOT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INTEGER,
    details JSON,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admins (id)
);

CREATE INDEX idx_audit_logs_timestamp ON audit_logs (timestamp);

-- =============================================
-- SAMPLE DATA (INSERT Statements)
-- =============================================

-- Insert Mall
INSERT INTO
    malls (
        name,
        city,
        address,
        operating_hours,
        is_active
    )
VALUES (
        'Elements Mall',
        'Bangalore',
        'Whitefield Main Road, Bangalore 560066',
        '{"mon-thu": "10:00-22:00", "fri-sun": "10:00-23:00"}',
        1
    );

-- Insert Categories
INSERT INTO
    categories (name, description, icon)
VALUES (
        'Fashion',
        'Clothing, accessories, and fashion brands',
        '👗'
    ),
    (
        'Electronics',
        'Gadgets, appliances, and electronics',
        '📱'
    ),
    (
        'Food & Beverages',
        'Restaurants, cafes, and food outlets',
        '🍔'
    ),
    (
        'Sports',
        'Sports equipment and apparel',
        '⚽'
    ),
    (
        'Entertainment',
        'Cinema, gaming, and entertainment',
        '🎬'
    ),
    (
        'Beauty',
        'Cosmetics, skincare, and beauty products',
        '💄'
    ),
    (
        'Home & Lifestyle',
        'Home decor and lifestyle products',
        '🏠'
    ),
    (
        'Kids',
        'Toys, kids clothing, and accessories',
        '🧸'
    );

-- Insert Stores
INSERT INTO
    stores (
        mall_id,
        category_id,
        name,
        floor,
        unit,
        description,
        status
    )
VALUES (
        1,
        1,
        'Zara',
        '1',
        '105',
        'International fashion brand with latest trends',
        'open'
    ),
    (
        1,
        1,
        'H&M',
        '1',
        '110',
        'Swedish fashion brand for all ages',
        'open'
    ),
    (
        1,
        4,
        'Nike',
        '2',
        '210',
        'Premium sports footwear and apparel',
        'open'
    ),
    (
        1,
        4,
        'Adidas',
        '2',
        '205',
        'German sports brand with iconic designs',
        'open'
    ),
    (
        1,
        2,
        'Apple Store',
        '2',
        '215',
        'Official Apple products and accessories',
        'open'
    ),
    (
        1,
        2,
        'Samsung',
        '2',
        '220',
        'Samsung electronics and mobile devices',
        'open'
    ),
    (
        1,
        3,
        'McDonald''s',
        '3',
        '301',
        'Fast food restaurant',
        'open'
    ),
    (
        1,
        3,
        'Pizza Hut',
        '3',
        '305',
        'Pizza and Italian cuisine',
        'open'
    ),
    (
        1,
        3,
        'Starbucks',
        '1',
        '115',
        'Premium coffee and beverages',
        'open'
    ),
    (
        1,
        5,
        'PVR Cinemas',
        '4',
        '401',
        'Multiplex cinema with IMAX',
        'open'
    ),
    (
        1,
        5,
        'Gaming Zone',
        '4',
        '410',
        'Arcade games and VR experiences',
        'open'
    ),
    (
        1,
        6,
        'Sephora',
        '1',
        '120',
        'Beauty and cosmetics retailer',
        'open'
    ),
    (
        1,
        7,
        'Home Centre',
        '3',
        '320',
        'Home decor and furniture',
        'open'
    ),
    (
        1,
        8,
        'Hamleys',
        '3',
        '330',
        'Premium toy store',
        'open'
    ),
    (
        1,
        1,
        'Levi''s',
        '1',
        '130',
        'Denim and casual wear',
        'open'
    );

-- Insert Offers
INSERT INTO
    offers (
        store_id,
        title,
        description,
        start_date,
        end_date,
        is_featured,
        is_active
    )
VALUES (
        1,
        '30% Off Winter Collection',
        'Get 30% off on all winter wear items at Zara',
        '2026-01-01',
        '2026-01-31',
        1,
        1
    ),
    (
        3,
        'Buy 2 Get 1 Free',
        'Buy any 2 footwear and get 1 free at Nike',
        '2026-01-15',
        '2026-02-15',
        1,
        1
    ),
    (
        10,
        '20% Off Movie Tickets',
        'Flat 20% off on all movie tickets on weekdays',
        '2026-01-01',
        '2026-03-31',
        1,
        1
    ),
    (
        2,
        'Flat 40% Off Sale',
        'Massive sale on H&M winter collection',
        '2026-01-10',
        '2026-02-10',
        0,
        1
    ),
    (
        4,
        'New Arrivals - 15% Off',
        'Special discount on new Adidas arrivals',
        '2026-01-20',
        '2026-02-20',
        0,
        1
    ),
    (
        9,
        'Free Coffee with Pastry',
        'Buy any pastry and get free tall coffee',
        '2026-01-01',
        '2026-01-31',
        0,
        1
    ),
    (
        5,
        'iPhone Trade-In Offer',
        'Trade your old phone for discount on new iPhone',
        '2026-01-01',
        '2026-03-31',
        1,
        1
    ),
    (
        12,
        'Beauty Box - 25% Off',
        'Special discount on beauty box subscription',
        '2026-01-15',
        '2026-02-28',
        0,
        1
    );

-- Insert Facilities
INSERT INTO facilities (mall_id, name, type, floor, unit, description, is_active) VALUES
(1, 'Washroom - Floor 1', 'washroom', '1', '101', 'Clean restrooms near main entrance', 1),
(1, 'Washroom - Floor 2', 'washroom', '2', '201', 'Restrooms near sports zone', 1),
(1, 'Washroom - Floor 3', 'washroom', '3', '310', 'Restrooms near food court', 1),
(1, 'ATM - HDFC Bank', 'atm', '1', '102', 'HDFC Bank ATM', 1),
(1, 'ATM - SBI', 'atm', '1', '103', 'State Bank of India ATM', 1),
(1, 'Parking - Basement', 'parking', 'B1', 'P1', '500+ car parking spaces', 1),
(1, 'Information Desk', 'info', '1', 'Main', 'Help desk at main entrance', 1),
(1, 'Food Court', 'food_court', '3', '300', 'Multi-cuisine food court', 1),
(1, 'Baby Care Room', 'baby_care', '2', '230', 'Baby changing and nursing room', 1),
(1, 'First Aid', 'medical', '1', '108', 'First aid station', 1);

-- Insert Events
INSERT INTO
    events (
        mall_id,
        name,
        description,
        event_date,
        location,
        is_active
    )
VALUES (
        1,
        'Republic Day Celebration',
        'Special cultural performances and flag hoisting ceremony',
        '2026-01-26 10:00:00',
        'Main Atrium, Floor 1',
        1
    ),
    (
        1,
        'Winter Fashion Show',
        'Showcase of winter collection from top brands',
        '2026-02-01 18:00:00',
        'Fashion Floor, Level 1',
        1
    ),
    (
        1,
        'Kids Carnival',
        'Fun activities, games and prizes for children',
        '2026-02-15 11:00:00',
        'Kids Zone, Floor 3',
        1
    ),
    (
        1,
        'Tech Expo 2026',
        'Latest gadgets and tech demos',
        '2026-02-20 10:00:00',
        'Electronics Zone, Floor 2',
        1
    ),
    (
        1,
        'Valentine''s Day Special',
        'Couple photobooth and special offers',
        '2026-02-14 16:00:00',
        'Central Atrium',
        1
    );

-- Insert Default Admin (password: admin123)
INSERT INTO
    admins (
        name,
        email,
        password_hash,
        role,
        is_active
    )
VALUES (
        'Admin User',
        'admin@mallbuddy.com',
        'pbkdf2:sha256:260000$salt$hashedpassword',
        'super_admin',
        1
    );

-- Insert Chatbot Settings
INSERT INTO
    chatbot_settings (key, value, description)
VALUES (
        'welcome_message',
        'Hello! 👋 Welcome to Elements Mall. I''m MallBuddy, your AI shopping assistant!',
        'Default welcome message'
    ),
    (
        'fallback_message',
        'I''m not sure I understand. Could you please rephrase that?',
        'Message when intent is not recognized'
    ),
    (
        'max_suggestions',
        '3',
        'Maximum number of suggestions to show'
    ),
    (
        'personality_tone',
        'friendly',
        'Chatbot personality tone'
    );

-- =============================================
-- PostgreSQL SPECIFIC SYNTAX (for Render/Railway)
-- Uncomment and use if deploying to PostgreSQL
-- =============================================

/*
-- For PostgreSQL, replace:
-- INTEGER PRIMARY KEY AUTOINCREMENT → SERIAL PRIMARY KEY
-- BOOLEAN DEFAULT 1 → BOOLEAN DEFAULT TRUE
-- BOOLEAN DEFAULT 0 → BOOLEAN DEFAULT FALSE
-- JSON → JSONB (recommended for PostgreSQL)

-- Example:
CREATE TABLE malls (
id SERIAL PRIMARY KEY,
name VARCHAR(200) NOT NULL,
city VARCHAR(100) NOT NULL,
address TEXT NOT NULL,
operating_hours JSONB,
is_active BOOLEAN DEFAULT TRUE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
*/