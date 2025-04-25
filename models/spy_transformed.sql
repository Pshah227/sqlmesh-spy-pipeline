MODEL (
    name spy_transformed,
    kind FULL,
    cron '@daily',
    grain [date]
);

WITH base AS (
    SELECT
        date,
        'SPY' as symbol,
        close,
        LAG(close) OVER (ORDER BY date) as prev_close
    FROM spy_staging
),

returns AS (
    SELECT
        *,
        ((close - prev_close) / prev_close * 100.0) as daily_return_pct,
        AVG(close) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as _7d_ma,
        AVG(close) OVER (ORDER BY date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as _30d_ma,
        AVG(close) OVER (ORDER BY date ROWS BETWEEN 89 PRECEDING AND CURRENT ROW) as _90d_ma,
        STDDEV(daily_return_pct) OVER (ORDER BY date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as _30d_volatility,
        MAX(close) OVER (ORDER BY date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as _30d_high
    FROM base
    WHERE prev_close IS NOT NULL
),

monthly_metrics AS (
    SELECT
        *,
        DATE_TRUNC('month', date) as month_start,
        FIRST_VALUE(close) OVER (PARTITION BY DATE_TRUNC('month', date) ORDER BY date) as month_start_close,
        LAG(close, 252) OVER (ORDER BY date) as year_ago_close
    FROM returns
),

final AS (
    SELECT
        date,
        symbol,
        close,
        daily_return_pct,
        _7d_ma as "7d_ma",
        _30d_ma as "30d_ma",
        _90d_ma as "90d_ma",
        _30d_volatility as "30d_volatility",
        ((close - month_start_close) / month_start_close * 100.0) as month_to_date_return,
        CASE WHEN year_ago_close IS NOT NULL 
             THEN ((close - year_ago_close) / year_ago_close * 100.0)
             ELSE NULL
        END as yearly_change_pct,
        CASE WHEN close >= _30d_high THEN TRUE ELSE FALSE END as high_30d_flag,
        CASE WHEN ABS(daily_return_pct) > 2.0 THEN TRUE ELSE FALSE END as volatility_flag,
        ((close - MAX(close) OVER (ORDER BY date)) / MAX(close) OVER (ORDER BY date) * 100.0) as drawdown_pct
    FROM monthly_metrics
)

SELECT * FROM final
WHERE date IS NOT NULL;
