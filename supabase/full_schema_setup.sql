-- =============================================================================
-- TIKKA — Complete Backend Setup Script (for Supabase SQL Editor)
-- Module: EC5208 — Mobile Application Development
-- Faculty of Engineering, University of Ruhuna | Group 10
-- Owner: Member 2 (ashuraweismann / Herath H.M.K.U.A)
-- Usage: Paste and run directly in Supabase Dashboard -> SQL Editor
-- =============================================================================

BEGIN;

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. UTILITY FUNCTIONS
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE IF NOT EXISTS public.booking_reference_seq START WITH 1001 INCREMENT BY 1;

CREATE OR REPLACE FUNCTION public.generate_booking_reference()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.booking_reference IS NULL OR NEW.booking_reference = '' THEN
        NEW.booking_reference := 'TK-' || NEXTVAL('public.booking_reference_seq')::TEXT;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. TABLES
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone_number TEXT,
    saved_address TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.service_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    icon_name TEXT,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES public.service_categories(id) ON DELETE RESTRICT,
    slug TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    common_jobs TEXT[] DEFAULT '{}' NOT NULL,
    base_price NUMERIC(10, 2),
    currency TEXT DEFAULT 'LKR' NOT NULL,
    icon_name TEXT,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_reference TEXT UNIQUE NOT NULL,
    customer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE RESTRICT,
    status TEXT NOT NULL DEFAULT 'NEW' CHECK (
        status IN (
            'NEW',
            'REVIEWING',
            'SCHEDULED',
            'ASSIGNED',
            'IN_PROGRESS',
            'COMPLETED',
            'CONFIRMED',
            'CANCELLED',
            'REJECTED'
        )
    ),
    problem_description TEXT NOT NULL,
    service_address_snapshot TEXT NOT NULL,
    contact_name_snapshot TEXT NOT NULL,
    contact_phone_snapshot TEXT NOT NULL,
    preferred_date DATE NOT NULL,
    preferred_time TEXT NOT NULL,
    photo_storage_path TEXT,
    assigned_worker_name TEXT,
    scheduled_at TIMESTAMPTZ,
    cancellation_reason TEXT,
    rejection_reason TEXT,
    admin_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID UNIQUE NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 4. TRIGGERS
DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_service_categories_updated_at ON public.service_categories;
CREATE TRIGGER set_service_categories_updated_at
BEFORE UPDATE ON public.service_categories
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_services_updated_at ON public.services;
CREATE TRIGGER set_services_updated_at
BEFORE UPDATE ON public.services
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_booking_reference ON public.bookings;
CREATE TRIGGER set_booking_reference
BEFORE INSERT ON public.bookings
FOR EACH ROW EXECUTE FUNCTION public.generate_booking_reference();

DROP TRIGGER IF EXISTS set_bookings_updated_at ON public.bookings;
CREATE TRIGGER set_bookings_updated_at
BEFORE UPDATE ON public.bookings
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_reviews_updated_at ON public.reviews;
CREATE TRIGGER set_reviews_updated_at
BEFORE UPDATE ON public.reviews
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Auto Profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    user_name TEXT;
    user_phone TEXT;
BEGIN
    user_name := COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', 'Valued Customer');
    user_phone := COALESCE(NEW.raw_user_meta_data->>'phone_number', NEW.raw_user_meta_data->>'phone', NEW.phone, NULL);

    INSERT INTO public.profiles (id, full_name, phone_number, saved_address)
    VALUES (NEW.id, user_name, user_phone, NULL)
    ON CONFLICT (id) DO UPDATE
    SET
        full_name = EXCLUDED.full_name,
        phone_number = COALESCE(public.profiles.phone_number, EXCLUDED.phone_number);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. ROW LEVEL SECURITY
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Profiles
DROP POLICY IF EXISTS "profiles_select_own" ON public.profiles;
CREATE POLICY "profiles_select_own" ON public.profiles FOR SELECT TO authenticated USING (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_insert_own" ON public.profiles;
CREATE POLICY "profiles_insert_own" ON public.profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);

-- Categories & Services
DROP POLICY IF EXISTS "service_categories_select_active" ON public.service_categories;
CREATE POLICY "service_categories_select_active" ON public.service_categories FOR SELECT TO authenticated, anon USING (is_active = TRUE);

DROP POLICY IF EXISTS "services_select_active" ON public.services;
CREATE POLICY "services_select_active" ON public.services FOR SELECT TO authenticated, anon USING (is_active = TRUE);

