#Query 1 - List tables
SELECT table_name
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.INFORMATION_SCHEMA.TABLES`
WHERE table_name LIKE 'events_%'
ORDER BY table_name;

# Query 2 - Peek at structure:
SELECT
  event_date,
  event_timestamp,
  event_name,
  user_pseudo_id,
  platform,
  device.category AS device_category,
  geo.country
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
LIMIT 50;

# Query 3 - most common events
SELECT event_name, COUNT(*) as event_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY event_name
ORDER BY event_count DESC
LIMIT 50;

# Query 4 - Extract session ID - are users appearing across events with the same session ID?
SELECT event_date, event_name, user_pseudo_id, (
  SELECT value.int_value
  FROM UNNEST(event_params)
  WHERE key = 'ga_session_id'
)AS ga_session_id,
(
  SELECT value.string_value
  FROM UNNEST(event_params)
  WHERE key = 'page_location'
) as page_location
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
LIMIT 100;

#Query 5 -

SELECT event_name, COUNT(*) as event_count, COUNT(DISTINCT user_pseudo_id) as users
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name IN ('session_start', 'page_view','view_item', 'add_to_cart','begin_checkout', 'purchase')
GROUP BY event_name
ORDER BY event_count DESC;

# Query 6 - Peek at purchase fields
SELECT
  event_date,
  event_name,
  user_pseudo_id,
  ecommerce.purchase_revenue AS purchase_revenue,
  ecommerce.transaction_id AS transaction_id
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name = 'purchase'
LIMIT 100;

# Query 7 - Peek at item-level structure
SELECT
  event_name,
  item.item_id,
  item.item_name,
  item.item_category,
  item.price,
  item.quantity
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
UNNEST(items) AS item
WHERE event_name IN ('view_item', 'add_to_cart', 'purchase')
LIMIT 100;