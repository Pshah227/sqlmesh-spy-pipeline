MODEL (
    name spy_staging,
    kind FULL,
    cron '@daily',
    grain [date]
);

SELECT
    date,
    symbol,
    open,
    high,
    low,
    close,
    volume
FROM spy_seed
WHERE date IS NOT NULL
  AND close IS NOT NULL
  AND volume > 0;
