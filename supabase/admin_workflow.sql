-- =============================================================================
-- TIKKA — Minimal Authorized Administrative Testing Workflow
-- Module: EC5208 — Mobile Application Development
-- Faculty of Engineering, University of Ruhuna | Group 10
-- Owner: Member 2 (ashuraweismann / Herath H.M.K.U.A)
-- Deliverable for: Phase 10 (Issue #11) — Admin and Backend Testing
-- =============================================================================
-- NOTE:
-- This script provides authorized administrative helpers for managing service data
-- and advancing booking lifecycles during testing, evaluation, and demonstrations.
-- These functions are executed in the Supabase Dashboard (SQL Editor) or via the
-- Supabase service_role key. They are NOT accessible to public or authenticated
-- customer clients, enforcing zero administrative exposure in the mobile app.
-- =============================================================================

BEGIN;

-- =============================================================================
-- 1. STATE MACHINE TRANSITION VALIDATOR
-- =============================================================================
-- Allowed transitions:
--   NEW         -> REVIEWING, CANCELLED
--   REVIEWING   -> SCHEDULED, REJECTED, CANCELLED
--   SCHEDULED   -> ASSIGNED, CANCELLED
--   ASSIGNED    -> IN_PROGRESS, CANCELLED
--   IN_PROGRESS -> COMPLETED, CANCELLED
--   COMPLETED   -> CONFIRMED
-- Terminal states (no transitions allowed):
--   CANCELLED, REJECTED, CONFIRMED

CREATE OR REPLACE FUNCTION public.validate_booking_status_transition(
    p_current_status TEXT,
    p_target_status TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
    IF p_current_status = p_target_status THEN
        RETURN TRUE;
    END IF;

    CASE p_current_status
        WHEN 'NEW' THEN
            RETURN p_target_status IN ('REVIEWING', 'CANCELLED');
        WHEN 'REVIEWING' THEN
            RETURN p_target_status IN ('SCHEDULED', 'REJECTED', 'CANCELLED');
        WHEN 'SCHEDULED' THEN
            RETURN p_target_status IN ('ASSIGNED', 'CANCELLED');
        WHEN 'ASSIGNED' THEN
            RETURN p_target_status IN ('IN_PROGRESS', 'CANCELLED');
        WHEN 'IN_PROGRESS' THEN
            RETURN p_target_status IN ('COMPLETED', 'CANCELLED');
        WHEN 'COMPLETED' THEN
            RETURN p_target_status = 'CONFIRMED';
        ELSE
            -- Terminal states cannot transition further
            RETURN FALSE;
    END CASE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- =============================================================================
-- 2. ADMINISTRATIVE BOOKING STATUS UPDATE PROCEDURE
-- =============================================================================

CREATE OR REPLACE FUNCTION public.admin_update_booking_status(
    p_booking_reference TEXT,
    p_new_status TEXT,
    p_worker_name TEXT DEFAULT NULL,
    p_scheduled_at TIMESTAMPTZ DEFAULT NULL,
    p_rejection_reason TEXT DEFAULT NULL,
    p_admin_notes TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_booking RECORD;
    v_valid_transition BOOLEAN;
BEGIN
    -- 1. Locate target booking
    SELECT * INTO v_booking
    FROM public.bookings
    WHERE booking_reference = p_booking_reference
       OR id::TEXT = p_booking_reference;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking not found with reference or ID: %', p_booking_reference
            USING ERRCODE = 'P0002';
    END IF;

    -- 2. Validate state transition
    v_valid_transition := public.validate_booking_status_transition(v_booking.status, p_new_status);
    IF NOT v_valid_transition THEN
        RAISE EXCEPTION 'Illegal status transition from % to % for booking %',
            v_booking.status, p_new_status, p_booking_reference
            USING ERRCODE = '22000';
    END IF;

    -- 3. Execute update
    UPDATE public.bookings
    SET
        status = p_new_status,
        assigned_worker_name = COALESCE(p_worker_name, assigned_worker_name),
        scheduled_at = COALESCE(p_scheduled_at, scheduled_at),
        rejection_reason = COALESCE(p_rejection_reason, rejection_reason),
        admin_notes = CASE 
            WHEN p_admin_notes IS NOT NULL THEN 
                COALESCE(admin_notes || E'\n' || p_admin_notes, p_admin_notes)
            ELSE admin_notes 
        END,
        updated_at = NOW()
    WHERE id = v_booking.id;

    RETURN jsonb_build_object(
        'success', TRUE,
        'booking_reference', v_booking.booking_reference,
        'previous_status', v_booking.status,
        'new_status', p_new_status,
        'assigned_worker', COALESCE(p_worker_name, v_booking.assigned_worker_name),
        'scheduled_at', COALESCE(p_scheduled_at, v_booking.scheduled_at),
        'updated_at', NOW()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- 3. ADMINISTRATIVE BOOKING OVERVIEW QUERY
-- =============================================================================

CREATE OR REPLACE FUNCTION public.admin_list_bookings(
    p_status_filter TEXT DEFAULT NULL
)
RETURNS TABLE (
    booking_id UUID,
    booking_reference TEXT,
    customer_id UUID,
    customer_name TEXT,
    customer_phone TEXT,
    service_name TEXT,
    status TEXT,
    problem_description TEXT,
    preferred_date DATE,
    preferred_time TEXT,
    assigned_worker_name TEXT,
    scheduled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    has_review BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.id AS booking_id,
        b.booking_reference,
        b.customer_id,
        b.contact_name_snapshot AS customer_name,
        b.contact_phone_snapshot AS customer_phone,
        COALESCE(s.name, 'Unknown Service') AS service_name,
        b.status,
        b.problem_description,
        b.preferred_date,
        b.preferred_time,
        b.assigned_worker_name,
        b.scheduled_at,
        b.created_at,
        EXISTS(SELECT 1 FROM public.reviews r WHERE r.booking_id = b.id) AS has_review
    FROM public.bookings b
    LEFT JOIN public.services s ON s.id = b.service_id
    WHERE (p_status_filter IS NULL OR b.status = p_status_filter)
    ORDER BY b.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- 4. ADMINISTRATIVE SERVICE CATALOG MANAGEMENT
-- =============================================================================

-- Toggle active status of a service (Soft Delete / Reactivation)
CREATE OR REPLACE FUNCTION public.admin_toggle_service_active(
    p_slug TEXT,
    p_is_active BOOLEAN
)
RETURNS JSONB AS $$
DECLARE
    v_service RECORD;
BEGIN
    UPDATE public.services
    SET is_active = p_is_active, updated_at = NOW()
    WHERE slug = p_slug
    RETURNING * INTO v_service;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Service with slug % not found', p_slug USING ERRCODE = 'P0002';
    END IF;

    RETURN jsonb_build_object(
        'success', TRUE,
        'slug', v_service.slug,
        'name', v_service.name,
        'is_active', v_service.is_active
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update or insert a service record
CREATE OR REPLACE FUNCTION public.admin_upsert_service(
    p_category_slug TEXT,
    p_slug TEXT,
    p_name TEXT,
    p_description TEXT,
    p_common_jobs TEXT[],
    p_base_price NUMERIC,
    p_is_active BOOLEAN DEFAULT TRUE,
    p_sort_order INTEGER DEFAULT 1
)
RETURNS JSONB AS $$
DECLARE
    v_category_id UUID;
    v_service RECORD;
BEGIN
    SELECT id INTO v_category_id
    FROM public.service_categories
    WHERE slug = p_category_slug;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Category with slug % not found', p_category_slug USING ERRCODE = 'P0002';
    END IF;

    INSERT INTO public.services (
        category_id, slug, name, description, common_jobs, base_price, currency, is_active, sort_order
    ) VALUES (
        v_category_id, p_slug, p_name, p_description, p_common_jobs, p_base_price, 'LKR', p_is_active, p_sort_order
    )
    ON CONFLICT (slug) DO UPDATE
    SET
        category_id = EXCLUDED.category_id,
        name = EXCLUDED.name,
        description = EXCLUDED.description,
        common_jobs = EXCLUDED.common_jobs,
        base_price = EXCLUDED.base_price,
        is_active = EXCLUDED.is_active,
        sort_order = EXCLUDED.sort_order,
        updated_at = NOW()
    RETURNING * INTO v_service;

    RETURN jsonb_build_object(
        'success', TRUE,
        'slug', v_service.slug,
        'name', v_service.name,
        'base_price', v_service.base_price,
        'is_active', v_service.is_active
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- 5. ACCESS CONTROL LOCKDOWN
-- =============================================================================
-- Administrative functions must NOT be callable by authenticated customers or anon.
-- Grant access exclusively to service_role (and superuser).

REVOKE ALL ON FUNCTION public.validate_booking_status_transition(TEXT, TEXT) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.admin_update_booking_status(TEXT, TEXT, TEXT, TIMESTAMPTZ, TEXT, TEXT) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.admin_list_bookings(TEXT) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.admin_toggle_service_active(TEXT, BOOLEAN) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.admin_upsert_service(TEXT, TEXT, TEXT, TEXT, TEXT[], NUMERIC, BOOLEAN, INTEGER) FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.validate_booking_status_transition(TEXT, TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_update_booking_status(TEXT, TEXT, TEXT, TIMESTAMPTZ, TEXT, TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_list_bookings(TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_toggle_service_active(TEXT, BOOLEAN) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_upsert_service(TEXT, TEXT, TEXT, TEXT, TEXT[], NUMERIC, BOOLEAN, INTEGER) TO service_role;

COMMIT;