-- Bookings
DROP POLICY IF EXISTS "bookings_select_own" ON public.bookings;
CREATE POLICY "bookings_select_own" ON public.bookings FOR SELECT TO authenticated USING (auth.uid() = customer_id);

DROP POLICY IF EXISTS "bookings_insert_own" ON public.bookings;
CREATE POLICY "bookings_insert_own" ON public.bookings FOR INSERT TO authenticated WITH CHECK (auth.uid() = customer_id AND status = 'NEW');

DROP POLICY IF EXISTS "bookings_customer_cancel" ON public.bookings;
CREATE POLICY "bookings_customer_cancel" ON public.bookings FOR UPDATE TO authenticated USING (auth.uid() = customer_id AND status IN ('NEW', 'REVIEWING')) WITH CHECK (auth.uid() = customer_id AND status = 'CANCELLED');

DROP POLICY IF EXISTS "bookings_customer_confirm_completion" ON public.bookings;
CREATE POLICY "bookings_customer_confirm_completion" ON public.bookings FOR UPDATE TO authenticated USING (auth.uid() = customer_id AND status = 'COMPLETED') WITH CHECK (auth.uid() = customer_id AND status = 'CONFIRMED');

-- Reviews
DROP POLICY IF EXISTS "reviews_select_all" ON public.reviews;
CREATE POLICY "reviews_select_all" ON public.reviews FOR SELECT TO authenticated, anon USING (TRUE);

DROP POLICY IF EXISTS "reviews_insert_own" ON public.reviews;
CREATE POLICY "reviews_insert_own" ON public.reviews FOR INSERT TO authenticated WITH CHECK (auth.uid() = customer_id AND EXISTS (SELECT 1 FROM public.bookings b WHERE b.id = booking_id AND b.customer_id = auth.uid() AND b.status IN ('COMPLETED', 'CONFIRMED')));

DROP POLICY IF EXISTS "reviews_update_own" ON public.reviews;
CREATE POLICY "reviews_update_own" ON public.reviews FOR UPDATE TO authenticated USING (auth.uid() = customer_id) WITH CHECK (auth.uid() = customer_id);

-- 6. STORAGE BUCKET & POLICIES
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'booking-photos',
    'booking-photos',
    FALSE,
    5242880,
    ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE
SET
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "booking_photos_insert_own" ON storage.objects;
CREATE POLICY "booking_photos_insert_own" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'booking-photos' AND (storage.foldername(name))[1] = auth.uid()::TEXT);

DROP POLICY IF EXISTS "booking_photos_select_own" ON storage.objects;
CREATE POLICY "booking_photos_select_own" ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'booking-photos' AND (storage.foldername(name))[1] = auth.uid()::TEXT);

DROP POLICY IF EXISTS "booking_photos_delete_own" ON storage.objects;
CREATE POLICY "booking_photos_delete_own" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'booking-photos' AND (storage.foldername(name))[1] = auth.uid()::TEXT);

-- 7. SEED DATA (CATEGORIES & SERVICES)
INSERT INTO public.service_categories (id, slug, name, description, icon_name, sort_order, is_active)
VALUES
    ('c1111111-1111-1111-1111-111111111101', 'plumbing', 'Plumbing', 'Leaks, pipes, drainage and bathroom fittings', 'plumbing', 1, TRUE),
    ('c1111111-1111-1111-1111-111111111102', 'electrical', 'Electrical', 'Wiring, lighting, sockets and electrical appliances', 'electrical_services', 2, TRUE),
    ('c1111111-1111-1111-1111-111111111103', 'cleaning', 'Cleaning', 'Home, kitchen, sofa and deep cleaning services', 'cleaning_services', 3, TRUE),
    ('c1111111-1111-1111-1111-111111111104', 'repairs', 'Repairs', 'General home maintenance, appliances and fixture repair', 'build', 4, TRUE),
    ('c1111111-1111-1111-1111-111111111105', 'painting', 'Painting', 'Interior and exterior wall painting and touch-ups', 'format_paint', 5, TRUE),
    ('c1111111-1111-1111-1111-111111111106', 'handyman', 'Handyman', 'Furniture assembly, wall mounting and general fixes', 'handyman', 6, TRUE),
    ('c1111111-1111-1111-1111-111111111107', 'gardening', 'Gardening', 'Lawn mowing, tree trimming and outdoor garden maintenance', 'yard', 7, TRUE),
    ('c1111111-1111-1111-1111-111111111108', 'moving', 'Moving', 'House shifting, packing and heavy furniture lifting', 'local_shipping', 8, TRUE)
