-- 📝 Insert Sample Data for Testing
-- Run this AFTER you have created some anonymous users in your app
-- This avoids foreign key constraint errors

-- First, let's get a real user ID from an existing anonymous user
-- Replace 'your_actual_user_id_here' with a real user ID from your app

-- Option 1: Use a specific user ID (replace with actual ID from your app)
/*
INSERT INTO flood_reports (
    user_id, lat, lng, severity, depth_cm, note, photo_urls, 
    created_at, expires_at, confirms, flags, status, is_anonymous
) VALUES 
    ('your_actual_user_id_here', 13.7466, 100.5347, 'severe', 50, 'Heavy flooding in Siam shopping district', ARRAY['sample1.jpg'], 
     NOW() - INTERVAL '2 hours', NOW() + INTERVAL '4 hours', 5, 0, 'active', true),
    
    ('your_actual_user_id_here', 13.7383, 100.5608, 'blocked', 30, 'Moderate flooding in Sukhumvit residential area', ARRAY['sample2.jpg'], 
     NOW() - INTERVAL '1 hour', NOW() + INTERVAL '5 hours', 3, 0, 'active', true),
    
    ('your_actual_user_id_here', 13.7310, 100.5440, 'passable', 15, 'Minor flooding in Lumpini Park area', ARRAY['sample3.jpg'], 
     NOW() - INTERVAL '30 minutes', NOW() + INTERVAL '5 hours 30 minutes', 1, 0, 'active', true);
*/

Option 2: Insert sample data for ALL existing users (more realistic)
This will create sample reports for every user in your system
-- /*
DO $$
DECLARE
    user_record RECORD;
BEGIN
    FOR user_record IN SELECT id FROM auth.users WHERE raw_user_meta_data->>'provider' = 'anon' LIMIT 3
    LOOP
        INSERT INTO flood_reports (
            user_id, lat, lng, severity, depth_cm, note, photo_urls, 
            created_at, expires_at, confirms, flags, status, is_anonymous
        ) VALUES 
            (user_record.id, 13.7466, 100.5347, 'severe', 50, 'Heavy flooding in Siam shopping district', ARRAY['sample1.jpg'], 
             NOW() - INTERVAL '2 hours', NOW() + INTERVAL '4 hours', 5, 0, 'active', true),
            
            (user_record.id, 13.7383, 100.5608, 'blocked', 30, 'Moderate flooding in Sukhumvit residential area', ARRAY['sample2.jpg'], 
             NOW() - INTERVAL '1 hour', NOW() + INTERVAL '5 hours', 3, 0, 'active', true),
            
            (user_record.id, 13.7310, 100.5440, 'passable', 15, 'Minor flooding in Lumpini Park area', ARRAY['sample3.jpg'], 
             NOW() - INTERVAL '30 minutes', NOW() + INTERVAL '5 hours 30 minutes', 1, 0, 'active', true);
    END LOOP;
END $$;
-- */

-- 🎯 How to Use This File:

-- 1. First, run your app and create some anonymous users
-- 2. Go to Supabase Studio → Authentication → Users
-- 3. Copy a user ID from the list
-- 4. Replace 'your_actual_user_id_here' with the real ID
-- 5. Uncomment Option 1 and run it

-- OR

-- 1. Create some anonymous users in your app
-- 2. Uncomment Option 2 and run it
-- 3. This will automatically create sample data for existing users

-- 💡 Pro Tip: You can also create sample data directly from your app
-- by using the flood report form to submit real reports!
