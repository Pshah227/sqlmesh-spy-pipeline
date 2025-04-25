import yfinance as yf
import pandas as pd
from pathlib import Path
from datetime import datetime, timedelta

def download_spy_data():
    Path("datasets").mkdir(exist_ok=True)
    
    spy = yf.Ticker("SPY")
    
    end_date = datetime.now()
    start_date = end_date - timedelta(days=20*365)
    
    df = spy.history(start=start_date, end=end_date, interval="1d")
    
    df.reset_index(inplace=True)
    
    df.columns = df.columns.str.lower()
    
    df['symbol'] = 'SPY'
    
    output_path = "datasets/spy.csv"
    df.to_csv(output_path, index=False)
    
    print(f"Downloaded SPY data to {output_path}")
    print(f"Date range: {df['date'].min()} to {df['date'].max()}")
    print(f"Total rows: {len(df)}")
    print("\nData columns:")
    for col in df.columns:
        print(f"- {col}")

if __name__ == "__main__":
    download_spy_data() 