ON CONFLICT (slug) DO UPDATE
SET name = EXCLUDED.name, description = EXCLUDED.description, icon_name = EXCLUDED.icon_name, sort_order = EXCLUDED.sort_order, is_active = EXCLUDED.is_active;

INSERT INTO public.services (id, category_id, slug, name, description, common_jobs, base_price, currency, is_active, sort_order)
VALUES
    ('s2222222-2222-2222-2222-222222222201', 'c1111111-1111-1111-1111-111111111101', 'plumbing-general', 'Plumbing', 'Book trusted help for leaks, taps, pipe issues and basic plumbing.', ARRAY['Leaking taps and pipes', 'Blocked sinks and drains', 'Fitting or replacing fixtures', 'Minor plumbing repairs'], 1500.00, 'LKR', TRUE, 1),
    ('s2222222-2222-2222-2222-222222222202', 'c1111111-1111-1111-1111-111111111101', 'pipe-drainage-repair', 'Drainage & Pipe Unclogging', 'Fast and reliable clearing of stubborn blocked drains, toilets, and gully traps.', ARRAY['Gully trap cleaning', 'Main drain unclogging', 'Toilet siphon repair'], 2000.00, 'LKR', TRUE, 2),
    ('s2222222-2222-2222-2222-222222222203', 'c1111111-1111-1111-1111-111111111102', 'electrical-general', 'Electrical', 'Expert electrical repairs, fixture replacements, socket wiring, and troubleshooting.', ARRAY['Light fixture & chandelier installation', 'Ceiling fan installation and capacitor replacement', 'Short circuit & trip switch troubleshooting', 'Socket and main switch replacement'], 1800.00, 'LKR', TRUE, 1),
    ('s2222222-2222-2222-2222-222222222204', 'c1111111-1111-1111-1111-111111111103', 'cleaning-general', 'Cleaning', 'Professional home sanitization, deep cleaning, and post-event cleanup.', ARRAY['Full house deep cleaning', 'Kitchen tile & exhaust degreasing', 'Bathroom stain and lime scale removal', 'Sofa & upholstery shampooing'], 3500.00, 'LKR', TRUE, 1),
    ('s2222222-2222-2222-2222-222222222205', 'c1111111-1111-1111-1111-111111111104', 'repairs-general', 'Repairs', 'Comprehensive maintenance and repair services for home fixtures and everyday equipment.', ARRAY['Door handle and lock mechanism repair', 'Cabinet hinge alignment and fixing', 'Window latch and mesh repair', 'Minor masonry patch-up'], 1500.00, 'LKR', TRUE, 1),
    ('s2222222-2222-2222-2222-222222222206', 'c1111111-1111-1111-1111-111111111105', 'painting-general', 'Painting', 'High quality interior and exterior wall painting, waterproof coating, and touch-ups.', ARRAY['Interior room repainting', 'Water damage & crack touch-ups', 'Exterior weather-shield coating', 'Door and window enamel painting'], 4000.00, 'LKR', TRUE, 1),
    ('s2222222-2222-2222-2222-222222222207', 'c1111111-1111-1111-1111-111111111106', 'handyman-general', 'Handyman', 'Versatile multi-skilled help for assembly, mounting, drilling, and home adjustments.', ARRAY['Flat-pack furniture assembly', 'Curtain rods, mirrors & artwork hanging', 'Wall-mounted TV bracket installation', 'Shelving unit installation'], 1600.00, 'LKR', TRUE, 1),
    ('s2222222-2222-2222-2222-222222222208', 'c1111111-1111-1111-1111-111111111107', 'gardening-general', 'Gardening', 'Lawn care, tree pruning, hedge trimming, and garden beautification.', ARRAY['Lawn mowing and weed removal', 'Tree and shrub pruning', 'Garden bed preparation and planting', 'Green waste disposal'], 2500.00, 'LKR', TRUE, 1),
    ('s2222222-2222-2222-2222-222222222209', 'c1111111-1111-1111-1111-111111111108', 'moving-general', 'Moving', 'Stress-free moving assistance, packing, loading, and furniture shifting.', ARRAY['Apartment shifting assistance', 'Heavy appliance & furniture relocation', 'Protective packing & wrapping', 'Loading and unloading assistance'], 5000.00, 'LKR', TRUE, 1)
ON CONFLICT (slug) DO UPDATE
SET category_id = EXCLUDED.category_id, name = EXCLUDED.name, description = EXCLUDED.description, common_jobs = EXCLUDED.common_jobs, base_price = EXCLUDED.base_price, currency = EXCLUDED.currency, is_active = EXCLUDED.is_active, sort_order = EXCLUDED.sort_order;

COMMIT;
