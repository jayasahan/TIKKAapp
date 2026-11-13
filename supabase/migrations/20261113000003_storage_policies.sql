-- =============================================================================
-- Migration: 20261113000003_storage_policies.sql
-- Description: Supabase Storage bucket and access policies for booking photo uploads.
-- Module: EC5208 — Mobile Application Development (Faculty of Engineering, University of Ruhuna)
-- Owner: Member 2 (ashuraweismann / Herath H.M.K.U.A)
-- Reference: docs/SHARED_CONTRACTS.md (D11), docs/DESIGN_REFERENCE.md
-- =============================================================================

-- =============================================================================
-- 1. CREATE STORAGE BUCKET FOR BOOKING PHOTOS
-- =============================================================================

-- Insert bucket configuration into storage.buckets if not already present
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'booking-photos',
    'booking-photos',
    FALSE, -- Private bucket: access secured via signed URLs or RLS policies
    5242880, -- 5MB file size limit
    ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE
SET
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- =============================================================================
-- 2. STORAGE ROW LEVEL SECURITY POLICIES
-- =============================================================================
-- Folder convention: booking-photos/<customer_uid>/<unique_filename>

-- Allow authenticated users to upload photos into their own folder
CREATE POLICY "booking_photos_insert_own"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'booking-photos'
    AND (storage.foldername(name))[1] = auth.uid()::TEXT
);

-- Allow authenticated users to view photos in their own folder
CREATE POLICY "booking_photos_select_own"
ON storage.objects
FOR SELECT
TO authenticated
USING (
    bucket_id = 'booking-photos'
    AND (storage.foldername(name))[1] = auth.uid()::TEXT
);

-- Allow authenticated users to delete their own uploaded photos
CREATE POLICY "booking_photos_delete_own"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'booking-photos'
    AND (storage.foldername(name))[1] = auth.uid()::TEXT
);
