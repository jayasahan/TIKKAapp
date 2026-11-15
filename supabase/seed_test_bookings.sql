-- =============================================================================
-- Seed: seed_test_bookings.sql
-- Description: Representative test bookings covering all lifecycle statuses.
-- Module: EC5208 — Mobile Application Development
-- Faculty of Engineering, University of Ruhuna | Group 10
-- Owner: Member 2 (ashuraweismann / Herath H.M.K.U.A)
-- Deliverable for: Phase 10 (Issue #11) — Admin and Backend Testing
-- =============================================================================

BEGIN;

-- Fallback test customer ID if no auth user is present during local testing
-- When testing in Supabase, replace with a real customer auth.users.id
DO $$
DECLARE
    v_customer_id UUID;
BEGIN
    -- Use the first existing customer in auth.users if available, otherwise a placeholder uuid
    SELECT id INTO v_customer_id FROM auth.users LIMIT 1;
    IF v_customer_id IS NULL THEN
        v_customer_id := 'a0000000-0000-0000-0000-000000000001'::UUID;
    END IF;

    -- Create corresponding profile if placeholder
    INSERT INTO public.profiles (id, full_name, phone_number, saved_address)
    VALUES (v_customer_id, 'Ranawaka P.S. (Demo Customer)', '+94 77 123 4567', 'Faculty of Engineering, Hapugala, Galle')
    ON CONFLICT (id) DO UPDATE
    SET full_name = EXCLUDED.full_name;

    -- =========================================================================
    -- REPRESENTATIVE BOOKINGS COVERING ALL STATUSES
    -- =========================================================================

    -- 1. Status: NEW
    INSERT INTO public.bookings (
        id, booking_reference, customer_id, service_id, status,
        problem_description, service_address_snapshot, contact_name_snapshot,
        contact_phone_snapshot, preferred_date, preferred_time, created_at, updated_at
    ) VALUES (
        'b1000000-0000-0000-0000-000000001001', 'TK-1001', v_customer_id,
        's2222222-2222-2222-2222-222222222201', 'NEW',
        'Kitchen tap leaking water from swivel base. Requires washer or cartridge replacement.',
        'No. 42, Beach Road, Matara', 'Kasun Herath', '+94 77 234 5678',
        CURRENT_DATE + INTERVAL '2 days', '10:00 AM',
        NOW() - INTERVAL '2 hours', NOW() - INTERVAL '2 hours'
    ) ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status;

    -- 2. Status: REVIEWING
    INSERT INTO public.bookings (
        id, booking_reference, customer_id, service_id, status,
        problem_description, service_address_snapshot, contact_name_snapshot,
        contact_phone_snapshot, preferred_date, preferred_time, admin_notes, created_at, updated_at
    ) VALUES (
        'b1000000-0000-0000-0000-000000001002', 'TK-1002', v_customer_id,
        's2222222-2222-2222-2222-222222222203', 'REVIEWING',
        'Ceiling fan in master bedroom makes humming noise and speed regulator is faulty.',
        'No. 15/A, Temple Road, Galle', 'Sunil Shantha', '+94 71 345 6789',
        CURRENT_DATE + INTERVAL '1 day', '02:00 PM',
        'Customer contacted to clarify regulator model.',
        NOW() - INTERVAL '5 hours', NOW() - INTERVAL '1 hour'
    ) ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status;

    -- 3. Status: SCHEDULED
    INSERT INTO public.bookings (
        id, booking_reference, customer_id, service_id, status,
        problem_description, service_address_snapshot, contact_name_snapshot,
        contact_phone_snapshot, preferred_date, preferred_time, scheduled_at, admin_notes, created_at, updated_at
    ) VALUES (
        'b1000000-0000-0000-0000-000000001003', 'TK-1003', v_customer_id,
        's2222222-2222-2222-2222-222222222204', 'SCHEDULED',
        'Post-renovation full house deep cleaning. Dust and debris removal across 3 rooms.',
        'No. 88, Kandy Road, Kurunegala', 'Anula Kumari', '+94 76 456 7890',
        CURRENT_DATE + INTERVAL '1 day', '09:00 AM',
        (CURRENT_DATE + INTERVAL '1 day' + TIME '09:00:00')::TIMESTAMPTZ,
        'Appointment slot confirmed with customer via phone.',
        NOW() - INTERVAL '1 day', NOW() - INTERVAL '3 hours'
    ) ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status;

    -- 4. Status: ASSIGNED
    INSERT INTO public.bookings (
        id, booking_reference, customer_id, service_id, status,
        problem_description, service_address_snapshot, contact_name_snapshot,
        contact_phone_snapshot, preferred_date, preferred_time, assigned_worker_name, scheduled_at, created_at, updated_at
    ) VALUES (
        'b1000000-0000-0000-0000-000000001004', 'TK-1004', v_customer_id,
        's2222222-2222-2222-2222-222222222202', 'ASSIGNED',
        'Main bathroom floor drain blocked. Gully trap overflowing.',
        'Faculty Quarters, University of Ruhuna, Matara', 'Prof. Jayawardena', '+94 77 567 8901',
        CURRENT_DATE, '11:30 AM',
        'Kamal Perera (Senior Plumber)',
        (CURRENT_DATE + TIME '11:30:00')::TIMESTAMPTZ,
        NOW() - INTERVAL '1 day', NOW() - INTERVAL '2 hours'
    ) ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status;

    -- 5. Status: IN_PROGRESS
    INSERT INTO public.bookings (
        id, booking_reference, customer_id, service_id, status,
        problem_description, service_address_snapshot, contact_name_snapshot,
        contact_phone_snapshot, preferred_date, preferred_time, assigned_worker_name, scheduled_at, created_at, updated_at
    ) VALUES (
        'b1000000-0000-0000-0000-000000001005', 'TK-1005', v_customer_id,
        's2222222-2222-2222-2222-222222222207', 'IN_PROGRESS',
        'Front wooden door lock jammed and bottom hinge loose. Needs realignment.',
        'No. 12, Fort Street, Galle', 'Malith Silva', '+94 72 678 9012',
        CURRENT_DATE, '10:00 AM',
        'Nimal Bandara (Handyman)',
        (CURRENT_DATE + TIME '10:00:00')::TIMESTAMPTZ,
        NOW() - INTERVAL '2 days', NOW() - INTERVAL '30 minutes'
    ) ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status;

    -- 6. Status: COMPLETED (Eligible for Review!)
    INSERT INTO public.bookings (
        id, booking_reference, customer_id, service_id, status,
        problem_description, service_address_snapshot, contact_name_snapshot,
        contact_phone_snapshot, preferred_date, preferred_time, assigned_worker_name, scheduled_at, created_at, updated_at
    ) VALUES (
        'b1000000-0000-0000-0000-000000001006', 'TK-1006', v_customer_id,
        's2222222-2222-2222-2222-222222222206', 'COMPLETED',
        'Living room accent wall painting with weatherproof emulsion coating.',
        'No. 5, Hill Street, Badulla', 'Nilmini Fernando', '+94 77 789 0123',
        CURRENT_DATE - INTERVAL '1 day', '09:00 AM',
        'Sunil Jayawardena (Master Painter)',
        (CURRENT_DATE - INTERVAL '1 day' + TIME '09:00:00')::TIMESTAMPTZ,
        NOW() - INTERVAL '3 days', NOW() - INTERVAL '4 hours'
    ) ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status;

    -- 7. Status: CONFIRMED (Completed & Reviewed)
    INSERT INTO public.bookings (
        id, booking_reference, customer_id, service_id, status,
        problem_description, service_address_snapshot, contact_name_snapshot,
        contact_phone_snapshot, preferred_date, preferred_time, assigned_worker_name, scheduled_at, created_at, updated_at
    ) VALUES (
        'b1000000-0000-0000-0000-000000001007', 'TK-1007', v_customer_id,
        's2222222-2222-2222-2222-222222222203', 'CONFIRMED',
        'Main distribution board tripped switch replacement and earthing check.',
        'No. 20, Beach Road, Tangalle', 'Saman Wickramasinghe', '+94 71 890 1234',
        CURRENT_DATE - INTERVAL '2 days', '04:00 PM',
        'Rohan De Silva (Certified Electrician)',
        (CURRENT_DATE - INTERVAL '2 days' + TIME '16:00:00')::TIMESTAMPTZ,
        NOW() - INTERVAL '4 days', NOW() - INTERVAL '1 day'
    ) ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status;

    -- Seed review for TK-1007
    INSERT INTO public.reviews (
        id, booking_id, customer_id, rating, comment, created_at, updated_at
    ) VALUES (
        'r1000000-0000-0000-0000-000000001007',
        'b1000000-0000-0000-0000-000000001007',
        v_customer_id,
        5,
        'Excellent work by Rohan! Identified the earthing issue immediately and fixed the tripped breaker safely. Highly recommended.',
        NOW() - INTERVAL '1 day',
        NOW() - INTERVAL '1 day'
    ) ON CONFLICT (booking_id) DO UPDATE
    SET rating = EXCLUDED.rating, comment = EXCLUDED.comment;

    -- 8. Status: CANCELLED (Customer Cancellation)
    INSERT INTO public.bookings (
        id, booking_reference, customer_id, service_id, status,
        problem_description, service_address_snapshot, contact_name_snapshot,
        contact_phone_snapshot, preferred_date, preferred_time, cancellation_reason, created_at, updated_at
    ) VALUES (
        'b1000000-0000-0000-0000-000000001008', 'TK-1008', v_customer_id,
        's2222222-2222-2222-2222-222222222201', 'CANCELLED',
        'Minor tap drip fixed by homeowner before technician arrived.',
        'No. 33, Station Road, Matara', 'Dhammika Perera', '+94 77 901 2345',
        CURRENT_DATE, '10:00 AM',
        'Managed to tighten the valve myself. No longer need service.',
        NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'
    ) ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status;

    -- 9. Status: REJECTED (Operator Rejection)
    INSERT INTO public.bookings (
        id, booking_reference, customer_id, service_id, status,
        problem_description, service_address_snapshot, contact_name_snapshot,
        contact_phone_snapshot, preferred_date, preferred_time, rejection_reason, admin_notes, created_at, updated_at
    ) VALUES (
        'b1000000-0000-0000-0000-000000001009', 'TK-1009', v_customer_id,
        's2222222-2222-2222-2222-222222222205', 'REJECTED',
        'Industrial generator overhaul requested.',
        'Offshore Harbour Site, Hambantota', 'Chaminda Dias', '+94 75 012 3456',
        CURRENT_DATE + INTERVAL '3 days', '09:00 AM',
        'TIKKA handles residential home maintenance only. Heavy industrial machinery repair is outside our service scope.',
        'Rejection communicated to customer.',
        NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days'
    ) ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status;

END $$;

COMMIT;
