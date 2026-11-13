-- =============================================================================
-- Migration: 20261113000002_row_level_security.sql
-- Description: Row Level Security (RLS) policies for user data isolation & security.
-- Module: EC5208 — Mobile Application Development (Faculty of Engineering, University of Ruhuna)
-- Owner: Member 2 (ashuraweismann / Herath H.M.K.U.A)
-- Reference: docs/SHARED_CONTRACTS.md (D08, D09, D12, D13, D14)
-- =============================================================================

-- =============================================================================
-- 1. ENABLE ROW LEVEL SECURITY
-- =============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- 2. POLICIES FOR public.profiles
-- =============================================================================

-- Customers can view only their own profile
CREATE POLICY "profiles_select_own"
ON public.profiles
FOR SELECT
TO authenticated
USING (
    auth.uid() = id
);

-- Customers can update only their own profile
CREATE POLICY "profiles_update_own"
ON public.profiles
FOR UPDATE
TO authenticated
USING (
    auth.uid() = id
)
WITH CHECK (
    auth.uid() = id
);

-- Customers can insert their own profile (in case trigger fallback is needed)
CREATE POLICY "profiles_insert_own"
ON public.profiles
FOR INSERT
TO authenticated
WITH CHECK (
    auth.uid() = id
);

-- =============================================================================
-- 3. POLICIES FOR public.service_categories AND public.services
-- =============================================================================
-- Active categories and services are readable by authenticated users and anon

CREATE POLICY "service_categories_select_active"
ON public.service_categories
FOR SELECT
TO authenticated, anon
USING (
    is_active = TRUE
);

CREATE POLICY "services_select_active"
ON public.services
FOR SELECT
TO authenticated, anon
USING (
    is_active = TRUE
);

-- Note: INSERT, UPDATE, DELETE on service_categories and services are restricted
-- to service_role / administrative tools; no public client policies are created.

-- =============================================================================
-- 4. POLICIES FOR public.bookings
-- =============================================================================

-- Customers can view only their own bookings
CREATE POLICY "bookings_select_own"
ON public.bookings
FOR SELECT
TO authenticated
USING (
    auth.uid() = customer_id
);

-- Customers can insert their own new booking request (initial status must be 'NEW')
CREATE POLICY "bookings_insert_own"
ON public.bookings
FOR INSERT
TO authenticated
WITH CHECK (
    auth.uid() = customer_id
    AND status = 'NEW'
);

-- Customers can cancel their own booking only while in 'NEW' or 'REVIEWING' state
CREATE POLICY "bookings_customer_cancel"
ON public.bookings
FOR UPDATE
TO authenticated
USING (
    auth.uid() = customer_id
    AND status IN ('NEW', 'REVIEWING')
)
WITH CHECK (
    auth.uid() = customer_id
    AND status = 'CANCELLED'
);

-- Customers can confirm completion when the booking is in 'COMPLETED' state
CREATE POLICY "bookings_customer_confirm_completion"
ON public.bookings
FOR UPDATE
TO authenticated
USING (
    auth.uid() = customer_id
    AND status = 'COMPLETED'
)
WITH CHECK (
    auth.uid() = customer_id
    AND status = 'CONFIRMED'
);

-- =============================================================================
-- 5. POLICIES FOR public.reviews
-- =============================================================================

-- Anyone can read reviews for services (or customer can read own reviews)
CREATE POLICY "reviews_select_all"
ON public.reviews
FOR SELECT
TO authenticated, anon
USING (
    TRUE
);

-- Customers can submit a review only for their own completed/confirmed bookings
CREATE POLICY "reviews_insert_own"
ON public.reviews
FOR INSERT
TO authenticated
WITH CHECK (
    auth.uid() = customer_id
    AND EXISTS (
        SELECT 1
        FROM public.bookings b
        WHERE b.id = booking_id
          AND b.customer_id = auth.uid()
          AND b.status IN ('COMPLETED', 'CONFIRMED')
    )
);

-- Customers can update their own review
CREATE POLICY "reviews_update_own"
ON public.reviews
FOR UPDATE
TO authenticated
USING (
    auth.uid() = customer_id
)
WITH CHECK (
    auth.uid() = customer_id
);
