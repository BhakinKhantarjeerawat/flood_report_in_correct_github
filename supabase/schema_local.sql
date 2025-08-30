-- 🌊 Flood Marker Database Schema - Local Development Version
-- Simplified version for local Supabase setup

-- Create custom types for better data validation
CREATE TYPE flood_severity AS ENUM ('passable', 'blocked', 'severe');
CREATE TYPE flood_status AS ENUM ('active', 'resolved', 'expired');

-- 🌊 Main flood reports table
CREATE TABLE flood_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Location data
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    location_name TEXT,
    
    -- Flood details
    severity flood_severity NOT NULL,
    depth_cm INTEGER CHECK (depth_cm >= 0 AND depth_cm <= 1000),
    note TEXT CHECK (char_length(note) <= 500),
    
    -- Media
    photo_urls TEXT[] DEFAULT '{}',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Community interaction
    confirms INTEGER DEFAULT 0,
    flags INTEGER DEFAULT 0,
    status flood_status DEFAULT 'active',
    
    -- Metadata
    is_anonymous BOOLEAN DEFAULT true,
    source TEXT DEFAULT 'mobile_app',
    
    -- Constraints
    CONSTRAINT valid_coordinates CHECK (lat >= -90 AND lat <= 90 AND lng >= -180 AND lng <= 180),
    CONSTRAINT valid_expiry CHECK (expires_at > created_at)
);

-- 🕒 Time-based indexes for efficient queries
CREATE INDEX idx_flood_reports_created_at ON flood_reports(created_at DESC);
CREATE INDEX idx_flood_reports_expires_at ON flood_reports(expires_at);
CREATE INDEX idx_flood_reports_status ON flood_reports(status);

-- 👤 User-based indexes
CREATE INDEX idx_flood_reports_user_id ON flood_reports(user_id);
CREATE INDEX idx_flood_reports_anonymous ON flood_reports(is_anonymous);

-- 🔍 Severity and status indexes
CREATE INDEX idx_flood_reports_severity ON flood_reports(severity);
CREATE INDEX idx_flood_reports_active_severity ON flood_reports(severity, status) WHERE status = 'active';

-- 🔐 User preferences table
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    
    -- Notification preferences
    email_notifications BOOLEAN DEFAULT false,
    push_notifications BOOLEAN DEFAULT true,
    location_alerts BOOLEAN DEFAULT true,
    
    -- Map preferences
    default_map_center_lat DOUBLE PRECISION DEFAULT 13.7563,
    default_map_center_lng DOUBLE PRECISION DEFAULT 100.5018,
    default_zoom_level INTEGER DEFAULT 12,
    
    -- Display preferences
    show_severity_colors BOOLEAN DEFAULT true,
    show_expired_reports BOOLEAN DEFAULT false,
    language TEXT DEFAULT 'en',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 📍 Favorite locations table
CREATE TABLE user_favorite_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Location data
    name TEXT NOT NULL,
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    address TEXT,
    
    -- Metadata
    is_home BOOLEAN DEFAULT false,
    is_work BOOLEAN DEFAULT false,
    notes TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_favorite_coordinates CHECK (lat >= -90 AND lat <= 90 AND lng >= -180 AND lng <= 180)
);

-- 🚨 Row Level Security (RLS) policies
ALTER TABLE flood_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorite_locations ENABLE ROW LEVEL SECURITY;

-- 👤 Users can view all flood reports
CREATE POLICY "Users can view all flood reports" ON flood_reports
    FOR SELECT USING (true);

-- 👤 Users can create flood reports
CREATE POLICY "Users can create flood reports" ON flood_reports
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 👤 Users can update their own flood reports
CREATE POLICY "Users can update own flood reports" ON flood_reports
    FOR UPDATE USING (auth.uid() = user_id);

-- 👤 Users can delete their own flood reports
CREATE POLICY "Users can delete own flood reports" ON flood_reports
    FOR DELETE USING (auth.uid() = user_id);

-- 👤 Users can manage their own preferences
CREATE POLICY "Users can manage own preferences" ON user_preferences
    FOR ALL USING (auth.uid() = user_id);

-- 👤 Users can manage their own favorite locations
CREATE POLICY "Users can manage own favorite locations" ON user_favorite_locations
    FOR ALL USING (auth.uid() = user_id);

-- 🔄 Functions for automatic updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 🔄 Triggers for automatic timestamp updates
CREATE TRIGGER update_flood_reports_updated_at 
    BEFORE UPDATE ON flood_reports 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at 
    BEFORE UPDATE ON user_preferences 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_favorite_locations_updated_at 
    BEFORE UPDATE ON user_favorite_locations 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 📊 Views for common queries
CREATE VIEW active_flood_reports AS
SELECT 
    fr.*,
    u.email as user_email,
    u.raw_user_meta_data->>'name' as user_name
FROM flood_reports fr
LEFT JOIN auth.users u ON fr.user_id = u.id
WHERE fr.status = 'active'
ORDER BY fr.created_at DESC;

CREATE VIEW flood_reports_by_severity AS
SELECT 
    severity,
    COUNT(*) as total_reports,
    COUNT(*) FILTER (WHERE status = 'active') as active_reports,
    AVG(depth_cm) as avg_depth_cm
FROM flood_reports
GROUP BY severity;

-- 📝 Note: Sample data will be inserted after users are created
-- The INSERT statements below are commented out to avoid foreign key constraint errors
-- Uncomment and run these AFTER you have created some anonymous users in your app

/*
INSERT INTO flood_reports (
    user_id, lat, lng, severity, depth_cm, note, photo_urls, 
    created_at, expires_at, confirms, flags, status, is_anonymous
) VALUES 
    (gen_random_uuid(), 13.7466, 100.5347, 'severe', 50, 'Heavy flooding in Siam shopping district', ARRAY['sample1.jpg'], 
     NOW() - INTERVAL '2 hours', NOW() + INTERVAL '4 hours', 5, 0, 'active', true),
    
    (gen_random_uuid(), 13.7383, 100.5608, 'blocked', 30, 'Moderate flooding in Sukhumvit residential area', ARRAY['sample2.jpg'], 
     NOW() - INTERVAL '1 hour', NOW() + INTERVAL '5 hours', 3, 0, 'active', true),
    
    (gen_random_uuid(), 13.7310, 100.5440, 'passable', 15, 'Minor flooding in Lumpini Park area', ARRAY['sample3.jpg'], 
     NOW() - INTERVAL '30 minutes', NOW() + INTERVAL '5 hours 30 minutes', 1, 0, 'active', true);
*/

-- 🎯 Comments for documentation
COMMENT ON TABLE flood_reports IS 'Main table storing flood report data from users';
COMMENT ON TABLE user_preferences IS 'User-specific app preferences and settings';
COMMENT ON TABLE user_favorite_locations IS 'User-saved favorite locations for quick access';
