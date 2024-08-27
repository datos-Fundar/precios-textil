import requests
import pandas as pd
from bs4 import BeautifulSoup
import json

with open('./auxiliares/item2custom_category.json','r') as f:
    item2custom_category = json.load(f)

item2custom_category = {item['item_names']: item['categoria_propia'] for item in item2custom_category}

def extract_numbeo_data()->pd.DataFrame:
    # URL de la página web
    url = "https://www.numbeo.com/cost-of-living/prices_by_country.jsp?displayCurrency=USD&itemId=101&itemId=100&itemId=228&itemId=224&itemId=60&itemId=66&itemId=64&itemId=62&itemId=110&itemId=118&itemId=121&itemId=14&itemId=19&itemId=17&itemId=15&itemId=11&itemId=16&itemId=113&itemId=9&itemId=12&itemId=8&itemId=119&itemId=111&itemId=112&itemId=115&itemId=116&itemId=13&itemId=27&itemId=26&itemId=29&itemId=28&itemId=114&itemId=6&itemId=4&itemId=5&itemId=3&itemId=2&itemId=1&itemId=7&itemId=105&itemId=106&itemId=44&itemId=40&itemId=42&itemId=24&itemId=20&itemId=18&itemId=109&itemId=108&itemId=107&itemId=206&itemId=25&itemId=30&itemId=33&itemId=34"

    # Realizar la solicitud GET a la página web
    response = requests.get(url)
    soup = BeautifulSoup(response.content, "html.parser")

    # Encontrar la tabla en la página
    table = soup.find("table", {"id": "t2"})

    # Obtener las columnas del thead
    columns = [th.get_text(strip=True) for th in table.find("thead").find_all("th")]

    # Obtener las filas del tbody
    rows = []
    for tr in table.find("tbody").find_all("tr"):
        row = [td.get_text(strip=True) for td in tr.find_all("td")]
        rows.append(row)

    data = pd.DataFrame(rows, columns=columns)

    data = pd.melt(data, id_vars=["Rank", "Country"], var_name="item_names", value_name="item_prices_usd").rename(columns = {'Country':'country'}).drop(columns=['Rank'])

    data["item_prices_usd"] = pd.to_numeric(data["item_prices_usd"], errors='coerce')

    return data

def reimputar_items_cerveza(_df:pd.DataFrame, item:str):
    # Reeimputo strings de items
    _df['es_max'] = _df.groupby(['country','item_names'])['item_prices_usd'].transform('max') == _df['item_prices_usd']
    _df.loc[(_df.item_names==item) & (_df.es_max),"item_names"] = f"Restaurants - {item}"
    _df.loc[(_df.item_names==item) & (~_df.es_max),"item_names"] = f"Market - {item}"
    _df = _df.drop(columns='es_max') 
    return _df


def get_numbeo_data(cat_prop:bool = False, mapper:dict = item2custom_category): 
    df = extract_numbeo_data()
    
    ## Reeimputo strings de items
    df = reimputar_items_cerveza(_df=df, item='Imported Beer(0.33 liter bottle)')
    df = reimputar_items_cerveza(_df=df, item='Imported Beer(0.5 liter bottle)')
    
    if cat_prop: 
        df['categoria_propia'] = df['item_names'].map(mapper)
        return df.dropna(subset='categoria_propia')
    
    return df
