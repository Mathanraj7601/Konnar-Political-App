-- This script is for MySQL.

-- Table: users
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY,
    mobile_number VARCHAR(20) UNIQUE NOT NULL,
    `role` ENUM('USER', 'MEMBER', 'ADMIN') DEFAULT 'USER',
    `status` ENUM('ACTIVE', 'BANNED', 'PENDING') DEFAULT 'PENDING',
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (updated_by) REFERENCES users(id)
);

-- Table: member_profiles
-- Note: voter_id and aadhaar_number should be encrypted at the application layer before storing.
CREATE TABLE member_profiles (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) UNIQUE,
    member_id_string VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    father_name VARCHAR(255) NOT NULL,
    dob DATE NOT NULL,
    age INTEGER NOT NULL,
    gender VARCHAR(20) NOT NULL,
    blood_group VARCHAR(10),
    voter_id VARCHAR(255) UNIQUE,
    aadhaar_number VARCHAR(255) UNIQUE,
    profile_image_url VARCHAR(2048),
    id_proof_url VARCHAR(2048),
    date_of_joining DATE DEFAULT (CURRENT_DATE),
    address_street VARCHAR(255) NOT NULL,
    address_door_no VARCHAR(50) NOT NULL,
    address_village VARCHAR(255) NOT NULL,
    address_union VARCHAR(255),
    pincode VARCHAR(10) NOT NULL,
    district VARCHAR(100) NOT NULL,
    constituency VARCHAR(100),
    state VARCHAR(100) DEFAULT 'Tamil Nadu',
    mobile_number VARCHAR(20) UNIQUE NOT NULL, -- Note: This is redundant as it exists in the 'users' table via user_id.
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (updated_by) REFERENCES users(id),
    INDEX idx_member_profiles_district (district),
    INDEX idx_member_profiles_constituency (constituency)
);

-- Table: notifications
CREATE TABLE notifications (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36),
    title VARCHAR(255) NOT NULL,
    subtitle VARCHAR(255),
    body TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (updated_by) REFERENCES users(id)
);

-- Table: events
CREATE TABLE events (
    id CHAR(36) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    subtitle VARCHAR(255),
    description TEXT,
    event_date DATETIME NOT NULL,
    location_name VARCHAR(255),
    location_url VARCHAR(2048),
    cover_image_url VARCHAR(2048),
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (updated_by) REFERENCES users(id)
);

-- Table: media_gallery
CREATE TABLE media_gallery (
    id CHAR(36) PRIMARY KEY,
    media_type ENUM('IMAGE', 'VIDEO', 'YOUTUBE_LINK') NOT NULL,
    url VARCHAR(2048) NOT NULL,
    thumbnail_url VARCHAR(2048),
    title VARCHAR(255),
    subtitle VARCHAR(255),
    uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (updated_by) REFERENCES users(id)
);

-- Table: announcements_news
CREATE TABLE announcements_news (
    id CHAR(36) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    subtitle VARCHAR(255),
    description TEXT,
    published_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    author_id CHAR(36),
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by CHAR(36),
    updated_by CHAR(36),
    FOREIGN KEY (author_id) REFERENCES users(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (updated_by) REFERENCES users(id)
);