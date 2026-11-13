-- =============================================================================
-- Seed: seed.sql
-- Description: Development seed data for service categories and services.
-- Module: EC5208 — Mobile Application Development (Faculty of Engineering, University of Ruhuna)
-- Owner: Member 2 (ashuraweismann / Herath H.M.K.U.A)
-- Reference: docs/DESIGN_REFERENCE.md, docs/SHARED_CONTRACTS.md
-- =============================================================================

-- =============================================================================
-- 1. SERVICE CATEGORIES
-- =============================================================================
-- Matches the 8 categories from the Figma prototype and proposal:
-- Cleaning, Electrical, Gardening, Handyman, Moving, Painting, Plumbing, Repairs.

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
SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    icon_name = EXCLUDED.icon_name,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- =============================================================================
-- 2. SERVICES & COMMON JOBS
-- =============================================================================

INSERT INTO public.services (id, category_id, slug, name, description, common_jobs, base_price, currency, is_active, sort_order)
VALUES
    -- Plumbing (matches Figma screen 05 details)
    (
        's2222222-2222-2222-2222-222222222201',
        'c1111111-1111-1111-1111-111111111101',
        'plumbing-general',
        'Plumbing',
        'Book trusted help for leaks, taps, pipe issues and basic plumbing.',
        ARRAY[
            'Leaking taps and pipes',
            'Blocked sinks and drains',
            'Fitting or replacing fixtures',
            'Minor plumbing repairs'
        ],
        1500.00,
        'LKR',
        TRUE,
        1
    ),
    (
        's2222222-2222-2222-2222-222222222202',
        'c1111111-1111-1111-1111-111111111101',
        'pipe-drainage-repair',
        'Drainage & Pipe Unclogging',
        'Fast and reliable clearing of stubborn blocked drains, toilets, and gully traps.',
        ARRAY[
            'Gully trap cleaning',
            'Main drain unclogging',
            'Toilet siphon repair'
        ],
        2000.00,
        'LKR',
        TRUE,
        2
    ),

    -- Electrical
    (
        's2222222-2222-2222-2222-222222222203',
        'c1111111-1111-1111-1111-111111111102',
        'electrical-general',
        'Electrical',
        'Expert electrical repairs, fixture replacements, socket wiring, and troubleshooting.',
        ARRAY[
            'Light fixture & chandelier installation',
            'Ceiling fan installation and capacitor replacement',
            'Short circuit & trip switch troubleshooting',
            'Socket and main switch replacement'
        ],
        1800.00,
        'LKR',
        TRUE,
        1
    ),

    -- Cleaning
    (
        's2222222-2222-2222-2222-222222222204',
        'c1111111-1111-1111-1111-111111111103',
        'cleaning-general',
        'Cleaning',
        'Professional home sanitization, deep cleaning, and post-event cleanup.',
        ARRAY[
            'Full house deep cleaning',
            'Kitchen tile & exhaust degreasing',
            'Bathroom stain and lime scale removal',
            'Sofa & upholstery shampooing'
        ],
        3500.00,
        'LKR',
        TRUE,
        1
    ),

    -- Repairs
    (
        's2222222-2222-2222-2222-222222222205',
        'c1111111-1111-1111-1111-111111111104',
        'repairs-general',
        'Repairs',
        'Comprehensive maintenance and repair services for home fixtures and everyday equipment.',
        ARRAY[
            'Door handle and lock mechanism repair',
            'Cabinet hinge alignment and fixing',
            'Window latch and mesh repair',
            'Minor masonry patch-up'
        ],
        1500.00,
        'LKR',
        TRUE,
        1
    ),

    -- Painting
    (
        's2222222-2222-2222-2222-222222222206',
        'c1111111-1111-1111-1111-111111111105',
        'painting-general',
        'Painting',
        'High quality interior and exterior wall painting, waterproof coating, and touch-ups.',
        ARRAY[
            'Interior room repainting',
            'Water damage & crack touch-ups',
            'Exterior weather-shield coating',
            'Door and window enamel painting'
        ],
        4000.00,
        'LKR',
        TRUE,
        1
    ),

    -- Handyman
    (
        's2222222-2222-2222-2222-222222222207',
        'c1111111-1111-1111-1111-111111111106',
        'handyman-general',
        'Handyman',
        'Versatile multi-skilled help for assembly, mounting, drilling, and home adjustments.',
        ARRAY[
            'Flat-pack furniture assembly',
            'Curtain rods, mirrors & artwork hanging',
            'Wall-mounted TV bracket installation',
            'Shelving unit installation'
        ],
        1600.00,
        'LKR',
        TRUE,
        1
    ),

    -- Gardening
    (
        's2222222-2222-2222-2222-222222222208',
        'c1111111-1111-1111-1111-111111111107',
        'gardening-general',
        'Gardening',
        'Lawn care, tree pruning, hedge trimming, and garden beautification.',
        ARRAY[
            'Lawn mowing and weed removal',
            'Tree and shrub pruning',
            'Garden bed preparation and planting',
            'Green waste disposal'
        ],
        2500.00,
        'LKR',
        TRUE,
        1
    ),

    -- Moving
    (
        's2222222-2222-2222-2222-222222222209',
        'c1111111-1111-1111-1111-111111111108',
        'moving-general',
        'Moving',
        'Stress-free moving assistance, packing, loading, and furniture shifting.',
        ARRAY[
            'Apartment shifting assistance',
            'Heavy appliance & furniture relocation',
            'Protective packing & wrapping',
            'Loading and unloading assistance'
        ],
        5000.00,
        'LKR',
        TRUE,
        1
    )
ON CONFLICT (slug) DO UPDATE
SET
    category_id = EXCLUDED.category_id,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    common_jobs = EXCLUDED.common_jobs,
    base_price = EXCLUDED.base_price,
    currency = EXCLUDED.currency,
    is_active = EXCLUDED.is_active,
    sort_order = EXCLUDED.sort_order;
