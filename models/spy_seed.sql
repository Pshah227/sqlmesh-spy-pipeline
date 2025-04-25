MODEL (
    name spy_seed,
    kind FULL
);

WITH raw_data AS (
    SELECT *
    FROM read_csv('seeds/spy.csv', 
        columns={
            'date': 'TIMESTAMP',
            'open': 'DOUBLE',
            'high': 'DOUBLE',
            'low': 'DOUBLE',
            'close': 'DOUBLE',
            'volume': 'BIGINT',
            'dividends': 'DOUBLE',
            'stock_splits': 'DOUBLE',
            'capital_gains': 'DOUBLE',
            'symbol': 'TEXT'
        }
    )
)
SELECT
    date,
    open,
    high,
    low,
    close,
    volume,
    dividends,
    stock_splits,
    capital_gains,
    symbol
FROM raw_data; 