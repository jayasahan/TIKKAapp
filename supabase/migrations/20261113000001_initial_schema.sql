-- =============================================================================
-- Migration: 20261113000001_initial_schema.sql
-- Description: Core tables, enums, sequences, and automated triggers for TIKKA.
-- Module: EC5208 — Mobile Application Development (Faculty of Engineering, University of Ruhuna)
-- Owner: Member 2 (ashuraweismann / Herath H.M.K.U.A)
-- Reference: docs/SHARED_CONTRACTS.md, docs/ARCHITECTURE.md, docs/DESIGN_REFERENCE.md
-- =============================================================================

-- Ensure necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- 1. UTILITY FUNCTIONS
-- =============================================================================

-- Automatically updates updated_at column on row modification
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Generates human-friendly booking reference in the format 'TK-1001', 'TK-1002', etc.
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

-- =============================================================================
-- 2. CUSTOMER PROFILES (public.profiles)
-- =============================================================================
-- Primary identity is the Supabase Auth user UUID.
-- Created automatically via trigger on auth.users on signup.
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone_number TEXT,
    saved_address TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON public.profiles(created_at);

CREATE TRIGGER set_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- Trigger to automatically create a profile entry when a user signs up through Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    user_name TEXT;
    user_phone TEXT;
BEGIN
    -- Extract full_name and phone_number from raw_user_meta_data if present
    user_name := COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', 'Valued Customer');
    user_phone := COALESCE(NEW.raw_user_meta_data->>'phone_number', NEW.raw_user_meta_data->>'phone', NEW.phone, NULL);

    INSERT INTO public.profiles (id, full_name, phone_number, saved_address)
    VALUES (
        NEW.id,
        user_name,
        user_phone,
        NULL -- saved_address starts unset per docs/SHARED_CONTRACTS.md D09
    )
    ON CONFLICT (id) DO UPDATE
    SET
        full_name = EXCLUDED.full_name,
        phone_number = COALESCE(public.profiles.phone_number, EXCLUDED.phone_number);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Attach trigger to auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();

-- =============================================================================
-- 3. SERVICE CATEGORIES & SERVICES (public.service_categories, public.services)
-- =============================================================================

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

CREATE INDEX IF NOT EXISTS idx_service_categories_slug ON public.service_categories(slug);
CREATE INDEX IF NOT EXISTS idx_service_categories_sort ON public.service_categories(sort_order);

CREATE TRIGGER set_service_categories_updated_at
BEFORE UPDATE ON public.service_categories
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

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

CREATE INDEX IF NOT EXISTS idx_services_category_id ON public.services(category_id);
CREATE INDEX IF NOT EXISTS idx_services_slug ON public.services(slug);
CREATE INDEX IF NOT EXISTS idx_services_is_active ON public.services(is_active);

CREATE TRIGGER set_services_updated_at
BEFORE UPDATE ON public.services
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- =============================================================================
-- 4. BOOKINGS (public.bookings)
-- =============================================================================
-- Allowed status lifecycle according to docs/SHARED_CONTRACTS.md:
-- NEW -> REVIEWING -> SCHEDULED -> ASSIGNED -> IN_PROGRESS -> COMPLETED -> CONFIRMED
-- Terminal states: CONFIRMED, CANCELLED, REJECTED

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

CREATE INDEX IF NOT EXISTS idx_bookings_customer_id ON public.bookings(customer_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_reference ON public.bookings(booking_reference);
CREATE INDEX IF NOT EXISTS idx_bookings_preferred_date ON public.bookings(preferred_date);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON public.bookings(created_at DESC);

-- Generate reference before insert
CREATE TRIGGER set_booking_reference
BEFORE INSERT ON public.bookings
FOR EACH ROW
EXECUTE FUNCTION public.generate_booking_reference();

CREATE TRIGGER set_bookings_updated_at
BEFORE UPDATE ON public.bookings
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- =============================================================================
-- 5. REVIEWS & RATINGS (public.reviews)
-- =============================================================================
-- One review per booking, restricted to 1-5 star ratings.
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID UNIQUE NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_reviews_customer_id ON public.reviews(customer_id);
CREATE INDEX IF NOT EXISTS idx_reviews_booking_id ON public.reviews(booking_id);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON public.reviews(rating);

CREATE TRIGGER set_reviews_updated_at
BEFORE UPDATE ON public.reviews
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();
