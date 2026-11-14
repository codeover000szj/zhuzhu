-- Manual cleanup for the incorrectly attributed inheritor entry requested for removal.
-- Keep the associated heritage works; remove only this person's links and profile.
START TRANSACTION;

DELETE FROM inheritor_item
WHERE inheritor_id = 'INH-2025-005';

DELETE FROM sys_file_info
WHERE business_type = 'INHERITOR'
  AND business_id = 'INH-2025-005';

DELETE FROM inheritor
WHERE id = 'INH-2025-005';

UPDATE course
SET description = REPLACE(
    description,
    '刘德华大师的风筝制作课程',
    '潍坊传统风筝制作课程'
)
WHERE id = 'CRS-2025-004'
  AND description LIKE '%刘德华%';

COMMIT;

-- Expected after applying: no inheritor or links for INH-2025-005; both heritage
-- items HI-2025-004 and HI-2025-005 remain available.
SELECT id FROM inheritor WHERE id = 'INH-2025-005';
SELECT id, title FROM heritage_item WHERE id IN ('HI-2025-004', 'HI-2025-005');
SELECT id FROM inheritor_item WHERE inheritor_id = 'INH-2025-005';
