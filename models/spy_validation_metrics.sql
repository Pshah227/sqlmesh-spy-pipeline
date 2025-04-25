MODEL (
    name spy_validation_metrics,
    kind FULL,
    cron '@daily'
);

SELECT
    COUNT(*) as row_count,
    AVG(daily_return_pct) as avg_daily_return,
    STDDEV(daily_return_pct) as stddev_daily_return,
    COUNT(CASE WHEN ABS(daily_return_pct) > 2.0 THEN 1 END) as num_volatile_days,
    MIN(drawdown_pct) as max_drawdown_pct,
    MAX(date) as latest_date
FROM spy_transformed

